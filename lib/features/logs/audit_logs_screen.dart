import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/supa_card.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import '../projects/projects_provider.dart';

class AuditLogsScreen extends ConsumerWidget {
  final String projectRef;
  const AuditLogsScreen({super.key, required this.projectRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: SupaAppBarSwitcher(title: 'Audit Logs'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audit Logs',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Track clinical and administrative actions across your project.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 24),
            _buildLogFilters(context),
            const SizedBox(height: 16),
            _buildLogsList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildLogFilters(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip('All Actions', true),
          _buildFilterChip('Schema Changes', false),
          _buildFilterChip('Auth Events', false),
          _buildFilterChip('Storage', false),
          _buildFilterChip('Database', false),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (_) {},
        backgroundColor: AppColors.bgSubtle,
        selectedColor: AppColors.supaGreen.withOpacity(0.2),
        labelStyle: TextStyle(
          color: isSelected ? AppColors.supaGreen : AppColors.textPrimary,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide.none),
      ),
    );
  }

  Widget _buildLogsList(BuildContext context) {
    // Mock audit logs
    final logs = [
      {'user': 'Admin (You)', 'action': 'updated', 'target': 'Table "users"', 'time': '2m ago', 'icon': Icons.edit_outlined},
      {'user': 'System', 'action': 'backup', 'target': 'Daily Postgres snapshot', 'time': '4h ago', 'icon': Icons.backup_outlined},
      {'user': 'Admin (You)', 'action': 'deployed', 'target': 'Edge Function "payment-hook"', 'time': '6h ago', 'icon': Icons.bolt},
      {'user': 'Support Manager', 'action': 'created', 'target': 'RLS Policy for "orders"', 'time': '1d ago', 'icon': Icons.security_outlined},
      {'user': 'Admin (You)', 'action': 'invited', 'target': 'dev@example.com', 'time': '2d ago', 'icon': Icons.person_add_outlined},
    ];

    return Column(
      children: logs.map((log) => _buildLogItem(context, log)).toList(),
    );
  }

  Widget _buildLogItem(BuildContext context, Map<String, dynamic> log) {
    return GestureDetector(
      onLongPress: () {
        Clipboard.setData(ClipboardData(text: '${log['user']} ${log['action']} ${log['target']}'));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Log copied to clipboard')));
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: SupaCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.bgOverlay,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(log['icon'] as IconData, size: 18, color: AppColors.textMuted),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13, color: AppColors.textPrimary, fontFamily: 'Inter'),
                        children: [
                          TextSpan(text: log['user'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                          const TextSpan(text: ' '),
                          TextSpan(text: log['action'] as String),
                          const TextSpan(text: ' '),
                          TextSpan(text: log['target'] as String, style: TextStyle(color: AppColors.supaGreen)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(log['time'] as String, style: TextStyle(fontSize: 11, color: AppColors.textMuted)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, size: 16, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}

