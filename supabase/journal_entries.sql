-- Per-entry journal rails: every journal entry is its own row, written the moment
-- it changes. Rows are only ever upserted by id — never bulk-replaced — so no sync
-- race, storage failure, or device loss can erase an entry that reached this table.
-- Deletes are a soft flag (deleted=true), never a removed row.
--
-- Run this once in the Supabase SQL editor. The app detects the table and starts
-- using it automatically (until then it logs quietly and relies on blob sync).

create table if not exists public.journal_entries (
  id         text primary key,
  user_id    uuid not null references auth.users(id) on delete cascade,
  data       jsonb not null,
  deleted    boolean not null default false,
  updated_at timestamptz not null default now()
);

alter table public.journal_entries enable row level security;

drop policy if exists "read own entries"   on public.journal_entries;
drop policy if exists "insert own entries" on public.journal_entries;
drop policy if exists "update own entries" on public.journal_entries;

create policy "read own entries" on public.journal_entries
  for select to authenticated using (auth.uid() = user_id);
create policy "insert own entries" on public.journal_entries
  for insert to authenticated with check (auth.uid() = user_id);
create policy "update own entries" on public.journal_entries
  for update to authenticated using (auth.uid() = user_id) with check (auth.uid() = user_id);

create index if not exists journal_entries_user_idx on public.journal_entries (user_id, updated_at desc);
