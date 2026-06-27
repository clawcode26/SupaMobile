import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import '../../widgets/supa_sub_nav.dart';
import '../../widgets/supa_card.dart';
import '../../widgets/supa_badge.dart';

class PoliciesScreen extends ConsumerWidget {
  final String projectRef;
  const PoliciesScreen({super.key, required this.projectRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // RLS policies list (typically from queries, simplified here)
    final policies = [
      {'name': 'Enable read access for all users', 'table': 'posts', 'action': 'SELECT'},
      {'name': 'Enable update for users based on user_id', 'table': 'profiles', 'action': 'UPDATE'},
      {'name': 'Enable insert for authenticated users only', 'table': 'comments', 'action': 'INSERT'},
    ];

    return Scaffold(
      appBar: SupaAppBarSwitcher(
        title: 'Policies',
        bottom: SupaSubNav(
          currentRoute: '/projects/$projectRef/auth/policies',
          items: [
            SubNavItem(label: 'Users', route: '/projects/$projectRef/auth'),
            SubNavItem(label: 'Policies', route: '/projects/$projectRef/auth/policies'),
            SubNavItem(label: 'Providers', route: '/projects/$projectRef/auth/providers'),
          ],
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: policies.length,
        separatorBuilder: (_, __) => SizedBox(height: 12),
        itemBuilder: (context, index) {
          final policy = policies[index];
          return SupaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SupaBadge(
                      text: policy['action']!,
                      color: _getActionColor(policy['action']!),
                    ),
                    Text(
                      'Table: ${policy['table']}',
                      style: TextStyle(fontSize: 12, color: AppColors.textMuted),
                    ),
                  ],
                ),
                SizedBox(height: 12),
                Text(
                  policy['name']!,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                SizedBox(height: 8),
                Text(
                  'using ( (select auth.uid()) = user_id )',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Color _getActionColor(String action) {
    switch (action) {
      case 'SELECT': return Colors.blue;
      case 'INSERT': return AppColors.supaGreen;
      case 'UPDATE': return Colors.orange;
      case 'DELETE': return Colors.red;
      default: return AppColors.textMuted;
    }
  }
}


