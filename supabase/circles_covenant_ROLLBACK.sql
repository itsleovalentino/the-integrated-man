-- The Integrated Man — Circles/Covenant ROLLBACK
-- ================================================
-- Fully reverses circles_covenant.sql. Nothing that held user data is dropped
-- except the NEW covenant tables (which, if you're rolling back before launch,
-- are empty). Existing Fellowship posts are untouched — only their circle tag
-- and the read policy are reverted. Backups (prayers_backup_*) are LEFT IN PLACE.

-- 1) restore the open wall read policy (posts world-readable again)
drop policy if exists "prayers read circle" on public.prayers;
drop policy if exists "prayers read"        on public.prayers;
create policy "prayers read" on public.prayers for select to authenticated using (true);

-- 2) untag posts (the column is left in place, harmless; uncomment to drop it)
update public.prayers set circle_id = null;
-- alter table public.prayers drop column if exists circle_id;

-- 3) drop the new covenant/circle tables + functions (empty pre-launch)
drop function if exists public.regenerate_code(uuid);
drop function if exists public.join_circle(text, text);
drop function if exists public.circle_preview(text);
drop table if exists public.nudges          cascade;
drop table if exists public.covenant_checks cascade;
drop table if exists public.covenants       cascade;
drop table if exists public.circle_members  cascade;
drop table if exists public.circles         cascade;
drop function if exists public.is_circle_member(uuid, uuid);

-- Backups remain: prayers_backup_20260702, prayer_prays_backup_20260702,
-- prayer_encouragements_backup_20260702 — drop them by hand once you're sure.
