import { createClient } from "@supabase/supabase-js";
import { guardedFetch } from "./dbGuard"; // prévient quand la base refuse une action (audit 2026-10-30)

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL as string | undefined;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY as
  | string
  | undefined;

if (!supabaseUrl || !supabaseAnonKey) {
  // eslint-disable-next-line no-console
  console.error(
    "Variables d'environnement Supabase manquantes. Créez un fichier " +
      ".env.local (voir .env.example) avec VITE_SUPABASE_URL et " +
      "VITE_SUPABASE_ANON_KEY."
  );
}

export const supabase = createClient(supabaseUrl ?? "", supabaseAnonKey ?? "", {
  global: { fetch: guardedFetch },
});
