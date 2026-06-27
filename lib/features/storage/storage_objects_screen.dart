import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import 'storage_provider.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import 'package:flutter/services.dart';
import '../../widgets/supa_skeleton.dart';
import '../../widgets/supa_card.dart';
import '../../widgets/supa_badge.dart';

class StorageObjectsScreen extends ConsumerWidget {
  final String projectRef;
  final String bucketId;
  final String bucketName;
  final String path;

  const StorageObjectsScreen({
    super.key,
    required this.projectRef,
    required this.bucketId,
    required this.bucketName,
    this.path = '',
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final objectsState = ref.watch(storageObjectsProvider(
      projectRef: projectRef,
      bucketId: bucketId,
      path: path,
    ));

    return Scaffold(
      appBar: SupaAppBarSwitcher(
        title: path.isEmpty ? bucketName : path.split('/').last,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(storageObjectsProvider(
          projectRef: projectRef,
          bucketId: bucketId,
          path: path,
        ).future),
        child: objectsState.when(
          data: (objects) {
            if (objects.isEmpty) {
              return const Center(child: Text('No objects found in this folder'));
            }

            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: objects.length,
              itemBuilder: (context, index) {
                final obj = objects[index];
                final isFolder = obj['id'] == null;
                final name = obj['name'] as String;
                final metadata = obj['metadata'] ?? {};
                final size = metadata['size'] ?? 0;
                final lastModified = obj['updated_at'] ?? obj['created_at'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SupaCard(
                    onTap: () {
                      if (isFolder) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StorageObjectsScreen(
                              projectRef: projectRef,
                              bucketId: bucketId,
                              bucketName: bucketName,
                              path: path.isEmpty ? name : '$path/$name',
                            ),
                          ),
                        );
                      } else {
                        _showObjectDetails(context, obj);
                      }
                    },
                    onLongPress: () {
                      Clipboard.setData(ClipboardData(text: name));
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Name copied to clipboard')));
                    },
                    child: Row(
                      children: [
                        Icon(
                          isFolder ? Icons.folder_open : Icons.insert_drive_file_outlined,
                          color: isFolder ? AppColors.supaGreen : AppColors.textMuted,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (!isFolder)
                                Text(
                                  'Size: ${_formatBytes(size as num)} • Modified ${SupaDateParser.format(lastModified)}',
                                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                            ],
                          ),
                        ),
                        if (isFolder)
                          Icon(Icons.chevron_right, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
            itemCount: 5,
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

  void _showObjectDetails(BuildContext context, dynamic obj) {
    final metadata = obj['metadata'] ?? {};
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
              Text('Object: ${obj['name']}', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              _buildInfoRow('ID', obj['id'] ?? 'N/A'),
              _buildInfoRow('Content Type', metadata['mimetype'] ?? 'N/A'),
              _buildInfoRow('Size', _formatBytes(metadata['size'] ?? 0)),
              _buildInfoRow('Last Modified', SupaDateParser.format(obj['updated_at'] ?? obj['created_at'])),
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
          Expanded(
            child: Text(
              value, 
              textAlign: TextAlign.end,
              style: const TextStyle(fontWeight: FontWeight.bold),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatBytes(num bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}

