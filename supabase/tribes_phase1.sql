-- ============================================================
-- The Integrated Man — Tribes, Phase 1
-- Intercession (shared prayer loop) + Encouragement (nudges)
--
-- HOW TO RUN: Supabase dashboard → SQL Editor → New query →
-- paste this whole file → Run. Safe to re-run (idempotent).
--
-- Privacy: a man only ever sees data for tribes he belongs to.
-- The personal journal (user_state) is untouched and never shared.
-- ============================================================

-- ---------- tables ----------
create table if not exists public.tribes (
  id          uuid primary key default gen_random_uuid(),
  name        text not null check (char_length(name) between 1 and 60),
  join_code   text not null unique,
  created_by  uuid not null references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now()
);

create table if not exists public.tribe_members (
  tribe_id      uuid not null references public.tribes(id) on delete cascade,
  user_id       uuid not null references auth.users(id) on delete cascade,
  display_name  text not null default 'A brother',
  role          text not null default 'member',          -- 'owner' | 'member'
  joined_at     timestamptz not null default now(),
  primary key (tribe_id, user_id)
);

create table if not exists public.prayers (
  id            uuid primary key default gen_random_uuid(),
  tribe_id      uuid not null references public.tribes(id) on delete cascade,
  author_id     uuid not null references auth.users(id) on delete cascade,
  author_name   text not null default 'A brother',
  body          text not null check (char_length(body) between 1 and 1000),
  answered      boolean not null default false,
  answered_note text,
  created_at    timestamptz not null default now(),
  answered_at   timestamptz
);

-- the "I prayed for this" loop
create table if not exists public.prayer_intercessions (
  prayer_id   uuid not null references public.prayers(id) on delete cascade,
  user_id     uuid not null references auth.users(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (prayer_id, user_id)
);

-- encouragements: to one brother (to_id) or the whole tribe (to_id null)
create table if not exists public.nudges (
  id          uuid primary key default gen_random_uuid(),
  tribe_id    uuid not null references public.tribes(id) on delete cascade,
  from_id     uuid not null references auth.users(id) on delete cascade,
  from_name   text not null default 'A brother',
  to_id       uuid references auth.users(id) on delete cascade,
  kind        text not null default 'encouragement',     -- encouragement | verse | thinking | proud | backup
  body        text,
  seen        boolean not null default false,
  created_at  timestamptz not null default now()
);

create index if not exists idx_members_user      on public.tribe_members(user_id);
create index if not exists idx_prayers_tribe      on public.prayers(tribe_id, created_at desc);
create index if not exists idx_nudges_tribe       on public.nudges(tribe_id, created_at desc);
create index if not exists idx_interc_prayer      on public.prayer_intercessions(prayer_id);

-- ---------- membership helper (SECURITY DEFINER avoids RLS recursion) ----------
create or replace function public.is_tribe_member(t uuid)
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.tribe_members
    where tribe_id = t and user_id = auth.uid()
  );
$$;

-- ---------- enable Row Level Security ----------
alter table public.tribes               enable row level security;
alter table public.tribe_members        enable row level security;
alter table public.prayers              enable row level security;
alter table public.prayer_intercessions enable row level security;
alter table public.nudges               enable row level security;

-- ---------- policies ----------
-- tribes: you can see tribes you belong to (creation/join go through RPCs below)
drop policy if exists tribes_select on public.tribes;
create policy tribes_select on public.tribes
  for select using (public.is_tribe_member(id));

-- members: see who's in your tribes; leave by deleting your own row
drop policy if exists members_select on public.tribe_members;
create policy members_select on public.tribe_members
  for select using (public.is_tribe_member(tribe_id));
drop policy if exists members_delete_self on public.tribe_members;
create policy members_delete_self on public.tribe_members
  for delete using (user_id = auth.uid());

-- prayers: members read; only the author writes / answers / removes
drop policy if exists prayers_select on public.prayers;
create policy prayers_select on public.prayers
  for select using (public.is_tribe_member(tribe_id));
