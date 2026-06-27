-- Enable Row Level Security (RLS) on the tables
ALTER TABLE anon_supporters ENABLE ROW LEVEL SECURITY;
ALTER TABLE donations ENABLE ROW LEVEL SECURITY;

-- Remove any existing permissive policies (if they exist)
-- DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON anon_supporters;
-- DROP POLICY IF EXISTS "Enable update for users based on email" ON anon_supporters;

-- 1. Policies for anon_supporters
-- Users can only READ their own record based on their anon_id
CREATE POLICY "Users can view their own pro status"
ON anon_supporters
FOR SELECT
USING (anon_id = current_setting('request.jwt.claims', true)::json->>'sub');
-- Note: If you are not using Supabase Auth (meaning users are completely anonymous and not signed in via Supabase), 
-- you might just allow public reads (since anon_id is practically a secret UUID).
-- If truly anonymous, uncomment the next line and comment the above policy:
-- CREATE POLICY "Public can view pro status by anon_id" ON anon_supporters FOR SELECT USING (true);

-- NO INSERT/UPDATE/DELETE policies are created for anon_supporters. 
-- This completely blocks the mobile app from writing to this table.
-- The Edge Function bypasses this because it uses the SERVICE ROLE KEY.

-- 2. Policies for donations
-- Users can only READ their own donation history
CREATE POLICY "Users can view their own donations"
ON donations
FOR SELECT
USING (anon_id = current_setting('request.jwt.claims', true)::json->>'sub');
-- Same as above, if truly anonymous without Supabase Auth session:
-- CREATE POLICY "Public can view their donations" ON donations FOR SELECT USING (true);

-- NO INSERT/UPDATE/DELETE policies are created for donations.
