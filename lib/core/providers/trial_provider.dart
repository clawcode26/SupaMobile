import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/anonymous_identity_service.dart';
import '../services/subscription_service.dart';

import 'package:flutter/foundation.dart';

enum TrialState { trial, free, pro }

final donationDismissedProvider = Provider<ValueNotifier<bool>>((ref) => ValueNotifier<bool>(false));

final trialStateProvider = Provider<TrialState>((ref) {
  final anonAsync = ref.watch(anonymousIdentityProvider);
  final isProAsync = ref.watch(isProUserProvider);

  return isProAsync.when(
    data: (isPro) {
      if (isPro) return TrialState.pro;
      
      return anonAsync.when(
        data: (identity) {
          final now = DateTime.now();
          final difference = now.difference(identity.createdAt);
          if (difference.inDays >= 30) {
            return TrialState.free;
          }
          return TrialState.trial;
        },
        loading: () => TrialState.trial,
        error: (_, __) => TrialState.trial,
      );
    },
    loading: () => TrialState.trial,
    error: (e, st) => TrialState.trial,
  );
});