drop policy if exists prayers_insert on public.prayers;
create policy prayers_insert on public.prayers
  for insert with check (public.is_tribe_member(tribe_id) and author_id = auth.uid());
drop policy if exists prayers_update on public.prayers;
create policy prayers_update on public.prayers
  for update using (author_id = auth.uid()) with check (author_id = auth.uid());
drop policy if exists prayers_delete on public.prayers;
create policy prayers_delete on public.prayers
  for delete using (author_id = auth.uid());

-- intercessions: members of the prayer's tribe; each man manages his own
drop policy if exists interc_select on public.prayer_intercessions;
create policy interc_select on public.prayer_intercessions
  for select using (
    exists (select 1 from public.prayers p where p.id = prayer_id and public.is_tribe_member(p.tribe_id))
  );
drop policy if exists interc_insert on public.prayer_intercessions;
create policy interc_insert on public.prayer_intercessions
  for insert with check (
    user_id = auth.uid()
    and exists (select 1 from public.prayers p where p.id = prayer_id and public.is_tribe_member(p.tribe_id))
  );
drop policy if exists interc_delete on public.prayer_intercessions;
create policy interc_delete on public.prayer_intercessions
  for delete using (user_id = auth.uid());

-- nudges: see those to you, to the whole tribe, or from you; send as yourself; mark your own seen
drop policy if exists nudges_select on public.nudges;
create policy nudges_select on public.nudges
  for select using (
    public.is_tribe_member(tribe_id)
    and (to_id = auth.uid() or to_id is null or from_id = auth.uid())
  );
drop policy if exists nudges_insert on public.nudges;
create policy nudges_insert on public.nudges
  for insert with check (public.is_tribe_member(tribe_id) and from_id = auth.uid());
drop policy if exists nudges_update on public.nudges;
create policy nudges_update on public.nudges
  for update using (to_id = auth.uid()) with check (to_id = auth.uid());
drop policy if exists nudges_delete on public.nudges;
create policy nudges_delete on public.nudges
  for delete using (from_id = auth.uid());

-- ---------- RPCs (SECURITY DEFINER): create + join by code ----------
create or replace function public.create_tribe(p_name text, p_display text)
returns public.tribes
language plpgsql
security definer
set search_path = public
as $$
declare
  alphabet text := 'ABCDEFGHJKMNPQRSTUVWXYZ23456789'; -- no I, L, O, 0, 1
  v_code text;
  i int;
  v_tribe public.tribes;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  loop
    v_code := '';
    for i in 1..6 loop
      v_code := v_code || substr(alphabet, 1 + floor(random() * length(alphabet))::int, 1);
    end loop;
    exit when not exists (select 1 from public.tribes where join_code = v_code);
  end loop;
  insert into public.tribes(name, join_code, created_by)
    values (left(trim(p_name), 60), v_code, auth.uid())
    returning * into v_tribe;
  insert into public.tribe_members(tribe_id, user_id, display_name, role)
    values (v_tribe.id, auth.uid(), coalesce(nullif(left(trim(p_display), 40), ''), 'A brother'), 'owner');
  return v_tribe;
end;
$$;

create or replace function public.join_tribe(p_code text, p_display text)
returns public.tribes
language plpgsql
security definer
set search_path = public
as $$
declare
  v_tribe public.tribes;
begin
  if auth.uid() is null then raise exception 'Not authenticated'; end if;
  select * into v_tribe from public.tribes where join_code = upper(trim(p_code));
  if v_tribe.id is null then raise exception 'No tribe found for that code'; end if;
  insert into public.tribe_members(tribe_id, user_id, display_name, role)
    values (v_tribe.id, auth.uid(), coalesce(nullif(left(trim(p_display), 40), ''), 'A brother'), 'member')
    on conflict (tribe_id, user_id) do update set display_name = excluded.display_name;
  return v_tribe;
end;
$$;

grant execute on function public.create_tribe(text, text) to authenticated;
grant execute on function public.join_tribe(text, text)   to authenticated;

-- done.
