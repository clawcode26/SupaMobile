import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/providers/core_providers.dart';
import '../auth/service_key_prompt.dart';
import 'package:flutter/services.dart';
import 'storage_provider.dart';
import 'storage_objects_screen.dart';
import '../../widgets/supa_skeleton.dart';
import '../../widgets/supa_card.dart';
import '../../widgets/supa_badge.dart';
import '../../widgets/supa_button.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import '../../widgets/supa_app_bar_switcher.dart';

class StorageScreen extends ConsumerWidget {
  final String projectRef;
  const StorageScreen({super.key, required this.projectRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceKeyState = ref.watch(serviceRoleKeyProvider(projectRef));

    return serviceKeyState.when(
      data: (key) {
        if (key == null) return _buildKeyRequired(context);
        return _buildBucketsList(context, ref);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildKeyRequired(BuildContext context) {
    return Scaffold(
      appBar: const SupaAppBarSwitcher(title: 'Storage'),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off_outlined, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 24),
              Text(
                'Service Role Key Required',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'To browse storage buckets and files, you must provide your project\'s service_role secret key.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 32),
              SupaButton(
                text: 'Enter Service Key',
                onPressed: () => showServiceKeyPrompt(context, projectRef),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBucketsList(BuildContext context, WidgetRef ref) {
    final bucketsState = ref.watch(storageBucketsProvider(projectRef));

    return Scaffold(
      appBar: const SupaAppBarSwitcher(title: 'Storage'),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(storageBucketsProvider(projectRef).future),
        child: bucketsState.when(
          data: (buckets) {
            if (buckets.isEmpty) {
              return const Center(child: Text('No buckets found'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: buckets.length,
              itemBuilder: (context, index) {
                final bucket = buckets[index];
                final isPublic = bucket['public'] ?? false;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SupaCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => StorageObjectsScreen(
                            projectRef: projectRef,
                            bucketId: bucket['id'],
                            bucketName: bucket['name'],
                          ),
                        ),
                      );
                    },
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: bucket['id']));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Bucket ID copied to clipboard')));
                    },
                    child: Row(
                      children: [
                        Icon(Icons.folder, color: AppColors.supaGreen, size: 32),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(bucket['name'], style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(
                                isPublic ? 'Public Bucket' : 'Private Bucket',
                                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                              ),
                            ],
                          ),
                        ),
                        SupaBadge(
                          text: isPublic ? 'Public' : 'Private',
                          color: isPublic ? AppColors.supaGreen : AppColors.textMuted,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            itemCount: 3,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SupaSkeleton(width: double.infinity, height: 70),
            ),
          ),
          error: (e, s) => Center(child: Text('Error: $e')),
        ),
      ),
    );
  }

  void _showBucketInfo(BuildContext context, dynamic bucket) {
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
              Text('Bucket: ${bucket['name']}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              _buildInfoRow('ID', bucket['id']),
              _buildInfoRow('Public', bucket['public'].toString()),
              _buildInfoRow('Created At', bucket['created_at']),
              const SizedBox(height: 32),
              SupaButton(
                text: 'View Files (Coming Soon)',
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow(String label, String value) {
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
}

