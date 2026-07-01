-- The Integrated Man — Prayer Wall (FINAL, definitive)
--
-- Run ONLY this file in the Supabase SQL editor. Ignore every earlier prayer/
-- wall/tribe SQL — this drops all of it and rebuilds clean. Safe to re-run.
--
-- The important fix vs. earlier versions: read policies now target the
-- `authenticated` ROLE directly (TO authenticated USING (true)) instead of the
-- fragile `auth.role() = 'authenticated'` expression, which can evaluate to null
-- and silently return zero rows — that's why the wall stayed empty no matter what.

-- 1) Remove everything from the earlier migrations.
drop table if exists public.prayer_encouragements  cascade;
drop table if exists public.prayer_intercessions   cascade;
drop table if exists public.prayer_prays           cascade;
drop table if exists public.nudges                 cascade;
drop table if exists public.prayers                cascade;
drop table if exists public.tribe_members          cascade;
drop table if exists public.tribes                 cascade;
do $$
declare r record;
begin
  for r in select p.oid::regprocedure as sig from pg_proc p
    join pg_namespace n on n.oid = p.pronamespace
    where n.nspname = 'public' and p.proname in ('create_tribe','join_tribe','is_tribe_member')
  loop execute 'drop function if exists ' || r.sig || ' cascade'; end loop;
end $$;

-- 2) profiles — name + avatar, readable by any signed-in brother.
create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'A brother',
  avatar_url   text,
  updated_at   timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "profiles read"   on public.profiles;
drop policy if exists "profiles insert" on public.profiles;
drop policy if exists "profiles update" on public.profiles;
create policy "profiles read"   on public.profiles for select to authenticated using (true);
create policy "profiles insert" on public.profiles for insert to authenticated with check (auth.uid() = id);
create policy "profiles update" on public.profiles for update to authenticated using (auth.uid() = id);

-- 3) prayers — the shared wall.
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
create policy "prayers read"   on public.prayers for select to authenticated using (true);
create policy "prayers insert" on public.prayers for insert to authenticated with check (auth.uid() = author_id);
create policy "prayers update" on public.prayers for update to authenticated using (auth.uid() = author_id);
create policy "prayers delete" on public.prayers for delete to authenticated using (auth.uid() = author_id);

-- 4) prayer_prays — who is praying.
create table public.prayer_prays (
  prayer_id  uuid not null references public.prayers(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (prayer_id, user_id)
);
alter table public.prayer_prays enable row level security;
create policy "prays read"   on public.prayer_prays for select to authenticated using (true);
create policy "prays insert" on public.prayer_prays for insert to authenticated with check (auth.uid() = user_id);
create policy "prays delete" on public.prayer_prays for delete to authenticated using (auth.uid() = user_id);

-- 5) prayer_encouragements — named words, visible only to the asker + sender.
create table public.prayer_encouragements (
  id         uuid primary key default gen_random_uuid(),
  prayer_id  uuid not null references public.prayers(id) on delete cascade,
  from_id    uuid not null references public.profiles(id) on delete cascade,
  body       text not null,
  created_at timestamptz not null default now()
);
alter table public.prayer_encouragements enable row level security;
create policy "enc read"   on public.prayer_encouragements for select to authenticated
  using (auth.uid() = from_id or auth.uid() = (select author_id from public.prayers p where p.id = prayer_id));
create policy "enc insert" on public.prayer_encouragements for insert to authenticated with check (auth.uid() = from_id);
create policy "enc delete" on public.prayer_encouragements for delete to authenticated using (auth.uid() = from_id);
