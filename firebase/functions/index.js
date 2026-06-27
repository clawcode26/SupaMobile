const functions = require("firebase-functions");
const admin = require("firebase-admin");
const crypto = require("crypto");
const nodemailer = require("nodemailer");
const cors = require("cors")({ origin: true });

admin.initializeApp();

// OTP Functions
exports.sendOtp = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") return res.status(405).send("Method Not Allowed");
    
    try {
      const { email } = req.body;
      if (!email) return res.status(400).send({ error: "Email required" });

      // Generate 6-digit OTP
      const otp = Math.floor(100000 + Math.random() * 900000).toString();
      
      // Save to Firestore (expires in 10 mins)
      await admin.firestore().collection("otp_codes").doc(email).set({
        code: otp,
        expires_at: admin.firestore.Timestamp.fromMillis(Date.now() + 10 * 60 * 1000)
      });

      // Send Email (Requires SMTP env vars)
      if (process.env.SMTP_HOST) {
        const transporter = nodemailer.createTransport({
          host: process.env.SMTP_HOST,
          port: process.env.SMTP_PORT || 587,
          secure: process.env.SMTP_SECURE === "true",
          auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
          },
        });
        await transporter.sendMail({
          from: `"SupaMobile" <${process.env.SMTP_USER}>`,
          to: email,
          subject: "Your SupaMobile Login Code",
          text: `Your 6-digit login code is: ${otp}`,
        });
      } else {
        console.log(`[DEV MODE] OTP for ${email}: ${otp}`);
      }

      res.status(200).send({ success: true, message: "OTP sent" });
    } catch (error) {
      console.error(error);
      res.status(500).send({ error: error.message });
    }
  });
});

exports.verifyOtp = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    if (req.method !== "POST") return res.status(405).send("Method Not Allowed");

    try {
      const { email, code } = req.body;
      if (!email || !code) return res.status(400).send({ error: "Email and code required" });

      const doc = await admin.firestore().collection("otp_codes").doc(email).get();
      if (!doc.exists) return res.status(400).send({ error: "No OTP found for this email" });

      const data = doc.data();
      if (data.code !== code) return res.status(400).send({ error: "Invalid OTP" });
      if (data.expires_at.toMillis() < Date.now()) return res.status(400).send({ error: "OTP expired" });

      // Valid OTP. Delete it.
      await admin.firestore().collection("otp_codes").doc(email).delete();

      // Get or Create User
      let userRecord;
      try {
        userRecord = await admin.auth().getUserByEmail(email);
      } catch (err) {
        if (err.code === "auth/user-not-found") {
          userRecord = await admin.auth().createUser({ email });
        } else {
          throw err;
        }
      }

      // Generate Custom Token
      const customToken = await admin.auth().createCustomToken(userRecord.uid);
      res.status(200).send({ token: customToken });
    } catch (error) {
      console.error(error);
      res.status(500).send({ error: error.message });
    }
  });
});

exports.razorpayWebhook = functions.https.onRequest(async (req, res) => {
  if (req.method !== "POST") {
    return res.status(405).send("Method Not Allowed");
  }

  try {
    const rawBody = req.rawBody.toString();
    const signature = req.headers["x-razorpay-signature"];
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;

    // Validate Signature
    if (webhookSecret && signature) {
      const expectedSignature = crypto
        .createHmac("sha256", webhookSecret)
        .update(rawBody)
        .digest("hex");
      if (expectedSignature !== signature) {
        return res.status(400).send("Invalid signature");
      }
    }

    const body = JSON.parse(rawBody);

    if (body.event === "payment.captured") {
      const payment = body.payload.payment.entity;
      const appUserId = payment.notes?.anon_id; // This is the Firebase UID passed from React
      const email = payment.email;
      const amount = payment.amount / 100;

      if (appUserId) {
        // We still log it in Firebase DB for our own records
        await admin.firestore().collection("donations").add({
          app_user_id: appUserId,
          amount: amount,
          email: email,
          status: "completed",
          created_at: admin.firestore.FieldValue.serverTimestamp(),
        });

        // Make secure REST API call to RevenueCat to grant the entitlement
        const rcSecretKey = process.env.REVENUECAT_SECRET_KEY;
        if (rcSecretKey) {
          const rcResponse = await fetch(`https://api.revenuecat.com/v1/subscribers/${appUserId}/entitlements/SupaMobile%20Pro/promotional`, {
            method: 'POST',
            headers: {
              'Authorization': `Bearer ${rcSecretKey}`,
              'Content-Type': 'application/json'
            },
            body: JSON.stringify({
              duration: "lifetime" // Or calculate based on amount
            })
          });

          if (!rcResponse.ok) {
            console.error("RevenueCat API Error:", await rcResponse.text());
          }
        } else {
          console.error("REVENUECAT_SECRET_KEY is not set in environment.");
        }
      }
    }

    res.status(200).send({ success: true });
  } catch (error) {
    console.error("Error processing Razorpay webhook:", error);
    res.status(500).send({ error: error.message });
  }
});
