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

-- ── Passcode for responses.html ───────────────────────────────────────────
-- Only a bcrypt hash is stored, in a schema the API cannot reach. The passcode
-- itself is never in this repo: set it once in the SQL Editor (see README):
--   select private.set_rsvp_passcode('your-passcode');
create extension if not exists pgcrypto with schema extensions;
create schema if not exists private;
revoke all on schema private from public, anon, authenticated;

create table if not exists private.settings (
  k text primary key,
  v text not null
);

create table if not exists private.failed_logins (
  at timestamptz not null default now()
);

create or replace function private.set_rsvp_passcode(passcode text)
returns void
language sql
set search_path = private, extensions
as $$
  insert into private.settings (k, v) values ('rsvp_pass', crypt(passcode, gen_salt('bf', 10)))
  on conflict (k) do update set v = excluded.v;
  delete from private.failed_logins;
$$;
revoke all on function private.set_rsvp_passcode(text) from public, anon, authenticated;

-- responses.html reads RSVPs through this function. Returns
--   {"ok": true, "rows": [...]}  or  {"ok": false, "error": "wrong" | "locked"}.
-- It returns instead of raising so a failed guess is recorded (an exception
-- would roll that back). After 10 wrong guesses in 15 minutes, all attempts are
-- refused until the window passes, which caps guessing at ~1,000 tries a day.
-- The lockout deliberately also refuses the right passcode: otherwise it
-- wouldn't slow an attacker at all. Worst case, the couple waits 15 minutes
-- (or re-runs private.set_rsvp_passcode, which clears it).
drop function if exists public.get_rsvps(text);
create or replace function public.get_rsvps(passcode text)
returns json
language plpgsql
security definer
set search_path = public, private, extensions
as $$
declare
  stored text;
begin
  -- One attempt at a time, so parallel guesses can't all pass the count
  -- check before their failures are recorded.
  perform pg_advisory_xact_lock(hashtext('public.get_rsvps'));
  delete from private.failed_logins where at < now() - interval '15 minutes';
  if (select count(*) from private.failed_logins) >= 10 then
    return json_build_object('ok', false, 'error', 'locked');
  end if;

  select v into stored from private.settings where k = 'rsvp_pass';
  if stored is null or passcode is null or crypt(passcode, stored) <> stored then
    insert into private.failed_logins default values;
    perform pg_sleep(1);
    return json_build_object('ok', false, 'error', 'wrong');
  end if;

  return json_build_object('ok', true, 'rows', coalesce(
    (select json_agg(r order by r.created_at desc) from public.rsvps r), '[]'::json));
end;
$$;

revoke all on function public.get_rsvps(text) from public;
grant execute on function public.get_rsvps(text) to anon;
