-- The Integrated Man — Prayer Wall FIX (run this once)
--
-- Why: the earlier tribes_phase1.sql created a `prayers` table with a NOT-NULL
-- `tribe_id`. prayer_wall.sql's "create table if not exists" then skipped it, so
-- the wall was still writing against the old tribe schema → "null value in column
-- tribe_id ... violates not-null constraint". This drops the tribe-era prayer
-- tables and rebuilds them for the global wall, with proper FKs to profiles.
--
-- Safe: there is no real wall data yet. Idempotent. Deploy in the Supabase SQL
-- editor (project rrhslltmkkvlveztylsi). This supersedes prayer_wall.sql.

-- profiles (unchanged if it already exists) --------------------------------
create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'A brother',
  avatar_url   text,
  updated_at   timestamptz not null default now()
);
alter table public.profiles enable row level security;
drop policy if exists "profiles read all" on public.profiles;
create policy "profiles read all" on public.profiles for select using (auth.role() = 'authenticated');
drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own" on public.profiles for insert with check (auth.uid() = id);
drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own" on public.profiles for update using (auth.uid() = id);

-- out with the old prayer tables (tribe-era + any partial wall ones) --------
drop table if exists public.prayer_intercessions cascade;
drop table if exists public.prayer_encouragements cascade;
drop table if exists public.prayer_prays cascade;
drop table if exists public.prayers cascade;

-- prayers: the shared wall --------------------------------------------------
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
create policy "prayers read all"  on public.prayers for select using (auth.role() = 'authenticated');
create policy "prayers insert own" on public.prayers for insert with check (auth.uid() = author_id);
create policy "prayers update own" on public.prayers for update using (auth.uid() = author_id);
create policy "prayers delete own" on public.prayers for delete using (auth.uid() = author_id);

-- prayer_prays: who is praying (face-stacks + counts) -----------------------
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

-- prayer_encouragements: named words, visible only to the asker + sender -----
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
