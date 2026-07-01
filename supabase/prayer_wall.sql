-- The Integrated Man — Prayer Wall (global shared prayer + encouragement)
--
-- One living wall the whole community shares: ask for prayer, pray for each
-- other (face-stacks), leave a named word of encouragement (private to the
-- person who asked), and mark prayers answered with a note.
--
-- Deploy: paste into the Supabase SQL editor (project rrhslltmkkvlveztylsi) and
-- run. Idempotent — safe to run more than once.

-- ---------------------------------------------------------------------------
-- 1) Profiles — minimal identity (name + avatar), readable by the community.
--    Monograms are derived from display_name client-side; avatar_url is the
--    slot real photos drop into later.
-- ---------------------------------------------------------------------------
create table if not exists public.profiles (
  id           uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'A brother',
  avatar_url   text,
  updated_at   timestamptz not null default now()
);
alter table public.profiles enable row level security;

drop policy if exists "profiles read all" on public.profiles;
create policy "profiles read all" on public.profiles
  for select using (auth.role() = 'authenticated');

drop policy if exists "profiles insert own" on public.profiles;
create policy "profiles insert own" on public.profiles
  for insert with check (auth.uid() = id);

drop policy if exists "profiles update own" on public.profiles;
create policy "profiles update own" on public.profiles
  for update using (auth.uid() = id);

-- ---------------------------------------------------------------------------
-- 2) Prayers — the shared wall. Everyone reads; you post/answer as yourself.
-- ---------------------------------------------------------------------------
create table if not exists public.prayers (
  id           uuid primary key default gen_random_uuid(),
  author_id    uuid not null references public.profiles(id) on delete cascade,
  body         text not null,
  answered     boolean not null default false,
  answered_at  timestamptz,
  answered_note text,
  created_at   timestamptz not null default now()
);
alter table public.prayers enable row level security;
create index if not exists prayers_created_idx on public.prayers (created_at desc);

drop policy if exists "prayers read all" on public.prayers;
create policy "prayers read all" on public.prayers
  for select using (auth.role() = 'authenticated');

drop policy if exists "prayers insert own" on public.prayers;
create policy "prayers insert own" on public.prayers
  for insert with check (auth.uid() = author_id);

drop policy if exists "prayers update own" on public.prayers;
create policy "prayers update own" on public.prayers
  for update using (auth.uid() = author_id);

drop policy if exists "prayers delete own" on public.prayers;
create policy "prayers delete own" on public.prayers
  for delete using (auth.uid() = author_id);

-- ---------------------------------------------------------------------------
-- 3) Prayer prays — who is praying (drives the warm face-stacks + counts).
-- ---------------------------------------------------------------------------
create table if not exists public.prayer_prays (
  prayer_id  uuid not null references public.prayers(id) on delete cascade,
  user_id    uuid not null references public.profiles(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (prayer_id, user_id)
);
alter table public.prayer_prays enable row level security;

drop policy if exists "prays read all" on public.prayer_prays;
create policy "prays read all" on public.prayer_prays
  for select using (auth.role() = 'authenticated');

drop policy if exists "prays insert own" on public.prayer_prays;
create policy "prays insert own" on public.prayer_prays
  for insert with check (auth.uid() = user_id);

drop policy if exists "prays delete own" on public.prayer_prays;
create policy "prays delete own" on public.prayer_prays
  for delete using (auth.uid() = user_id);

-- ---------------------------------------------------------------------------
-- 4) Encouragements — named words of encouragement. Visible ONLY to the
--    person who asked (and the sender). Never a public comment thread — love,
--    not a stage.
-- ---------------------------------------------------------------------------
create table if not exists public.prayer_encouragements (
  id         uuid primary key default gen_random_uuid(),
  prayer_id  uuid not null references public.prayers(id) on delete cascade,
  from_id    uuid not null references public.profiles(id) on delete cascade,
  body       text not null,
  created_at timestamptz not null default now()
);
alter table public.prayer_encouragements enable row level security;

drop policy if exists "enc read mine or to me" on public.prayer_encouragements;
create policy "enc read mine or to me" on public.prayer_encouragements
  for select using (
    auth.uid() = from_id
    or auth.uid() = (select author_id from public.prayers p where p.id = prayer_id)
  );

drop policy if exists "enc insert own" on public.prayer_encouragements;
create policy "enc insert own" on public.prayer_encouragements
  for insert with check (auth.uid() = from_id);

drop policy if exists "enc delete own" on public.prayer_encouragements;
create policy "enc delete own" on public.prayer_encouragements
  for delete using (auth.uid() = from_id);
