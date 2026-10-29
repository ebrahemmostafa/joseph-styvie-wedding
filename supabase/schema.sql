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
