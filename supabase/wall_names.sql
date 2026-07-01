-- The Integrated Man — store the author's name ON each post/comment
--
-- Names were only looked up from the profiles table, which can lag or fail to sync,
-- leaving posts showing "A brother". Capturing the name at post time (from the poster's
-- own device, where the name is already required) makes it bulletproof going forward.
-- Run once. Idempotent.

alter table public.prayers               add column if not exists author_name text;
alter table public.prayer_encouragements add column if not exists from_name   text;
