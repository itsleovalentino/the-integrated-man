# The Integrated Man — Design System & Architecture

> Reference for building a **separate internal tool** (e.g. an admin/CRM) that reads as the same
> product family as the member app. Written from an audit of `index.html` (single-file PWA), `sw.js`,
> and the Supabase backend. **Nothing here changes app behavior — it documents what exists.**
>
> Bottom line up front: the member app is a hand-written, single-file, mobile-first vanilla PWA with a
> strong, well-defined visual language but **no reusable component layer and no build system**. The
> right way to stay "in the family" is to **extract the design tokens + a handful of primitives into a
> shared, versioned CSS package** and build the internal tool on a real framework — *not* to fork or
> import the member app's code.

---

## 1. Technical stack

| Layer | Member app (today) | Notes for the internal tool |
|---|---|---|
| **Framework** | None. Vanilla HTML/CSS/JS, one `index.html` (~12k lines: `<style>` → markup → `<script>`) | Use a real framework (React+Vite+TS or SvelteKit). Do **not** replicate the single-file model. |
| **Build** | None. No bundler, no transpile, no package.json. Ships raw. | The CRM should have a build; keep the two toolchains independent. |
| **Routing** | No URL router. `setView(name)` toggles `hidden` on five view containers + `.active` on nav buttons. Hash read only for `type=recovery` / `install` deep-links. | The CRM needs real routing (tables, detail pages, deep links). |
| **State** | One global `db` object → `localStorage` (`leo_daily_v1`) + Supabase blob. No store library. | Use a proper data layer / query cache; do not reuse the `db` blob model. |
| **Styling** | One inline `<style>` (~4,000 lines). Flat BEM-ish classes (`.pw-card`, `.f21-btn`, `.nav-btn`). CSS custom properties for theming. No utility framework, no preprocessor, no CSS modules. | Reuse the **tokens**; add a component layer the member app never had. |
| **Theming** | `[data-theme="light"]` attribute on `:root`; dark is default. `color-scheme` set. | Same mechanism. Consider **light-default** for an internal tool. |
| **Icons** | Inline stroke SVG (Feather/Lucide style: `fill:none; stroke:currentColor; stroke-width:1.6–2; round caps`). Pillar "orbs" are PNGs (`assets/orb-*.png`). | Adopt Lucide (same visual DNA) instead of hand-inlining. |
| **Fonts** | Google Fonts: **Fraunces** (serif display), **Spline Sans Mono** (eyebrows/codes), **Cormorant Garamond** (auth screens only). System stack for body. | Same fonts = instant family resemblance. |
| **Auth** | Supabase Auth — email/password only (`signUp`, `signInWithPassword`, `resetPasswordForEmail`, `getSession`, `onAuthStateChange`). Client-side invite-code gate. No OAuth/SSO. | See §7 — the CRM must **not** share the member auth project/keys. |
| **Backend** | Supabase (Postgres + Auth + Storage + Edge Functions), via CDN `@supabase/supabase-js@2`, `createClient(url, publishableKey)`. **Publishable key is embedded client-side; RLS is the only security boundary.** | Critical constraint for the CRM — see §7. |
| **Hosting/deploy** | GitHub Pages, `main` → prod root, `dev` → `/dev/`. Service worker cache versioned in lockstep with `APP_VERSION`. | Host the CRM separately (private, auth-gated, ideally behind SSO/VPN). |

**Supabase surface (member app):**
- Tables: `user_state` (whole-state JSON blob per user), `journal_entries` (per-entry rows), `profiles`,
  `prayers` / `prayer_prays` / `prayer_encouragements`, `circles` / `circle_members` / `covenants` /
  `covenant_checks` / `nudges`, `invite_codes`.
- Storage: private `voice` bucket.
- Edge functions: `bible`, `oura`, `push` (API proxies so third-party keys stay server-side).
- Sync model: debounced whole-blob upsert **+** per-entry rows, with **union-merge-on-pull** (a sync can
  add content but never delete it). This is intentionally over-engineered against data loss because the
  content is a man's private journal.

---

## 2. Design tokens

The entire theme is CSS custom properties on `:root` (dark) and `[data-theme="light"]`. **These are the
single most important thing to share.** Values are verbatim from the source.

### 2.1 Color — semantic tokens

