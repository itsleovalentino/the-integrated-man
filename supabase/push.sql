-- ============================================================
--  WEB PUSH subscriptions (the notification test + everything after).
--  Run ONCE in Supabase → SQL Editor. Additive only.
--
--  Each row is one device's push subscription (endpoint + keys), owned by the
--  signed-in man. The `push` edge function (service role) reads them to send.
-- ============================================================

create table if not exists public.push_subs (
  id         bigint generated always as identity primary key,
  user_id    uuid not null references auth.users (id) on delete cascade,
  endpoint   text not null unique,
  sub        jsonb not null,          -- full PushSubscription JSON (endpoint + keys)
  ua         text,                    -- device hint, for debugging
  created_at timestamptz not null default now()
);

alter table public.push_subs enable row level security;

create policy "push: own rows read"   on public.push_subs for select to authenticated using (user_id = auth.uid());
create policy "push: own rows insert" on public.push_subs for insert to authenticated with check (user_id = auth.uid());
create policy "push: own rows update" on public.push_subs for update to authenticated using (user_id = auth.uid());
create policy "push: own rows delete" on public.push_subs for delete to authenticated using (user_id = auth.uid());
