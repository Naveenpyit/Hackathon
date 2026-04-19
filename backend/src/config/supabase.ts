import { createClient } from "supabase";
import { load } from "dotenv";

const env = await load();

const supabaseUrl = env["SUPABASE_URL"];
const supabaseKey = env["SUPABASE_KEY"];

if (!supabaseUrl || !supabaseKey) {
  throw new Error("Missing Supabase credentials in .env file");
}

export const supabase = createClient(supabaseUrl, supabaseKey);
