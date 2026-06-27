import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/supa_sub_nav.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import '../../widgets/supa_card.dart';
import 'database_metadata_provider.dart';

class DatabaseSubPage extends ConsumerWidget {
  final String title;
  final String projectRef;
  const DatabaseSubPage({super.key, required this.title, required this.projectRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metadataState = ref.watch(databaseMetadataProvider((projectRef: projectRef, entityType: title)));

    return Scaffold(
      appBar: SupaAppBarSwitcher(
        title: title,
        bottom: SupaSubNav(
          currentRoute: '/projects/$projectRef/database/${title.toLowerCase() == 'functions' ? '' : title.toLowerCase()}',
          items: [
            SubNavItem(label: 'Functions', route: '/projects/$projectRef/database'),
            SubNavItem(label: 'Indexes', route: '/projects/$projectRef/database/indexes'),
            SubNavItem(label: 'Publications', route: '/projects/$projectRef/database/publications'),
            SubNavItem(label: 'Triggers', route: '/projects/$projectRef/database/triggers'),
          ],
        ),
      ),
      body: metadataState.when(
        data: (items) {
          if (items.isEmpty) {
            return _buildEmptyState(context);
          }
          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index] as Map<String, dynamic>;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SupaCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            title.toLowerCase() == 'triggers' ? Icons.bolt : Icons.filter_alt_outlined,
                            size: 16,
                            color: AppColors.supaGreen,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item['name'] ?? 'Unnamed',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          if (item['table'] != null)
                            Container(
                              constraints: const BoxConstraints(maxWidth: 100),
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(color: AppColors.bgOverlay, borderRadius: BorderRadius.circular(4)),
                              child: Text(
                                item['table'],
                                style: TextStyle(fontSize: 10, color: AppColors.textSecondary),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                        ],
                      ),
                      if (item['definition'] != null) ...[
                        const SizedBox(height: 8),
                        Text(
                          item['definition'],
                          style: TextStyle(fontSize: 11, color: AppColors.textMuted, fontFamily: 'JetBrains Mono'),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: AppColors.supaGreen)),
        error: (e, s) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.construction_rounded, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 16),
          Text('No $title found.', style: TextStyle(color: AppColors.textMuted)),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.supaGreen),
            child: Text('Create New $title', style: const TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }
}

