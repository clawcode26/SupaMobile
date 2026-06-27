import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/supa_card.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import '../../widgets/supa_button.dart';
import 'infrastructure_provider.dart';

class InfrastructureScreen extends ConsumerWidget {
  final String projectRef;
  const InfrastructureScreen({super.key, required this.projectRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsState = ref.watch(infrastructureMetricsProvider(projectRef));

    return Scaffold(
      appBar: const SupaAppBarSwitcher(title: 'Infrastructure'),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(infrastructureMetricsProvider(projectRef).future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: metricsState.when(
              loading: () => const Center(child: Padding(
                padding: EdgeInsets.all(40.0),
                child: CircularProgressIndicator(color: AppColors.supaGreen),
              )),
              error: (e, s) => Center(child: Text('Error: $e')),
              data: (metrics) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('Compute Saturation'),
                  SupaCard(
                    child: Column(
                      children: [
                        _buildMetricRow('CPU Usage', metrics['cpu_usage'], _getStatusLabel(metrics['cpu_usage'])),
                        Divider(color: AppColors.borderDefault, height: 24),
                        _buildMetricRow('RAM Utilization', metrics['ram_usage'], _getStatusLabel(metrics['ram_usage'])),
                        Divider(color: AppColors.borderDefault, height: 24),
                        _buildMetricRow('Disk I/O', metrics['disk_io'], _getStatusLabel(metrics['disk_io'])),
                        Divider(color: AppColors.borderDefault, height: 24),
                        _buildMetricRow('Active Connections', metrics['connections_progress'], '${metrics['connections']} Active'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildSectionHeader('Optimization Advisors'),
                  if (metrics['rls_issues'] > 0)
                    _buildAdvisorItem(
                      icon: Icons.security_outlined,
                      title: 'Enable Row Level Security',
                      description: '${metrics['rls_issues']} tables in your public schema do not have RLS enabled. This could lead to unauthorized data exposure.',
                      severity: 'CRITICAL',
                      action: 'View Tables',
                    ),
                  const SizedBox(height: 16),
                  if (metrics['total_indexes'] < 5)
                    _buildAdvisorItem(
                      icon: Icons.speed_outlined,
                      title: 'Add Indexes for Performance',
                      description: 'Low index count detected. Queries may be slow on larger tables without proper indexing.',
                      severity: 'MEDIUM',
                      action: 'Optimize',
                    ),
                  const SizedBox(height: 16),
                  if (metrics['vacuum_needed'] > 0)
                    _buildAdvisorItem(
                      icon: Icons.storage_outlined,
                      title: 'Database Bloat Detected',
                      description: '${metrics['vacuum_needed']} tables have significant updates/inserts without recent vacuuming.',
                      severity: 'LOW',
                      action: 'Run Vacuum',
                    ),
                  
                  if (metrics['rls_issues'] == 0 && metrics['vacuum_needed'] == 0)
                    SupaCard(
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle_rounded, color: AppColors.supaGreen),
                          const SizedBox(width: 12),
                          const Text('No optimization issues detected.', style: TextStyle(fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getStatusLabel(double value) {
    if (value > 0.8) return 'Critical';
    if (value > 0.6) return 'Elevated';
    return 'Optimal';
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted, letterSpacing: 1.2),
      ),
    );
  }

  Widget _buildMetricRow(String label, double value, String status) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
            Text(status, style: TextStyle(fontSize: 11, color: value > 0.7 ? Colors.orange : AppColors.supaGreen, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: AppColors.borderDefault,
            color: value > 0.7 ? Colors.orange : AppColors.supaGreen,
            minHeight: 6,
          ),
        ),
      ],
    );
  }

  Widget _buildAdvisorItem({
    required IconData icon,
    required String title,
    required String description,
    required String severity,
    required String action,
  }) {
    Color severityColor;
    switch (severity) {
      case 'CRITICAL': severityColor = Colors.redAccent; break;
      case 'MEDIUM': severityColor = Colors.orange; break;
      default: severityColor = AppColors.supaGreen;
    }

    return SupaCard(
      borderColor: severityColor.withOpacity(0.3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: severityColor, size: 20),
              const SizedBox(width: 12),
              Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(color: severityColor.withOpacity(0.1), borderRadius: BorderRadius.circular(4)),
                child: Text(severity, style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: severityColor)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(description, style: TextStyle(fontSize: 12, color: AppColors.textSecondary, height: 1.4)),
          const SizedBox(height: 16),
          SupaButton(
            text: action,
            color: severityColor,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