| Token | Dark (default) | Light | Role |
|---|---|---|---|
| `--bg` | `#0a0a0b` | `#f4f2ec` | App background (near-black, warm off-white) |
| `--panel` | `#121214` | `#ffffff` | Card / surface |
| `--panel-edge` | `#242426` | `#e5e1d7` | Card border (hairline) |
| `--ink-high` | `#f1efe9` | `#161614` | Highest-contrast text (headings) |
| `--ink` | `#eae8e1` | `#1a1a18` | Body text |
| `--ink-soft` | `#a2a099` | `#5a5750` | Secondary text |
| `--ink-faint` | `#807e78` | `#948f86` | Tertiary / labels / placeholders |
| `--accent` | `#cbb27e` | `#8a6d30` | Gold — the brand accent |
| `--accent-hover` | `#d8c290` | `#715a28` | Accent hover |
| `--accent-soft` | `rgba(203,178,126,.12)` | `rgba(138,109,48,.12)` | Accent fill / tinted backgrounds |
| `--gold-line` | `rgba(203,178,126,.30)` | `rgba(138,109,48,.30)` | Accent border |
| `--field` | `#131314` | `#faf8f3` | Input background |
| `--field-edge` | `#2a2a2c` | `#e1dcd1` | Input / chip border |
| `--line` | `#1b1b1d` | `#ebe7dd` | Divider / list separator |
| `--shadow` | `0 1px 0 rgba(255,255,255,.02)` | `0 1px 2px rgba(40,36,28,.04)` | Default (near-flat) elevation |

**Ethos:** near-black warm field, off-white inks, a single gold accent, hairline borders. Surfaces are
**flat**; dramatic shadow is reserved for floating/overlay elements only.

### 2.2 Color — brand/atmosphere (auth screens ONLY)

Deliberately scoped to the welcome/sign-in experience — do **not** spread into the app shell or the CRM
chrome. Warm ground `#0a0908`, gold `#b69256`, ink `#ece7dd`, Cormorant Garamond, grain + vignette.

### 2.3 Color — pillar palette (categorical / data-viz)

The seven-pillar identity doubles as the app's categorical chart palette. Each is fixed. Reuse these in
the CRM for any pillar-keyed charts so colors mean the same thing in both apps.

| Pillar | Hex | Hue |
|---|---|---|
| Vitality | `#8aa85a` | green |
| Mental | `#5d8cb4` | blue |
| Faith | `#cdcdca` | silver |
| Vocation / Stewardship | `#897fcf` | purple |
| Wealth | `#a8997d` | tan |
| Environment | `#d59f3b` | amber |
| Tribe | `#7faab0` | teal |

Semantic status colors seen inline (not tokenized, worth formalizing): positive/up `#8aa85a`,
negative/down `#d08a72`, fire/urgent `#f5a04a`.

### 2.4 Typography

| Family | Stack | Use |
|---|---|---|
| **Display / serif** | `"Fraunces", "Iowan Old Style", Palatino, Georgia, serif` | Headings, numbers, reflective prose |
| **Body / UI** | `-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif` | Everything chrome |
| **Mono / eyebrow** | `"Spline Sans Mono", ui-monospace, monospace` | Invite codes, section labels, uppercase tracked kickers |
| **Auth display** | `"Cormorant Garamond"` | Welcome/sign-in only |

- Base: **16px / 1.5**. Inputs are **16px** on purpose (prevents iOS zoom-on-focus).
- Content-only scale: `--read-scale` (`1` default, `1.13` when `html[data-textsize="large"]`) — bumps
  reading/writing text without touching chrome. Worth replicating for accessibility.
- **The "eyebrow/label" is the signature type treatment:** `font-size:11px; letter-spacing:.22em;
  text-transform:uppercase; color:var(--ink-faint); font-weight:500` (`.label`). Used everywhere as
  section headers.
- Display headings: light weight (`300`), slightly negative tracking (`-.01em`), e.g. `.modal-title`
  at 28px/300.

### 2.5 Spacing

**There is no formal spacing scale/token.** Values are ad-hoc px on a loose ~4px rhythm. Recurring:

- Page container `.wrap`: `max-width: 620px`, padding `56px 24px 128px` (bottom clears the floating nav).
- Panel padding: `24px`. Card padding: `15–17px`. Modal padding: `32px 28px`.
- Common gaps/margins: `8, 10, 12, 14, 16, 18, 24, 40px`.

> **Recommendation:** formalize a scale (`--space-1:4px … --space-8:40px`) in the shared package. The CRM
> will be denser than the member app; a real scale prevents drift.

