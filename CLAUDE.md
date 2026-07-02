# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

**The Integrated Man (TIM) Journal** — a faith-driven daily journal PWA for men: scripture reading
plans + in-app Bible reader, journaling, prayer list, keystone habits, weekly 7-pillar check, and a
shared community Prayer Wall ("Fellowship"). Single-file vanilla HTML/CSS/JS — **no build step, no
framework, no bundler**. Auth + sync via Supabase. Live at https://itsleovalentino.github.io/the-integrated-man/.

## File structure

- `index.html` — the entire app (~8,500 lines: CSS, markup, and JS in one file)
- `sw.js` — service worker (offline precache; `CACHE` version must match `APP_VERSION`)
- `assets/` — brand images: `cross.png`, `logo-trimmed.png`, seven `orb-<pillar>.png`
- `supabase/` — SQL to run in the Supabase SQL editor. `prayer_wall_FINAL.sql` is the current wall
  schema (supersedes `prayer_wall.sql`/`_fix`/`_reset`); `avatars_storage.sql` = profile-photo bucket;
  `tribes_phase1.sql` is deprecated. `functions/bible` + `functions/oura` are Deno edge functions
  (API proxies so keys stay server-side).
- `docs/` — design notes

## Navigating index.html

Everything lives in one file; navigate by grepping the `=====` section banners. Key sections (names
are stable, line numbers drift): audio vault (IndexedDB voice storage) → pillar cards → In-app Bible →
Anchor verses → Prayer Wall → App shell: bottom nav (Home / Journal / Bible / Fellowship, `setView()`) →
Voice: dictation + memos → Thought capture → Journal (Day One–style drawer) → Trash (soft-delete) →
Full journal page → daily render → Morning threshold → accounts + cloud sync (Supabase) →
customize mode (home widgets) → init + auto-renew.

## Run / deploy

- **Run locally:** it's just `index.html` — open it directly or serve the folder with any static server.
- **Deploy:** bump `APP_VERSION` in index.html **and** `CACHE` in sw.js (keep them in lockstep, e.g.
  `v54`/`tim-v54`), commit, `git push origin main`. GitHub Pages auto-deploys from `main`.
- Verify live: `curl -s https://itsleovalentino.github.io/the-integrated-man/ | grep APP_VERSION`
- Pages deploys occasionally hang GitHub-side (~10 min then fail) — re-trigger with an empty commit.
- **Never ask for git tokens.** Credentials are handled (gh CLI / macOS keychain). If a push 403s,
  report it — Leo re-seeds the keychain himself.

## Data: where everything is stored

All user data lives in one in-memory object `db`, persisted as JSON. Journal entries specifically:

- `db.thoughts` — **the main journal stream**: `[{id, text, title, html, voice, mood, star, ts, dateKey}]`.
  Free-writes and quick captures both land here via `addThought()`. IDs from `newId("t")`.
- `db.journal` / `db.evening` / `db.morning` — dateKey → string (daily prompt answers, one per day)
- `db.noteTrash` — soft-deleted thoughts (recoverable; capped at last 200)
- `db.trash` — dateKey → snapshot of a deleted day's prompt entries (restorable)
- `db.voice` + IndexedDB — voice memo audio; `splitAudio()` strips data-URLs into `aud:*` refs before
  any persist (localStorage + cloud stay small), `rehydrateAudio()` pulls them back on load
- Other stores: `db.prayers`, `db.habits`/`db.habitLog`, `db.ratings` (pillars), `db.anchors`,
  `db.scriptureNotes`, `db.readLog`, `db.layout` (home widgets), `db.profile`

## How saves work

Every mutation calls `save()`, the single write path:
1. stamps `db.updatedAt` (freshness guard for sync)
2. `writeLocal()` → localStorage key **`leo_daily_v1`** (audio-free via `splitAudio`; failures show a
   sticky warning banner, never silent)
3. `snapshotSafe()` → localStorage key **`leo_daily_safe`** (rolling last-known-good, ≤ every 90s)
4. `cloudPushSoon()` → debounced 1.5s upsert of the whole state blob to Supabase `user_state`
   (minus `SYNC_SKIP` e.g. `bibleCache`), retrying every 8s until confirmed

**Sync safety (hard-won — a bug once wiped an account):** `cloudPull()` runs FIRST on sign-in and all
pushes are gated on `pulled === true` and `db.profile.onboarded`. Cloud wins when local has no
profile; otherwise newer `updatedAt` wins. Never reorder or bypass these guards.

## How deletes work

There is no hard delete of user content anywhere, and it must stay that way:
- Thoughts: `softDeleteThought(id)` moves the record to `db.noteTrash` with `_deletedAt`; an undo
  toast + `restoreThought(id)` bring it back. Deletes find records **by id**, first match only.
- Day entries: snapshot into `db.trash[dateKey]` before clearing; restorable from the Trash view.

## Design system

- **App theme:** CSS variables in `:root` (dark, default) and `[data-theme="light"]`. Near-black
  `--bg:#0a0a0b`, gold accent `--accent:#cbb27e`, warm off-white inks. Fraunces serif for display.
  Always use the variables — never hardcode colors.
- **Brand design system** (Cormorant Garamond + Spline Sans Mono eyebrows, warm ground `#0a0908`,
  gold `#b69256`, grain + vignette atmosphere) is deliberately **scoped to the welcome/sign-in
  screens only** — don't spread it into the app shell.
- Seven pillar orbs (`assets/orb-*.png`) are the brand motif; each pillar has a fixed color.
- Ethos: Romans 12:2 — calm, private, "audience of one." No leaderboards, no public metrics.

## Hard rules

1. **Never hard-delete user data. Soft deletes only** (trash + restore, as above).
2. **Never load, modify, or overwrite whole entry arrays.** Mutate individual records, located by
   their unique `id` (`newId()`), only.
3. **Never ask for git tokens** — gh CLI / keychain handles auth.
4. Keep `APP_VERSION` and the sw.js `CACHE` version in lockstep on every deploy.
