import { createClient } from '@supabase/supabase-js';

// These should normally come from environment variables (.env)
// For simplicity in this demo implementation, we load them if available or fallback.
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
