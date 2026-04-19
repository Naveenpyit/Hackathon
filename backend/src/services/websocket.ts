import { createClient } from "supabase";
import { load } from "dotenv";
import { dirname, fromFileUrl, resolve } from "https://deno.land/std@0.208.0/path/mod.ts";

const __dirname = dirname(fromFileUrl(import.meta.url));
const envPath = resolve(__dirname, "../../.env");
const examplePath = resolve(__dirname, "../../.env.example");

const env = await load({ envPath, examplePath, allowEmptyValues: true });

const supabaseUrl = env["SUPABASE_URL"];
const supabaseKey = env["SUPABASE_SERVICE_KEY"] || env["SUPABASE_KEY"];

if (!supabaseUrl || !supabaseKey) {
  throw new Error("Missing Supabase credentials for WebSocket");
}

export const supabaseWs = createClient(supabaseUrl, supabaseKey);

export async function verifyToken(token: string): Promise<{ userId: string; email: string } | null> {
  const { data: { user }, error } = await supabaseWs.auth.getUser(token);
  
  if (error || !user) {
    return null;
  }
  
  return { userId: user.id, email: user.email || "" };
}