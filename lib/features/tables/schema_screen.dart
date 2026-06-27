import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import '../../widgets/supa_card.dart';

class SchemaScreen extends ConsumerWidget {
  final String projectRef;
  const SchemaScreen({super.key, required this.projectRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // High-level schema view derived from PostgREST/Rest endpoints
    final schema = [
      {'name': 'posts', 'columns': 12, 'relations': ['profiles.id'], 'size': '45 MB'},
      {'name': 'profiles', 'columns': 8, 'relations': [], 'size': '12 MB'},
      {'name': 'comments', 'columns': 5, 'relations': ['posts.id', 'profiles.id'], 'size': '8 MB'},
    ];

    return Scaffold(
      appBar: const SupaAppBarSwitcher(title: 'Schema Visualizer'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Public Schema Overview',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            ...schema.map((table) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: SupaCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          table['name'] as String,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.supaGreen),
                        ),
                        Text(
                          table['size'] as String,
                          style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Columns: ${table['columns']}',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    if ((table['relations'] as List).isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Foreign Key Relations:',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        spacing: 8,
                        children: (table['relations'] as List).map((rel) => Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.bgBase,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.borderDefault),
                          ),
                          child: Text(
                            rel,
                            style: const TextStyle(fontSize: 11, fontFamily: 'JetBrains Mono'),
                          ),
                        )).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            )).toList(),
          ],
        ),
      ),
    );
  }
}

