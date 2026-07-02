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

- **Run locally:** `.claude/launch.json` serves the folder on :8765 (preview tools), or open `index.html`.
- **Deploy:** bump `APP_VERSION` in index.html **and** `CACHE` in sw.js (keep them in lockstep, e.g.
  `v55`/`tim-v55`), commit, `git push origin main`. GitHub Pages auto-deploys from `main`.
- **A push is NOT a deploy.** Always verify:
  `curl -s https://itsleovalentino.github.io/the-integrated-man/ | grep APP_VERSION` and `gh run list`.
  Pages deploys can time out GitHub-side (check githubstatus.com for Pages incidents) — re-trigger
  with an empty commit once GitHub recovers. On July 2 2026 a Pages incident kept a critical
  data-loss fix (v54) undeployed for hours while users kept hitting the bug it fixed.
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
profile; otherwise newer `updatedAt` wins **for settings only**. Never reorder or bypass these guards.

**Content is NEVER replaced by sync (v56):** `applyCloud` union-merges everything in `CONTENT_KEYS`
(entries, prayers, day-keyed maps…) — a pull can add content but can never erase it. Deletes travel
as soft tombstones via `noteTrash` (`applyCloudDeletes`; `restoredAt`/`edited` newer than
`_deletedAt` wins). Settings/preferences outside `CONTENT_KEYS` still replace wholesale.

**Per-entry cloud rails (v56, Day One-grade):** every journal entry is also its own row in the
Supabase `journal_entries` table (`supabase/journal_entries.sql`), upserted by id via `syncEntry()`
at every mutation point (add/edit/star/delete/restore — new mutation points MUST call it).
`reconcileEntries()` runs on sign-in: rows come down (newest copy wins per entry), missing local
entries go up. Deletes are a `deleted` flag on the row — rows are never removed. If the table
isn't deployed the client stands down gracefully (`ENTRIES_ON`). `navigator.storage.persist()`
is requested on init to resist OS storage eviction.

## How deletes work

There is no hard delete of user content anywhere, and it must stay that way:
- Thoughts: `softDeleteThought(id)` moves the record to `db.noteTrash` with `_deletedAt`; an undo
  toast + `restoreThought(id)` bring it back. Deletes find records **by id**, first match only.
- Day entries: snapshot into `db.trash[dateKey]` before clearing; restorable from the Trash view.

## Recovery & save transparency

- `mergeRecover()` + the Settings "Recover lost entries" button: strictly ADDITIVE merge from the
  on-device snapshot AND the cloud — adds missing records by id/key, never overwrites. Any new
  record type must be added to `mergeRecover` or it silently won't be recoverable.
- The writer shows a live honest save status (`renderSaveStatus`, `#writerStatus`): "Saving…" →
  "Saved ✓" only after `writeLocal()` actually returned ok (`lastWriteOk`) and sync confirmed.
  Never show "saved" for a write that wasn't verified.
- There is deliberately NO wholesale "restore snapshot" button (removed in v55) — replacing the
  whole journal with an older copy is an overwrite; recovery is merge-only. File import in
  Settings remains the only full-replace path, for true disaster recovery.

## Incident history (why the rules exist)

- **June 30 2026:** sign-in raced the cloud pull; an empty fresh state overwrote the cloud and
  wiped an account → pull-first gating + `pulled` flag + `updatedAt` freshness guard.
- **July 2 2026:** base64 voice memos blew the ~5MB localStorage quota; `save()` failed silently
  for a whole morning of entries → audio vault in IndexedDB, loud failure banner, visible save
  status, additive recovery. Compounded by a GitHub Pages incident that delayed the fix.
- **July 2 2026 (second finding):** old `applyCloud` replaced whole arrays, so a stale device's
  later push could erase another device's unsynced entries on the next pull → content is now
  union-merged, never replaced, plus per-entry cloud rows. Entries lost that morning were
  unrecoverable — they never reached any durable copy.

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
