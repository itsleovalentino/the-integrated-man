# Tribes — Phase 1 design

A small, invite-only circle of brothers. The journal stays personal and private;
the tribe is a light layer for **intercession** (shared prayer) and **encouragement** (nudges).

## Principles
- The personal journal — entries, thoughts, pillar details, reflections — is **never** shared.
- A man only ever sees data for tribes he belongs to (enforced by Postgres RLS, not the UI).
- Opt-in by action: nothing reaches the tribe unless he posts it.
- No ranking, no leaderboard, no comparison.
- Small and invite-only — a covenant group, not a network.

## Defaults (Phase 1)
- A man can belong to **multiple** tribes; the UI shows one active tribe with a switcher.
- Invite by a **6-character join code** (no ambiguous characters).
- Soft size guidance ~12; not hard-enforced yet.
- Display name = the name already in the app (no last name required).

## Data model
- `tribes` — id, name, join_code, created_by
- `tribe_members` — (tribe_id, user_id), display_name, role (owner/member)
- `prayers` — tribe_id, author, body, answered, answered_note
- `prayer_intercessions` — (prayer_id, user_id)  ← the "I prayed for this" loop
- `nudges` — tribe_id, from, to (null = whole tribe), kind, body, seen

RPCs (run as definer to bootstrap membership safely): `create_tribe(name, display)`,
`join_tribe(code, display)`.

## The prayer loop (the heart)
request → brothers tap **"I prayed for this"** → author sees he's being carried →
author marks **answered** (+ optional note) → the tribe rejoices.

## Encouragement (nudges)
One-tap sends to a brother (or the whole tribe): a verse, "thinking of you / praying for you",
"proud of you", or **"I need backup today"** (a wordless ask for prayer).

## Screens
1. **Tribe tab** — your active tribe, members, switcher, "+ create / join".
2. **Create / Join** — name a tribe (get a code), or enter a code.
3. **Shared prayer** — post a request; pray for others; mark answered; answered list.
4. **Nudge** — pick a brother (or all) + a kind + optional words.

## Later (not Phase 1)
Presence-as-care (gentle "reach out to him"), milestone witnessing, the weekly shared
question, shared reading plan.
