import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";
// For Razorpay signature verification
import { hmac } from "https://deno.land/x/hmac@v2.0.1/mod.ts";

const supabaseUrl = Deno.env.get("SUPABASE_URL") as string;
const supabaseServiceKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY") as string;
const supabase = createClient(supabaseUrl, supabaseServiceKey);

serve(async (req) => {
  try {
    if (req.method !== "POST") {
      return new Response("Method not allowed", { status: 405 });
    }

    const rawBody = await req.text();
    const signature = req.headers.get("x-razorpay-signature");
    const webhookSecret = Deno.env.get("RAZORPAY_WEBHOOK_SECRET"); // Add this to Supabase Secrets

    // Validate Signature
    if (webhookSecret && signature) {
      const expectedSignature = hmac("sha256", webhookSecret, rawBody, "utf8", "hex");
      if (expectedSignature !== signature) {
        return new Response("Invalid signature", { status: 400 });
      }
    }

    const body = JSON.parse(rawBody);

    if (body.event === "payment.captured") {
      const payment = body.payload.payment.entity;
      const anonId = payment.notes?.anon_id;
      const email = payment.email;
      const amount = payment.amount / 100; // Convert from paise to standard currency

      if (anonId) {
        // Grant Pro status
        const { error } = await supabase.from("anon_supporters").upsert({
          anon_id: anonId,
          email: email,
          is_pro: true,
          last_donation_amount: amount,
          updated_at: new Date().toISOString(),
        });

        if (error) throw error;

        // Record the donation
        await supabase.from("donations").insert({
          anon_id: anonId,
          amount: amount,
          email: email,
          status: "completed",
          created_at: new Date().toISOString(),
        });
      }
    }

    return new Response(JSON.stringify({ success: true }), {
      headers: { "Content-Type": "application/json" },
      status: 200,
    });
  } catch (error) {
    console.error("Error processing Razorpay webhook:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { "Content-Type": "application/json" },
      status: 500,
    });
  }
});
