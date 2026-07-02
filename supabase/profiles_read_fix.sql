-- The Integrated Man — make the wall a real social space (fixes missing photos + "A brother" on reactions)
--
-- The old profiles read policy used `auth.role() = 'authenticated'`, which evaluates
-- unreliably and often returns NO rows for other users. Result: you can't read anyone
-- else's profile, so their photo never loads and every reaction/comment falls back to
-- "A brother" (→ "AB"). The reliable pattern is `to authenticated using (true)`.
--
-- Run once in the Supabase SQL editor. Idempotent.

drop policy if exists "profiles read all" on public.profiles;
drop policy if exists "profiles read"     on public.profiles;
create policy "profiles read" on public.profiles
  for select to authenticated using (true);

-- Make sure the avatars bucket is publicly readable (so photo URLs load for everyone).
insert into storage.buckets (id, name, public) values ('avatars', 'avatars', true)
  on conflict (id) do update set public = true;
drop policy if exists "avatars public read" on storage.objects;
create policy "avatars public read" on storage.objects
  for select using (bucket_id = 'avatars');
