-- The Integrated Man — turn the prayer wall into a living feed
--
-- Adds an is_prayer flag so a post can be a PRAYER REQUEST (button says "Pray")
-- or just a POST / win / encouragement (button says "Amen"). Delete policies for
-- your own posts + comments already exist from the wall setup. Run once.

alter table public.prayers add column if not exists is_prayer boolean not null default true;
