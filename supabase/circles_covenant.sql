-- The Integrated Man — Circles + Weekly Covenant Board
-- =====================================================
-- Run ONCE in the Supabase SQL editor. Idempotent and REVERSIBLE.
-- Nothing is deleted. Existing Fellowship posts are backed up, then tagged
-- into the first circle (data only — no feed UI ships in this version).
-- To undo everything, run circles_covenant_ROLLBACK.sql.
--
-- Model (CLAUDE.md rules apply — no hard deletes, records have unique ids):
--   circles           one row per circle (name, revocable invite code, leader, weekly focus)
--   circle_members    who belongs (multi-circle capable; UI built for one)
--   covenants         APPEND-ONLY: every signing/renewal is a NEW row, never edited/deleted
--   covenant_checks   one row per member per local day; un-mark flips done=false (never deleted)
--   nudges            "got your back" / 🔥, one per (from,to,day,kind) — limit enforced in DB

-- Don't validate function bodies at CREATE time: is_circle_member() references
-- circle_members before that table is created below. (Postgres validates
-- LANGUAGE sql bodies by default; the table exists by the time it's ever called.)
set check_function_bodies = off;

-- ---------- 0) membership helper (SECURITY DEFINER avoids RLS recursion) ----------
create or replace function public.is_circle_member(p_circle uuid, p_user uuid)
returns boolean language sql security definer stable set search_path = public as $$
  select exists (select 1 from public.circle_members m
                 where m.circle_id = p_circle and m.user_id = p_user);
$$;

-- ---------- 1) circles ----------
create table if not exists public.circles (
  id         uuid primary key default gen_random_uuid(),
  name       text not null,
  code       text not null unique,
  created_by uuid not null references auth.users(id) on delete cascade,
  focus_ref  text not null default '2 Corinthians 3:18',
  focus_note text not null default 'Beholding Him, we are transformed into His image — from glory to glory.',
  created_at timestamptz not null default now()
);
alter table public.circles enable row level security;
drop policy if exists "circles read members" on public.circles;
drop policy if exists "circles update leader" on public.circles;
-- members read their circle; anyone authenticated may read the MINIMAL preview via the RPC below
create policy "circles read members" on public.circles for select to authenticated
  using (public.is_circle_member(id, auth.uid()) or created_by = auth.uid());
create policy "circles update leader" on public.circles for update to authenticated
  using (created_by = auth.uid()) with check (created_by = auth.uid());

-- ---------- 2) members ----------
create table if not exists public.circle_members (
  circle_id uuid not null references public.circles(id) on delete cascade,
  user_id   uuid not null references auth.users(id) on delete cascade,
  role      text not null default 'member',   -- 'leader' | 'member'
  joined_day text not null,                    -- the member's LOCAL day (YYYY-MM-DD)
  joined_at timestamptz not null default now(),
  primary key (circle_id, user_id)
);
alter table public.circle_members enable row level security;
drop policy if exists "members read same circle" on public.circle_members;
drop policy if exists "members insert self"       on public.circle_members;
create policy "members read same circle" on public.circle_members for select to authenticated
  using (public.is_circle_member(circle_id, auth.uid()));
-- (joins happen through join_circle() SECURITY DEFINER; a direct self-insert is also allowed)
create policy "members insert self" on public.circle_members for insert to authenticated
  with check (user_id = auth.uid());

-- ---------- 3) covenants (APPEND-ONLY — the vow and its full history) ----------
create table if not exists public.covenants (
  id         uuid primary key default gen_random_uuid(),
  circle_id  uuid not null references public.circles(id) on delete cascade,
  user_id    uuid not null references auth.users(id) on delete cascade,
  body       text not null,                    -- the becoming action
  kind       text not null default 'first',    -- 'first' | 'continue' | 'new'
  signed_day text not null,                    -- LOCAL day the vow was signed (YYYY-MM-DD)
  signed_at  timestamptz not null default now()
);
alter table public.covenants enable row level security;
create index if not exists covenants_circle_idx on public.covenants (circle_id, user_id, signed_at desc);
drop policy if exists "covenants read circle" on public.covenants;
drop policy if exists "covenants insert self" on public.covenants;
create policy "covenants read circle" on public.covenants for select to authenticated
  using (public.is_circle_member(circle_id, auth.uid()));
create policy "covenants insert self" on public.covenants for insert to authenticated
  with check (user_id = auth.uid() and public.is_circle_member(circle_id, auth.uid()));
-- deliberately NO update/delete policy: a vow is immutable; renewal inserts a new row.

-- ---------- 4) daily checks (one per member per local day) ----------
create table if not exists public.covenant_checks (
  id           uuid primary key default gen_random_uuid(),
  circle_id    uuid not null references public.circles(id) on delete cascade,
  user_id      uuid not null references auth.users(id) on delete cascade,
  day          text not null,                  -- LOCAL day (YYYY-MM-DD)
  done         boolean not null default true,
  covenant_id  uuid references public.covenants(id) on delete set null,
  updated_at   timestamptz not null default now(),
  unique (circle_id, user_id, day)
);
alter table public.covenant_checks enable row level security;
create index if not exists checks_circle_day_idx on public.covenant_checks (circle_id, day);
drop policy if exists "checks read circle"  on public.covenant_checks;
drop policy if exists "checks insert self"  on public.covenant_checks;
drop policy if exists "checks update self"  on public.covenant_checks;
create policy "checks read circle" on public.covenant_checks for select to authenticated
  using (public.is_circle_member(circle_id, auth.uid()));
create policy "checks insert self" on public.covenant_checks for insert to authenticated
  with check (user_id = auth.uid() and public.is_circle_member(circle_id, auth.uid()));
create policy "checks update self" on public.covenant_checks for update to authenticated
  using (user_id = auth.uid()) with check (user_id = auth.uid());
