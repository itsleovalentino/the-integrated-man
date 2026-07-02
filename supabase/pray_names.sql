-- The Integrated Man — show real names/photos on reactions (fixes "AB" on Amen/Praying)
--
-- Reaction identity was looked up only from the profiles table; when that read is
-- blocked or lags, every reactor falls back to "A brother" (→ "AB"). We now also
-- capture the reactor's name + photo ON the reaction itself (like author_name on posts),
-- so it's bulletproof going forward regardless of profile-read timing.
--
-- Run once in the Supabase SQL editor. Idempotent. Pairs with profiles_read_fix.sql
-- (which makes existing reactions/photos resolve too).

alter table public.prayer_prays add column if not exists user_name   text;
alter table public.prayer_prays add column if not exists user_avatar text;
