import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import 'functions_provider.dart';
import '../../widgets/supa_card.dart';
import '../../widgets/supa_badge.dart';
import '../../widgets/supa_skeleton.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import '../../widgets/supa_sub_nav.dart';
import '../../widgets/supa_button.dart';
import '../../widgets/supa_text_field.dart';

class FunctionsScreen extends ConsumerWidget {
  final String projectRef;
  const FunctionsScreen({super.key, required this.projectRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final functionsState = ref.watch(edgeFunctionsProvider(projectRef));

    return Scaffold(
      appBar: SupaAppBarSwitcher(
        title: 'Edge Functions',
        bottom: SupaSubNav(
          currentRoute: '/projects/$projectRef/functions',
          items: [
            SubNavItem(label: 'Functions', route: '/projects/$projectRef/functions'),
            SubNavItem(label: 'Secrets', route: '/projects/$projectRef/functions/secrets'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showDeployDialog(context),
        backgroundColor: AppColors.supaGreen,
        child: const Icon(Icons.add, color: Colors.black),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(edgeFunctionsProvider(projectRef).future),
        child: functionsState.when(
          data: (functions) {
            if (functions.isEmpty) {
              return const Center(
                  child: Text('No Edge Functions found in this project'));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: functions.length,
              itemBuilder: (context, index) {
                final function = functions[index];
                final status = function['status'] ?? 'UNKNOWN';
                final updatedAt = SupaDateParser.format(function['updated_at']);

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SupaCard(
                    onTap: () => _showFunctionDetails(context, function),
                    child: Row(
                      children: [
                        Icon(Icons.bolt, color: AppColors.supaWarning, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(function['name'],
                                  style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                'Updated $updatedAt',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        SupaBadge(
                          text: status.toUpperCase(),
                          color: status.toUpperCase() == 'ACTIVE'
                              ? AppColors.supaGreen
                              : AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 3,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SupaSkeleton(width: double.infinity, height: 75),
            ),
          ),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  void _showFunctionDetails(BuildContext context, dynamic function) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgOverlay,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Function: ${function['id']}',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              _buildMetricItem(context, 'Name', function['name']),
              _buildMetricItem(context, 'Status', function['status']),
              _buildMetricItem(context, 'Created At', SupaDateParser.format(function['created_at'])),
              _buildMetricItem(context, 'Updated At', SupaDateParser.format(function['updated_at'])),
              const SizedBox(height: 32),
              const Text('Invoke URL',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.bgBase,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderDefault),
                ),
                child: Text(
                  'https://$projectRef.supabase.co/functions/v1/${function['name']}',
                  style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 11,
                      color: AppColors.textCode),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMetricItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
  void _showDeployDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgOverlay,
        title: const Text('Deploy New Function', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Function Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            const SizedBox(height: 8),
            SupaTextField(label: 'Function Name', placeholder: 'my-service', controller: controller),
            const SizedBox(height: 16),
            Text('Note: Real deployment requires Supabase CLI or GitHub integration. This is a local administrative interface.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Deploying function "${controller.text}"... (Mock Action)')),
              );
            },
            child: Text('Deploy', style: TextStyle(color: AppColors.supaGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

