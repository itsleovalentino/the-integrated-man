-- The Integrated Man — FIX join_circle (invite codes were failing for everyone)
-- ============================================================================
-- Bug: the function's RETURNS TABLE columns were named circle_id / circle_name,
-- which collided with circle_members.circle_id inside the INSERT / ON CONFLICT,
-- so Postgres raised: column reference "circle_id" is ambiguous (42702).
-- Result: NO invite code could ever be redeemed.
-- Fix: rename the output columns so there is no collision. Run this once.

create or replace function public.join_circle(p_code text, p_day text)
returns table (joined_circle uuid, joined_name text)
language plpgsql security definer set search_path = public as $$
declare v_cid uuid; v_name text;
begin
  select c.id, c.name into v_cid, v_name from public.circles c where c.code = p_code limit 1;
  if v_cid is null then raise exception 'Unknown invite code'; end if;
  insert into public.circle_members (circle_id, user_id, role, joined_day)
  values (v_cid, auth.uid(), 'member', p_day)
  on conflict (circle_id, user_id) do nothing;
  return query select v_cid, v_name;
end;
$$;