### 2.6 Border radii

| Radius | Applied to |
|---|---|
| `10px` | Inputs, textareas |
| `12px` | Small cards, chips-as-blocks, icon tiles |
| `14px` | **`.panel`** — the primary card radius |
| `16px` | `.day-card` and content cards |
| `18px` | `.modal` (dialogs) |
| `20–22px` | Bottom sheets (`.sheet`, install sheet) |
| `999px` / `100px` | **Pills** — buttons, chips, nav, toggles (by far the most common: ~60 uses) |
| `50%` | Circles — orbs, avatars, dots, icon buttons |

Mental model: **inputs 10 · cards 14–16 · dialogs 18 · sheets 20–22 · everything interactive is a pill · anything round is a circle.**

### 2.7 Shadows / elevation

Two tiers only:

1. **Resting surfaces** → `var(--shadow)` (a 1px hairline, effectively flat).
2. **Floating / overlay** → dramatic, soft, large-offset:
   - Bottom nav: `0 12px 38px -10px rgba(0,0,0,.7)` + inset highlights.
   - Modal: `0 20px 60px -20px rgba(0,0,0,.7)`.
   - Glassy popup (trends): `0 30px 80px rgba(0,0,0,.7)`.
   - Bottom sheet: `0 -20px 60px -14px rgba(0,0,0,.75)`.

**Hard rule from the codebase:** never animate `box-shadow` (transform/opacity only) — it caused iOS jank.
Glass surfaces use `backdrop-filter: blur(16px)` (dialed down from 34px for scroll perf).

### 2.8 Responsive breakpoints

Mobile-first, **single 620px column**. Very few breakpoints:

- `max-width: 480px` — collapse two-column grids to one.
- `min-width: 1000px` — the journal drawer docks beside content (the only real "desktop" layout shift).
- `640px` / `1100px` — occasional.
- `prefers-reduced-motion: reduce` — used ~20×; motion is always optional.
- `hover: none` — touch affordances.

> The member app is essentially a **phone app in a browser**. The CRM is the opposite problem (data-dense
> desktop). Share tokens, **not** this layout.

---

## 3. Reusable UI patterns

These patterns are consistent and worth codifying as components in the new tool:

- **Eyebrow + content**: an uppercase tracked `.label` above every section. The core rhythm of the app.
- **Panel/card**: `var(--panel)` bg, 1px `--panel-edge` border, radius 14, `var(--shadow)`. Flat, calm.
- **Gold-line emphasis card**: swap the border for `--gold-line` and add `--accent-soft` fill to mark
  something special (used for "next step", primary CTAs, active states).
- **Pill button / chip**: radius 999, uppercase tracked for CTAs; `.on`/`.active` fills with `--accent`
  and flips text to `--bg`. `:active { transform: scale(.98) }` + a haptic `buzz()` on every tap.
- **Filled gold CTA**: gradient `linear-gradient(135deg, var(--accent-hover), var(--accent))`, dark text,
  pill radius (`.f21-begin` / `.f21-btn`).
- **Field**: `--field` bg, `--field-edge` border, radius 10; focus → border `--accent`, bg `--panel`.
- **Dialog stack**: `.modal-overlay` (dim + `blur(3px)`) → `.modal` (max-width 440, radius 18). Sticky
  `.modal-head` with circular `.modal-x`; scroll body; pinned footer for primary actions. Overlay-click
  closes; `[hidden]{display:none!important}` guarantees hide over `display:flex`.
- **Bottom sheet**: `.sheet`, slide-up, top-rounded 20–22, for contextual actions on mobile.
- **Glassy popup**: `.trends-pop` — centered, backdrop-blur, scrollable card; the pattern to reuse for
  any focused overlay (incl. charts).
- **Toast**: `.toast` with uppercase `.toast-kicker`, body, optional clamp (`-webkit-line-clamp:4`) for
  long content, dismiss X.
- **Row list**: flex/grid rows separated by `border-bottom: 1px solid var(--line)`; compact glassy rows
  (`.cov-row`) for board-style lists.
- **Empty state**: italic, `--ink-faint`, centered, generous padding, gentle copy. No illustration.
- **Data-viz**: hand-rolled inline SVG. Line/area (`.tg-line`/`.tg-area` = accent stroke + `--accent-soft`
  fill), sparklines in pillar colors, count-up number tweens, ±deadband delta chips (up/down/flat). A
  small, tasteful charting language already exists — reuse its color/stroke conventions.
