# Joseph & Styvie · 21.11.2026

Wedding invitation — Saturday 21 November 2026, 5:00 PM, Novotel Cairo Airport.

## RSVP setup (Supabase)

1. Create a project at https://supabase.com.
2. Open **SQL Editor** and run [`supabase/schema.sql`](supabase/schema.sql).
3. In **Project Settings → API**, copy the Project URL and the `anon` public key.
4. Paste them into `SUPABASE_URL` and `SUPABASE_ANON_KEY` in `config.js`.

The anon key is safe to publish: row-level security only lets guests insert RSVPs.

## Viewing responses

Set the passcode once in the Supabase SQL Editor (after running `schema.sql`).
Don't commit it — this repo is public:

```sql
select private.set_rsvp_passcode('your-passcode');
```

Run the same line again to change it. Only a bcrypt hash is stored, and after 10 wrong
guesses in 15 minutes the page refuses all attempts until the window passes.

Then open `responses.html` and enter the passcode. It shows totals (responses, attending,
total guests, declined), filters, search, and a CSV download.
