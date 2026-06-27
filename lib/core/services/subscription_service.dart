import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';

import 'revenuecat_service.dart';

// Provides the real-time pro status
final isProUserProvider = StreamProvider<bool>((ref) {
  return Stream.value(true);
});

// Provides the real-time donation history (Removed Firebase backend)
final donationHistoryProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return Stream.value([]);
});

// StateNotifier to manage subscription actions
class SubscriptionNotifier {
  final Ref _ref;

  SubscriptionNotifier(this._ref);

  Future<void> markAsPro(String anonId, double amount, {String? email}) async {
    // SECURITY UPDATE:
    // The mobile app is no longer allowed to grant Pro status directly.
    // This is handled by the Razorpay Webhook -> Firebase Cloud Function.
    debugPrint('Purchase completed. Webhook will update Firebase.');
  }

  Future<void> restoreMembership(String email, String currentAnonId) async {
    // Disabled since backend is removed
    _ref.invalidate(donationHistoryProvider);
  }
}

final subscriptionActionsProvider = Provider((ref) => SubscriptionNotifier(ref));