- **Honest async feedback**: "Saving… / Saved ✓" only shown after a write is actually confirmed; loading
  is inline text, not spinners; renders optimistically from cache. Good pattern to carry into the CRM.

---

## 4. Existing components worth reusing (extract, don't fork)

Extract these into a shared, versioned package (`@tim/design-tokens`) as **static CSS + a few HTML
patterns**, framework-agnostic:

1. **The token sheet** — §2.1/2.3/2.4/2.6/2.7 as `tokens.css` (both themes). *Highest priority.*
2. **Font loading** — the exact Google Fonts `<link>` + family stacks.
3. **Base primitives CSS** — `.panel`, `.label`, `input/textarea`, pill-button + chip, `.modal*`,
   `.sheet`, `.toast`, empty-state, divider. These are self-contained and theme-driven.
4. **The charting conventions** — accent line/area, pillar-color sparklines, delta chips, count-up tween.
5. **Auth + Supabase client wiring pattern** (the shape, not the project) — `createClient`, session
   bootstrap via `getSession` + `onAuthStateChange`, email/password + reset flow.
6. **Pillar palette + labels** — as a shared constant so charts agree across apps.

---

## 5. Components that should NOT be shared

These are member-product-specific or architecturally unsafe to reuse:

- **The single-file `db` blob + localStorage schema** — member-shaped, and holds sacred journal data.
- **The sync/merge engine** (`mergeRecover`, `applyCloud`, per-entry rails, uid-tagging) — tuned to the
  journal's *never-lose-a-word* guarantee; irrelevant and risky in a CRM with different data.
- **The Forge / The 21 engine** (`t21*`, `.f21-*`), **Fellowship/circles**, **in-app Bible reader**,
  **pillar scorer**, **ambient breathing background**, **celebration/haptic layer** — all member features.
- **The glassy floating bottom-nav** — a mobile member pattern; a CRM wants a sidebar/top-nav.
- **The pastoral voice** — empty states, celebrations, and copy ("audience of one", "your mirror") are
  wrong register for an internal tool. Keep the *visual* family; drop the devotional tone.
- **The hardcoded member Supabase project + publishable key** — see §7. The CRM must not ship these.

---

## 6. Strategy: a separate internal tool that stays visually consistent

1. **Package the tokens once.** Create `@tim/design-tokens` (a tiny repo/workspace): `tokens.css`
   (`:root` + `[data-theme]`), `fonts.css`, `primitives.css`, `palette.ts` (pillar + status colors),
   `README` with a semver. Both apps consume it. **Copying = drift; package = truth.**
2. **Keep the family markers, change the shell.** Same gold accent, same Fraunces headings + Spline Sans
   Mono eyebrows, same hairline-flat-surface language, same radii/shadow tiers, same theme mechanism.
   But give the CRM a **desktop shell**: left sidebar nav, top bar, denser spacing, real data tables.
3. **Default the CRM to light theme.** Internal/data tools read better light; the token system already
   ships a complete light palette — just set `data-theme="light"` as default (dark remains available).
4. **Add what the member app lacks.** It has *no tables, no pagination, no filters, no bulk actions, no
   real forms-with-validation.* Build those as **new** components on the shared tokens — that's most of
   the CRM's UI surface.
5. **Formalize spacing + status colors** (§2.5, §2.3) in the package while you're at it — the member app
   never needed them but the CRM will.
6. **Match the charts.** Reuse the accent line/area + pillar-color sparkline conventions so an admin
   dashboard feels like the same product looking at the same data.

Result: a person who uses both immediately recognizes the family (color, type, calm surfaces, gold), but
the CRM behaves like the dense desktop tool it needs to be.

---

## 7. Risks of sharing code/backend between the member app and the CRM

Ordered by severity. The first two are non-negotiable.

1. **Shared Supabase project = privacy blast radius.** Member data is deeply personal (faith,
   confessions, addiction/porn recovery, private journals). A CRM that can query `user_state` /
   `journal_entries` is one bad RLS policy or leaked key away from a serious privacy incident. **Mitigation:**
   the CRM uses a **separate Supabase project**, or at absolute minimum a **separate schema with
   least-privilege, aggregate-only access** and its own service credentials — never the member
   publishable key, never row-level member content.
