import { createClient } from '@supabase/supabase-js';

// These should normally come from environment variables (.env)
// For simplicity in this demo implementation, we load them if available or fallback.
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL || 'https://hwbawslmbpxzzwyvxpfg.supabase.co';
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpYmlmaHZxdm9uenJpbXptdXpjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI0ODEzNDcsImV4cCI6MjA5ODA1NzM0N30.z6ebGrcbnPcB2r1SnIGuzmY0N0jsyHXEdZfHYOjAVSY';

export const supabase = createClient(supabaseUrl, supabaseAnonKey);
