-- The Integrated Man — FIX "A brother" / "AB" everywhere
-- =======================================================
-- Root cause: the profiles table was missing the avatar_url column, so the client's
-- profiles SELECT failed entirely (PostgREST errors the whole query on an unknown
-- column) → NO names/photos loaded → everyone showed "A brother" / "AB".
-- Fix: add the column, and make the read policy the reliable pattern. Run once.

alter table public.profiles add column if not exists avatar_url text;

drop policy if exists "profiles read"     on public.profiles;
drop policy if exists "profiles read all" on public.profiles;
create policy "profiles read" on public.profiles for select to authenticated using (true);
