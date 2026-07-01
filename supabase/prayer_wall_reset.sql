-- The Integrated Man — Prayer Wall RESET (the only one you need to run)
--
-- Run this ONCE in the Supabase SQL editor. It removes every prayer/circle/tribe
-- object from all the earlier migrations (tribes_phase1.sql, prayer_wall.sql,
-- prayer_wall_fix.sql) and rebuilds a single clean wall schema. Safe to run more
-- than once. You do NOT need to run any of the older files after this.

-- 1) Drop all the old tables (cascade takes their policies + indexes with them).
drop table if exists public.prayer_encouragements  cascade;
drop table if exists public.prayer_intercessions   cascade;
drop table if exists public.prayer_prays           cascade;
drop table if exists public.nudges                 cascade;
drop table if exists public.prayers                cascade;
drop table if exists public.tribe_members          cascade;
drop table if exists public.tribes                 cascade;

-- 2) Drop the old tribe functions regardless of their exact signatures.
do $$
declare r record;
begin
  for r in
    select p.oid::regprocedure as sig
    from pg_proc p join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public'
      and p.proname in ('create_tribe', 'join_tribe', 'is_tribe_member')
  loop execute 'drop function if exists ' || r.sig || ' cascade'; end loop;
end $$;

-- 3) profiles — minimal identity (name + avatar), readable by the community.
create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'A brother',
  avatar_url   text,
  updated_at   timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "profiles read all"   on public.profiles;
create policy "profiles read all"   on public.profiles for select using (auth.role() = 'authenticated');
drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own" on public.profiles for insert with check (auth.uid() = id);
drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own" on public.profiles for update using (auth.uid() = id);

-- 4) prayers — the shared wall.
create table public.prayers (
  id            uuid primary key default gen_random_uuid(),
  author_id     uuid not null references public.profiles(id) on delete cascade,
  body          text not null,
  answered      boolean not null default false,
  answered_at   timestamptz,
  answered_note text,
  created_at    timestamptz not null default now()
);
alter table public.prayers enable row level security;
create index prayers_created_idx on public.prayers (created_at desc);
create policy "prayers read all"   on public.prayers for select using (auth.role() = 'authenticated');
create policy "prayers insert own" on public.prayers for insert with check (auth.uid() = author_id);
create policy "prayers update own" on public.prayers for update using (auth.uid() = author_id);
create policy "prayers delete own" on public.prayers for delete using (auth.uid() = author_id);

-- 5) prayer_prays — who is praying (face-stacks + counts).
create table public.prayer_prays (
  prayer_id  uuid not null references public.prayers(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (prayer_id, user_id)
);
alter table public.prayer_prays enable row level security;
create policy "prays read all"   on public.prayer_prays for select using (auth.role() = 'authenticated');
create policy "prays insert own" on public.prayer_prays for insert with check (auth.uid() = user_id);
create policy "prays delete own" on public.prayer_prays for delete using (auth.uid() = user_id);

-- 6) prayer_encouragements — named words, visible only to the asker + sender.
create table public.prayer_encouragements (
  id         uuid primary key default gen_random_uuid(),
  prayer_id  uuid not null references public.prayers(id) on delete cascade,
  from_id    uuid not null references public.profiles(id) on delete cascade,
  body       text not null,
  created_at timestamptz not null default now()
);
alter table public.prayer_encouragements enable row level security;
create policy "enc read mine or to me" on public.prayer_encouragements
  for select using (
    auth.uid() = from_id
    or auth.uid() = (select author_id from public.prayers p where p.id = prayer_id)
  );
create policy "enc insert own" on public.prayer_encouragements for insert with check (auth.uid() = from_id);
create policy "enc delete own" on public.prayer_encouragements for delete using (auth.uid() = from_id);

-- Done. One clean wall. Post from the app — if anything errors now, the app
-- shows the exact message in a toast.
