import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/supa_card.dart';
import '../../widgets/supa_skeleton.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import 'tables_provider.dart';
import 'table_detail_screen.dart';

class TablesScreen extends ConsumerWidget {
  final String projectRef;
  const TablesScreen({super.key, required this.projectRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tablesState = ref.watch(tableListProvider(projectRef));

    return Scaffold(
      appBar: const SupaAppBarSwitcher(title: 'Tables'),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(tableListProvider(projectRef).future),
        child: tablesState.when(
          data: (tables) {
            if (tables.isEmpty) {
              return Center(child: Text('No tables found in public schema'));
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
              itemCount: tables.length,
              itemBuilder: (context, index) {
                final table = tables[index];
                final tableName = table['table_name'];

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SupaCard(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TableDetailScreen(
                            projectRef: projectRef,
                            tableName: tableName,
                          ),
                        ),
                      );
                    },
                    child: Row(
                      children: [
                        Icon(Icons.table_chart_outlined, color: AppColors.supaGreen),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            tableName,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.edit_outlined, size: 18, color: AppColors.textMuted),
                          onPressed: () => _showEditTableDialog(context, ref, tableName),
                        ),
                        Icon(Icons.chevron_right, color: AppColors.textMuted),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: 8,
            itemBuilder: (_, __) => const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: SupaSkeleton(width: double.infinity, height: 60),
            ),
          ),
          error: (e, s) => Center(child: Text('Error loading tables: $e')),
        ),
      ),
    );
  }
  void _showEditTableDialog(BuildContext context, WidgetRef ref, String tableName) {
    final controller = TextEditingController(text: tableName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgOverlay,
        title: Text('Edit $tableName', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Table Name', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
            SizedBox(height: 8),
            TextField(
              controller: controller,
              style: TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.bgBase,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
            ),
            SizedBox(height: 16),
            Text('Editing structure (Columns, RLS) is currently restricted to the SQL Editor for security.', style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () async {
              final newName = controller.text.trim();
              if (newName.isEmpty || newName == tableName) {
                Navigator.pop(context);
                return;
              }
              try {
                // Showing a temporary loading state or handling via the provider
                await ref.read(tableActionsProvider).renameTable(projectRef, tableName, newName);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Table "$tableName" renamed to "$newName"')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent),
                  );
                }
              }
            },
            child: Text('Update', style: TextStyle(color: AppColors.supaGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}


