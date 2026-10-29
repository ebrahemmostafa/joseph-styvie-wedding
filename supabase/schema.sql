-- Run this in Supabase → SQL Editor.
create table if not exists public.rsvps (
  id          bigint generated always as identity primary key,
  created_at  timestamptz not null default now(),
  name        text    not null check (char_length(name) between 1 and 120),
  phone       text             check (char_length(phone) <= 30),
  attending   boolean not null,
  guests      smallint not null default 1 check (guests between 0 and 5),
  message     text             check (char_length(message) <= 1000)
);

alter table public.rsvps enable row level security;

-- Guests (anon key) may only add an RSVP; they cannot read, edit or delete any.
-- View responses in the Supabase dashboard (Table Editor → rsvps).
drop policy if exists "anon can insert rsvp" on public.rsvps;
create policy "anon can insert rsvp"
  on public.rsvps for insert
  to anon
  with check (true);

-- responses.html reads RSVPs through this function. The passcode is checked
-- here in the database, so it never appears in the published page and the
-- table itself stays unreadable with the anon key.
create or replace function public.get_rsvps(passcode text)
returns setof public.rsvps
language plpgsql
security definer
set search_path = public
as $$
begin
  if passcode is distinct from '211126' then
    perform pg_sleep(1);  -- slow down guessing
    raise exception 'invalid passcode' using errcode = '28P01';
  end if;
  return query select * from public.rsvps order by created_at desc;
end;
$$;

revoke all on function public.get_rsvps(text) from public;
grant execute on function public.get_rsvps(text) to anon;
