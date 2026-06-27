import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  // RevenueCat Configuration
  static String get revenueCatAppleKey => dotenv.env['REVENUECAT_APPLE_KEY'] ?? 'appl_your_apple_key_here';
  static String get revenueCatGoogleKey => dotenv.env['REVENUECAT_GOOGLE_KEY'] ?? 'goog_your_google_key_here';

  // Stripe & PayPal Global Configuration
  static String get paypalLink => dotenv.env['PAYPAL_LINK'] ?? 'https://paypal.me/priyamnkar';
  
  // App Mission & Branding
  static const String appName = 'Supamobile';
  static const String developerName = 'Priyamnkar';
  static const String supportEmail = 'priyamnkar@gmail.com';
}
