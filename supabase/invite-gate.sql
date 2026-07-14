-- ============================================================
--  INVITE GATE for account creation ("one code opens the house").
--  Run ONCE in Supabase → SQL Editor. 100% ADDITIVE: creates one new
--  table + two new functions. Touches NOTHING existing — current
--  users, circles, and data are unaffected. Sign-in is never gated.
--
--  Two kinds of valid door codes:
--   1. Any CIRCLE invite code (circles.code) — one code gets a man
--      through the door AND to his brothers' chapel door.
--   2. WAVE codes in invite_codes below — standalone door codes for
--      waitlist launches (with optional use limits + on/off switch).
--
--  Launch-day runbook:
--    insert into public.invite_codes (code, label, max_uses)
--      values ('WAVE2', 'September wave', 100);
--    ...then email the waitlist: "Your code is WAVE2."
--    Kill a code anytime:  update public.invite_codes set active = false where code = 'WAVE2';
-- ============================================================

create table if not exists public.invite_codes (
  code       text primary key,
  label      text,
  max_uses   int,                          -- null = unlimited
  uses       int  not null default 0,
  active     boolean not null default true,
  created_at timestamptz not null default now()
);

alter table public.invite_codes enable row level security;
-- (no policies on purpose: the table is only reachable through the functions below)

-- Pre-signup check (callable before an account exists, so `anon` needs it).
-- Returns 'circle', 'door', or null. Reveals nothing else.
create or replace function public.validate_invite(p_code text)
returns text
language plpgsql
security definer
set search_path = public
as $$
declare
  v text;
begin
  p_code := upper(trim(coalesce(p_code, '')));
  if p_code = '' then return null; end if;
  if exists (select 1 from public.circles c where upper(c.code) = p_code) then
    return 'circle';
  end if;
  select 'door' into v
  from public.invite_codes i
  where upper(i.code) = p_code
    and i.active
    and (i.max_uses is null or i.uses < i.max_uses);
  return v;   -- null when nothing matched
end;
$$;

revoke all on function public.validate_invite(text) from public;
grant execute on function public.validate_invite(text) to anon, authenticated;

-- After a gated signup signs in, count the use (wave codes only; circle
-- joins are already tracked by join_circle). Idempotent enough for MVP.
create or replace function public.redeem_invite(p_code text)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  p_code := upper(trim(coalesce(p_code, '')));
  update public.invite_codes set uses = uses + 1
  where upper(code) = p_code
    and active
    and (max_uses is null or uses < max_uses);
end;
$$;

revoke all on function public.redeem_invite(text) from public;
grant execute on function public.redeem_invite(text) to authenticated;

-- A first wave code to have in hand (adjust or delete freely):
insert into public.invite_codes (code, label, max_uses)
values ('FIRSTFRUIT', 'Founding wave', 25)
on conflict (code) do nothing;

-- ------------------------------------------------------------
-- HONEST NOTE (read me): this gate + the app check stops normal
-- people cold. A developer poking the API directly could still call
-- auth.signUp — closing THAT hole needs Supabase's before-user-created
-- auth hook or an RLS approved-users layer, which we'll do together
-- post-launch (it touches live policies, so not while you're away).
-- For a private beta behind an unlisted app, this gate is the right
-- amount of lock.
-- ------------------------------------------------------------
