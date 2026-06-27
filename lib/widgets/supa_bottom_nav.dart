import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/theme/app_colors.dart';
import '../features/projects/projects_provider.dart';
import '../core/providers/core_providers.dart';
import '../core/providers/scaffold_key_provider.dart';
import 'supa_drawer.dart';

class SupaBottomNav extends ConsumerWidget {
  final Widget child;

  const SupaBottomNav({super.key, required this.child});

  int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.path;
    if (location.endsWith('/dashboard')) return 0;
    if (location.contains('/tables')) return 1;
    if (location.contains('/sql')) return 2;
    if (location.contains('/auth')) return 3;
    if (location.contains('/storage')) return 4;
    return 0;
  }

  void _onItemTapped(int index, BuildContext context, WidgetRef ref) {
    final activeProject = ref.read(activeProjectProvider).value;
    if (activeProject == null) return;
    
    final ref_str = activeProject.ref;
    
    switch (index) {
      case 0:
        context.go('/projects/$ref_str/dashboard');
        break;
      case 1:
        context.go('/projects/$ref_str/tables');
        break;
      case 2:
        context.go('/projects/$ref_str/sql');
        break;
      case 3:
        context.go('/projects/$ref_str/auth');
        break;
      case 4:
        context.go('/projects/$ref_str/storage');
        break;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = _calculateSelectedIndex(context);
    final scaffoldKey = ref.watch(rootScaffoldKeyProvider);
    final items = [
      {'icon': Icons.dashboard_rounded, 'label': 'Overview'},
      {'icon': Icons.table_rows_rounded, 'label': 'Tables'},
      {'icon': Icons.terminal_rounded, 'label': 'SQL'},
      {'icon': Icons.people_rounded, 'label': 'Auth'},
      {'icon': Icons.storage_rounded, 'label': 'Storage'},
    ];

    return Scaffold(
      key: scaffoldKey,
      drawer: const SupaDrawer(),
      extendBody: false, // Don't flow under the stuck nav
      body: child,
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bgSurface.withOpacity(0.95),
          border: Border.all(color: AppColors.borderDefault, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Container(
            height: 64,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  final isSelected = index == currentIndex;

                  return Expanded(
                    child: GestureDetector(
                      onTap: () => _onItemTapped(index, context, ref),
                      behavior: HitTestBehavior.opaque,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOutCubic,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              padding: EdgeInsets.symmetric(
                                horizontal: isSelected ? 16 : 0,
                                vertical: isSelected ? 4 : 0,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.supaGreen.withOpacity(0.15) : Colors.transparent,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Icon(
                                item['icon'] as IconData,
                                color: isSelected ? AppColors.supaGreen : AppColors.textMuted,
                                size: 20,
                              ),
                            ),
                            const SizedBox(height: 4),
                            AnimatedDefaultTextStyle(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              style: TextStyle(
                                fontSize: 9,
                                letterSpacing: -0.2,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected ? AppColors.supaGreen : AppColors.textMuted,
                              ),
                              child: Text(item['label'] as String),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