2. **The publishable key is client-visible; an internal tool needs elevated access it must never ship to
   the browser.** Any admin capability (see any member, edit invite codes, read cohort progress) must go
   through a **server/edge layer** with a service-role key held server-side. Do not put privileged keys
   in a client bundle the way the member app puts its publishable key.
3. **Coupling to the `db` blob + sync engine.** Importing the member sync/merge logic drags in
   data-loss-prevention complexity that doesn't fit relational CRM queries and creates a shared surface
   where a CRM change can break member sync. Keep data layers fully separate.
4. **Data-model mismatch.** The member app models everything as one JSON blob per user; a CRM needs
   normalized, queryable, joinable tables. Forcing one model onto the other corrupts both.
5. **Release/toolchain coupling.** The member app is a no-build single file on GitHub Pages; the CRM
   wants a framework + build + private hosting. If they share a runtime, one dictates the other's
   deploys. **Share static CSS tokens, not a JS runtime.**
6. **Token version skew.** If tokens are copy-pasted rather than packaged, the two apps slowly diverge and
   "same family" erodes. Package + version (semver) and pin.
7. **Auth confusion.** Reusing the member auth project means CRM staff and members live in the same user
   pool. Separate the auth boundary; gate the CRM behind SSO/allow-list, not the member invite gate.

---

## 8. Proposed file & component structure for the new tool

A conventional framework app (React + Vite + TypeScript shown; SvelteKit maps 1:1). The **shared token
package** is the connective tissue to the member app.

```
packages/
  design-tokens/                 ← @tim/design-tokens (shared, versioned, framework-agnostic)
    tokens.css                   ← :root + [data-theme="light"] variables (§2.1/2.3)
    fonts.css                    ← Fraunces / Spline Sans Mono / system stacks
    primitives.css               ← .panel .label input button .modal .sheet .toast empty-state
    palette.ts                   ← PILLAR_COLORS, STATUS_COLORS
    spacing.css                  ← formalized --space-* scale (new)
    README.md                    ← usage + semver

apps/
  internal/                      ← the CRM (private, auth-gated)
    package.json
    vite.config.ts
    index.html
    src/
      styles/
        theme.css                ← imports @tim/design-tokens; sets light default
        app.css
      lib/
        supabase.ts              ← SEPARATE project/schema client; privileged calls via edge/server only
        auth.ts                  ← SSO / allow-list session bootstrap (getSession + onAuthStateChange)
        api/                     ← typed data-access (server functions), never raw member content client-side
      components/
        primitives/              ← Button, Input, Select, Textarea, Panel, Label, Chip,
                                    Modal, Sheet, Toast, EmptyState, Spinner   (built on shared tokens)
        data/                    ← DataTable, TableRow, Pagination, Filters, Toolbar,
                                    BulkActions, StatTile, Sparkline, TrendChart, DeltaChip
        layout/                  ← AppShell, Sidebar, TopBar, PageHeader, Breadcrumbs
      features/
        members/                 ← list · detail · cohort views (aggregate/least-privilege)
        the21/                   ← program-progress analytics (read-only)
        circles/                 ← fellowship/circle admin
        invites/                 ← invite-code + wave management
        dashboard/               ← overview KPIs
      routes/                    ← real router (list/detail/deep-link)
      App.tsx
      main.tsx
```

**Component build order:** tokens package → `layout/` shell (sidebar + topbar) → `primitives/` →
`data/` (this is where most CRM value lives and where the member app offers nothing to copy) →
`features/`.

---

## 9. Quick reference — "make it feel like TIM" checklist

- [ ] Import `@tim/design-tokens` (`tokens.css` + `fonts.css` + `primitives.css`).
- [ ] Fraunces for headings/numbers; system font for UI; Spline Sans Mono uppercase-tracked eyebrows.
- [ ] Gold `--accent` for the one primary action per view; everything else calm and hairline.
- [ ] Flat surfaces (`--panel` + 1px `--panel-edge`); heavy shadow only on overlays; never animate shadow.
- [ ] Pills for interactive elements (radius 999); cards at 14–16; dialogs at 18.
- [ ] Inputs 16px, radius 10, focus → accent border.
- [ ] Empty states: italic, faint, centered, kind — but drop the devotional voice for internal copy.
- [ ] Pillar palette for any pillar-keyed chart; accent line/area for trends; delta chips with a deadband.
- [ ] Respect `prefers-reduced-motion` and offer a content text-scale.
- [ ] **Separate Supabase boundary, privileged keys server-side only.** (Non-negotiable.)
```
