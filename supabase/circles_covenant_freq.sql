-- The Integrated Man — add cadence to covenants
-- ===============================================
-- Run ONCE in the Supabase SQL editor, after circles_covenant.sql.
-- Adds how many days a week a covenant is committed to (7 = daily, the default).
-- Idempotent. Existing covenants keep 7 (daily).

alter table public.covenants add column if not exists freq int not null default 7;
