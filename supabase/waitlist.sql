-- ============================================================
--  WAITLIST capture for the landing page (waitlist-preview.html).
--  Run ONCE in Supabase → SQL Editor when you're ready to launch the page.
--
--  Privacy: RLS is ON with NO policies, so the `anon` key CANNOT read or write
--  the table directly — the email list can never be scraped. The ONLY access is
--  the SECURITY DEFINER function below, which inserts (idempotently) and returns
--  just the person's position number. Nothing exposes the list.
-- ============================================================

create table if not exists public.waitlist (
  id         bigint generated always as identity primary key,
  email      text unique not null,
  source     text,
  created_at timestamptz not null default now()
);

alter table public.waitlist enable row level security;
-- (intentionally no policies → the table is locked; all access goes through join_waitlist)

create or replace function public.join_waitlist(p_email text, p_source text default null)
returns int
language plpgsql
security definer
set search_path = public
as $$
declare
  v_id  bigint;
  v_pos int;
begin
  p_email := lower(trim(p_email));
  if p_email is null or p_email !~ '^[^@[:space:]]+@[^@[:space:]]+\.[^@[:space:]]+$' then
    raise exception 'invalid email';
  end if;
  insert into public.waitlist (email, source)
  values (p_email, p_source)
  on conflict (email) do update set email = excluded.email   -- idempotent: a re-signup returns their existing spot
  returning id into v_id;
  select count(*) into v_pos from public.waitlist where id <= v_id;
  return v_pos;
end;
$$;

revoke all on function public.join_waitlist(text, text) from public;
grant execute on function public.join_waitlist(text, text) to anon, authenticated;
