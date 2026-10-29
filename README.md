# Joseph & Styvie · 21.11.2026

Wedding invitation — Saturday 21 November 2026, 5:00 PM, Novotel Cairo Airport.

## RSVP setup (Supabase)

1. Create a project at https://supabase.com.
2. Open **SQL Editor** and run [`supabase/schema.sql`](supabase/schema.sql).
3. In **Project Settings → API**, copy the Project URL and the `anon` public key.
4. Paste them into `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `config.js`.

The anon key is safe to publish: row-level security only lets guests insert RSVPs.

## Viewing responses

Open `responses.html` and enter the passcode. It shows totals (responses, attending,
total guests, declined), filters, search, and a CSV download.

The passcode is checked inside the database by the `get_rsvps` function in
`supabase/schema.sql`, not in the page. To change it, edit it there and re-run the SQL.