-- un-mark is done=false (an UPDATE), never a DELETE.

-- ---------- 5) nudges (got-your-back / 🔥), one per from→to per day per kind ----------
create table if not exists public.nudges (
  id         uuid primary key default gen_random_uuid(),
  circle_id  uuid not null references public.circles(id) on delete cascade,
  from_id    uuid not null references auth.users(id) on delete cascade,
  to_id      uuid not null references auth.users(id) on delete cascade,
  day        text not null,
  kind       text not null default 'back',     -- 'back' | 'fire'
  seen       boolean not null default false,
  created_at timestamptz not null default now(),
  unique (circle_id, from_id, to_id, day, kind)
);
alter table public.nudges enable row level security;
create index if not exists nudges_to_idx on public.nudges (to_id, seen);
drop policy if exists "nudges read mine"   on public.nudges;
drop policy if exists "nudges insert self" on public.nudges;
drop policy if exists "nudges update to"   on public.nudges;
create policy "nudges read mine" on public.nudges for select to authenticated
  using ((from_id = auth.uid() or to_id = auth.uid()) and public.is_circle_member(circle_id, auth.uid()));
create policy "nudges insert self" on public.nudges for insert to authenticated
  with check (from_id = auth.uid() and public.is_circle_member(circle_id, auth.uid()));
create policy "nudges update to" on public.nudges for update to authenticated
  using (to_id = auth.uid()) with check (to_id = auth.uid());

-- ---------- 6) RPCs ----------
-- Minimal, join-free preview so an invited user can see WHO invited them + the
-- circle name before committing. Returns nothing if the code is unknown.
create or replace function public.circle_preview(p_code text)
returns table (circle_name text, inviter_name text)
language sql security definer stable set search_path = public as $$
  select c.name,
         coalesce((select display_name from public.profiles p where p.id = c.created_by), 'A brother')
  from public.circles c where c.code = p_code limit 1;
$$;

-- Join a circle by code. Idempotent (re-join = no-op). joined_day is the caller's LOCAL day.
-- OUT columns are named joined_* so they don't collide with circle_members.circle_id
-- inside the INSERT/ON CONFLICT (that collision raised "column reference is ambiguous").
drop function if exists public.join_circle(text, text);
create or replace function public.join_circle(p_code text, p_day text)
returns table (joined_circle uuid, joined_name text)
language plpgsql security definer set search_path = public as $$
declare v_cid uuid; v_name text;
begin
  select c.id, c.name into v_cid, v_name from public.circles c where c.code = p_code limit 1;
  if v_cid is null then raise exception 'Unknown invite code'; end if;
  insert into public.circle_members (circle_id, user_id, role, joined_day)
  values (v_cid, auth.uid(), 'member', p_day)
  on conflict (circle_id, user_id) do nothing;
  return query select v_cid, v_name;
end;
$$;

-- Leader regenerates the invite code (revokes the old one). Returns the new code.
create or replace function public.regenerate_code(p_circle uuid)
returns text
language plpgsql security definer set search_path = public as $$
declare v_new text;
begin
  if not exists (select 1 from public.circles where id = p_circle and created_by = auth.uid()) then
    raise exception 'Only the circle leader can regenerate the code';
  end if;
  v_new := upper(substr(replace(gen_random_uuid()::text, '-', ''), 1, 6));
  update public.circles set code = v_new where id = p_circle;
  return v_new;
end;
$$;

-- ---------- 7) MIGRATION: back up + tag existing Fellowship posts into "The Circle" ----------
do $$
declare v_leo uuid; v_cid uuid; v_today text := to_char((now() at time zone 'utc'), 'YYYY-MM-DD');
begin
  -- back up the wall tables (timestamped, never touched again) — belt & suspenders
  execute 'create table if not exists public.prayers_backup_20260702 as table public.prayers';
  execute 'create table if not exists public.prayer_prays_backup_20260702 as table public.prayer_prays';
  execute 'create table if not exists public.prayer_encouragements_backup_20260702 as table public.prayer_encouragements';

  -- add the circle tag to posts (nullable — existing rows keep working until tagged)
  alter table public.prayers add column if not exists circle_id uuid references public.circles(id);

  select id into v_leo from auth.users where lower(email) = 'leo@truka.com' limit 1;
  if v_leo is null then raise notice 'leo@truka.com not found — create The Circle manually after Leo signs up.'; return; end if;

  -- create The Circle if it doesn't exist yet; Leo is creator/leader; seeded invite code CORD3
  select id into v_cid from public.circles where code = 'CORD3' limit 1;
  if v_cid is null then
    insert into public.circles (name, code, created_by) values ('The Circle', 'CORD3', v_leo)
    returning id into v_cid;
  end if;

  -- enroll ONLY Leo (per decision — brothers arrive via the invite link)
  insert into public.circle_members (circle_id, user_id, role, joined_day)
  values (v_cid, v_leo, 'leader', v_today) on conflict do nothing;

  -- tag every existing post into The Circle (data rests here; no feed UI this version)
  update public.prayers set circle_id = v_cid where circle_id is null;
end $$;

-- ---------- 8) scope the (dormant) wall reads to circle members ----------
-- Posts no longer world-readable; they rest inside the circle. Reversible in ROLLBACK.
drop policy if exists "prayers read"          on public.prayers;
drop policy if exists "prayers read circle"   on public.prayers;
create policy "prayers read circle" on public.prayers for select to authenticated
  using (circle_id is not null and public.is_circle_member(circle_id, auth.uid()));

reset check_function_bodies;

-- Done. Your invite link: https://itsleovalentino.github.io/the-integrated-man/?join=CORD3
-- (the /dev/ copy uses the same backend: .../the-integrated-man/dev/?join=CORD3)
