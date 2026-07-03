-- The Integrated Man — store each member's name/photo ON the membership row
-- ==========================================================================
-- Definitive fix for "A brother"/"AB": the board no longer depends on reading the
-- profiles table. Each member's name + photo live on their own circle_members row
-- (which every member of the circle can already read), written by that member's own
-- device. Run once. (Each of the 9 guys just needs to open the app once after this
-- so their name stamps onto their row; the app does it automatically on load.)

alter table public.circle_members add column if not exists member_name   text;
alter table public.circle_members add column if not exists member_avatar text;

-- let a member update their OWN membership row (to write their name/photo)
drop policy if exists "members update self" on public.circle_members;
create policy "members update self" on public.circle_members
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());

-- backfill from profiles right now, so any name already captured shows immediately
update public.circle_members m
set member_name = p.display_name, member_avatar = coalesce(m.member_avatar, p.avatar_url)
from public.profiles p
where m.user_id = p.id and p.display_name is not null and p.display_name <> 'A brother'
  and (m.member_name is null or m.member_name = '' or m.member_name = 'A brother');

-- DIAGNOSTIC (optional): run this SELECT to see what names Supabase actually has.
-- If a member shows blank/'A brother' here, that person never saved a name yet.
-- select cm.user_id, cm.member_name, p.display_name
-- from public.circle_members cm left join public.profiles p on p.id = cm.user_id;
