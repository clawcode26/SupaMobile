import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:purchases_ui_flutter/purchases_ui_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class RevenueCatService {
  static final _apiKey = dotenv.env['REVENUECAT_API_KEY'] ?? '';
  static const entitlementId = 'SupaMobile Pro';

  static Future<void> initialize() async {
    if (kIsWeb) {
      debugPrint('RevenueCat is not supported on Web. Skipping initialization.');
      return;
    }

    try {
      await Purchases.setLogLevel(LogLevel.debug);
      
      PurchasesConfiguration configuration;
      if (Platform.isAndroid || Platform.isIOS) {
        configuration = PurchasesConfiguration(_apiKey);
        await Purchases.configure(configuration);
        debugPrint('RevenueCat SDK Configured successfully');
      }
    } catch (e) {
      debugPrint('Error configuring RevenueCat: $e');
    }
  }

  /// Logs in to RevenueCat with the given app user ID (e.g., Firebase UID or Supabase anon_id)
  static Future<void> login(String appUserId) async {
    if (kIsWeb) return;
    try {
      await Purchases.logIn(appUserId);
    } catch (e) {
      debugPrint('Error logging in to RevenueCat: $e');
    }
  }

  /// Logs out of RevenueCat
  static Future<void> logout() async {
    if (kIsWeb) return;
    try {
      await Purchases.logOut();
    } catch (e) {
      debugPrint('Error logging out of RevenueCat: $e');
    }
  }

  /// Checks if the user is currently Pro
  static Future<bool> isUserPro() async {
    if (kIsWeb) return false;
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return customerInfo.entitlements.all[entitlementId]?.isActive == true;
    } catch (e) {
      debugPrint('Failed to check pro status: $e');
      return false;
    }
  }

  /// Restores previous purchases
  static Future<bool> restorePurchases() async {
    if (kIsWeb) return false;
    try {
      final customerInfo = await Purchases.restorePurchases();
      return customerInfo.entitlements.all[entitlementId]?.isActive == true;
    } catch (e) {
      debugPrint('Failed to restore purchases: $e');
      return false;
    }
  }

  /// Presents the Paywall Native UI
  static Future<void> presentPaywall() async {
    if (kIsWeb) return;
    try {
      await RevenueCatUI.presentPaywallIfNeeded(
        entitlementId,
        displayCloseButton: true,
      );
    } catch (e) {
      debugPrint('Error presenting paywall: $e');
    }
  }

  /// Presents the Customer Center Native UI for managing subscriptions
  static Future<void> presentCustomerCenter() async {
    if (kIsWeb) return;
    try {
      await RevenueCatUI.presentCustomerCenter();
    } catch (e) {
      debugPrint('Error presenting customer center: $e');
    }
  }
}
