import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

// Initialize Supabase client with the Service Role key to bypass RLS
const supabaseUrl = Deno.env.get("SUPABASE_URL") as string;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") as string;
const supabase = createClient(supabaseUrl, supabaseServiceKey);

serve(async (req) => {
  try {
    // Verify it's a POST request
    if (req.method !== "POST") {
      return new Response("Method not allowed", { status: 405 });
    }

    // Parse the RevenueCat webhook payload
    const body = await req.json();
    const event = body.event;

    if (!event) {
      return new Response("Invalid payload", { status: 400 });
    }

    // The app_user_id is the user's ID we passed to RevenueCat when they logged in.
    // In your app, this is the anon_id.
    const userId = event.app_user_id;
    const eventType = event.type; 

    // Handle different RevenueCat event types
    // https://www.revenuecat.com/docs/webhooks
    if (eventType === "INITIAL_PURCHASE" || eventType === "RENEWAL") {
      // Grant Pro status
      const { error } = await supabase.from("anon_supporters").upsert({
        anon_id: userId,
        is_pro: true,
        updated_at: new Date().toISOString(),
      });

      if (error) throw error;
      
      // Optionally record the donation amount if provided in the webhook
      await supabase.from("donations").insert({
        anon_id: userId,
        amount: event.price || 0,
        status: "completed",
        created_at: new Date().toISOString(),
      });
      
    } else if (eventType === "CANCELLATION" || eventType === "EXPIRATION") {
      // Revoke Pro status
      const { error } = await supabase.from("anon_supporters").upsert({
        anon_id: userId,
        is_pro: false,
        updated_at: new Date().toISOString(),
      });
      
      if (error) throw error;
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error("Error processing webhook:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});
