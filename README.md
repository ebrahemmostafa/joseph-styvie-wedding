# Joseph & Styvie · 21.11.2026

Wedding invitation — Saturday 21 November 2026, 5:00 PM, Novotel Cairo Airport.

## RSVP setup (Supabase)

1. Create a project at https://supabase.com.
2. Open **SQL Editor** and run [`supabase/schema.sql`](supabase/schema.sql).
3. In **Project Settings → API**, copy the Project URL and the `anon` public key.
4. Paste them into `SUPABASE_URL` and `SUPABASE_ANON_KEY` near the bottom of `index.html`.

The anon key is safe to publish: row-level security only lets guests insert RSVPs.
Responses appear in **Table Editor → rsvps**.
