-- The Integrated Man — make encouragements PUBLIC on the prayer wall
--
-- Was: an encouragement was visible only to the person who asked + the sender.
-- Now: everyone signed in can see all encouragements on a prayer (a warmer, comment-like
-- feel for a small circle). Inserts are still your-own-only.
--
-- Run once in the Supabase SQL editor. Idempotent.

drop policy if exists "enc read mine or to me" on public.prayer_encouragements;
drop policy if exists "enc read all"           on public.prayer_encouragements;
create policy "enc read all" on public.prayer_encouragements
  for select to authenticated using (true);
