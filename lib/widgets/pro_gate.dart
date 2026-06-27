import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../core/providers/trial_provider.dart';
import '../core/theme/app_colors.dart';
import 'supa_button.dart';

class ProGate extends ConsumerWidget {
  final Widget child;
  final String featureName;

  const ProGate({
    super.key,
    required this.child,
    required this.featureName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final trialState = ref.watch(trialStateProvider);

    // If it's a 30-day trial or they bought PRO, let them in!
    if (trialState == TrialState.trial || trialState == TrialState.pro) {
      return child;
    }

    // Otherwise, they are on the Free Plan. Show the premium blurred lock screen.
    return Stack(
      children: [
        // Blurry background of the actual feature
        Positioned.fill(
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
            child: AbsorbPointer(
              child: child,
            ),
          ),
        ),
        // Dark overlay
        Positioned.fill(
          child: Container(
            color: AppColors.bgBase.withOpacity(0.4),
          ),
        ),
        // Upgrade Card
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.bgSurface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.borderDefault),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 32,
                    offset: const Offset(0, 16),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.supaGreen.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.star_rounded, color: AppColors.supaGreen, size: 48),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'PRO Feature',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    '$featureName is a premium feature. Upgrade to PRO to unlock advanced capabilities and support the project!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 32),
                  SupaButton(
                    text: 'View PRO Plans',
                    width: double.infinity,
                    onPressed: () => context.push('/pricing'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
