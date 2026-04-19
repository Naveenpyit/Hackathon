Backend (Deno + Oak + Supabase)

Quick start

1. Copy dotenv file:

   cp .env.example .env

2. Fill in your Supabase credentials in .env (SUPABASE_URL, SUPABASE_KEY). If you need admin actions, also set SUPABASE_SERVICE_KEY (keep it secret).

3. Run in development:

   deno task dev

Notes
- The project uses Supabase for auth and data. The middleware requireAuth validates access tokens on protected routes.
- Do not commit real service keys to version control.
