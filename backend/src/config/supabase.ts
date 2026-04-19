import { createClient } from "supabase";
import { load } from "dotenv";
import { dirname, fromFileUrl, resolve } from "https://deno.land/std@0.208.0/path/mod.ts";

// Resolve .env path relative to project root (backend/), not CWD
const __dirname = dirname(fromFileUrl(import.meta.url));
const envPath = resolve(__dirname, "../../.env");
const examplePath = resolve(__dirname, "../../.env.example");

const env = await load({ envPath, examplePath, allowEmptyValues: true });

const supabaseUrl = env["SUPABASE_URL"];
const supabaseKey = env["SUPABASE_KEY"];
const supabaseServiceKey = env["SUPABASE_SERVICE_KEY"]; // Optional service role key

if (!supabaseUrl || !supabaseKey) {
  throw new Error("Missing Supabase credentials in .env file");
}

export const supabase = createClient(supabaseUrl, supabaseKey);

// Admin client for bypassing RLS and email confirmation (only if service key is provided)
export const supabaseAdmin = supabaseServiceKey 
  ? createClient(supabaseUrl, supabaseServiceKey, {
      auth: {
        autoRefreshToken: false,
        persistSession: false
      }
    })
  : null;
