-- The Integrated Man — profile photo storage (avatars bucket)
--
-- Enables the "Change photo" button in the Fellowship profile sheet. Photos are
-- public (they appear on the shared wall); each man can only write inside his
-- own {user-id}/ folder.
--
-- Deploy: run in the Supabase SQL editor (project rrhslltmkkvlveztylsi) after
-- prayer_wall.sql. Idempotent.

insert into storage.buckets (id, name, public)
values ('avatars', 'avatars', true)
on conflict (id) do update set public = true;

drop policy if exists "avatars public read" on storage.objects;
create policy "avatars public read" on storage.objects
  for select using (bucket_id = 'avatars');

drop policy if exists "avatars insert own" on storage.objects;
create policy "avatars insert own" on storage.objects
  for insert with check (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars update own" on storage.objects;
create policy "avatars update own" on storage.objects
  for update using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);

drop policy if exists "avatars delete own" on storage.objects;
create policy "avatars delete own" on storage.objects
  for delete using (bucket_id = 'avatars' and (storage.foldername(name))[1] = auth.uid()::text);
