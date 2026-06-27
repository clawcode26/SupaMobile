import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/providers/core_providers.dart';
import '../auth/service_key_prompt.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import 'auth_users_provider.dart';
import '../../widgets/supa_skeleton.dart';
import '../../widgets/supa_card.dart';
import '../../widgets/supa_badge.dart';
import '../../widgets/supa_button.dart';
import '../../widgets/supa_sub_nav.dart';
import 'package:flutter/services.dart';
import '../tables/tables_provider.dart';
import 'profile_table_provider.dart';

class AuthUsersScreen extends ConsumerWidget {
  final String projectRef;
  const AuthUsersScreen({super.key, required this.projectRef});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceKeyState = ref.watch(serviceRoleKeyProvider(projectRef));

    return serviceKeyState.when(
      data: (key) {
        if (key == null) return _buildKeyRequired(context);
        return _buildUserList(context, ref);
      },
      loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, s) => Scaffold(body: Center(child: Text('Error: $e'))),
    );
  }

  Widget _buildKeyRequired(BuildContext context) {
    return Scaffold(
      appBar: SupaAppBarSwitcher(
        title: 'Users',
        bottom: SupaSubNav(
          currentRoute: '/projects/$projectRef/auth',
          items: [
            SubNavItem(label: 'Users', route: '/projects/$projectRef/auth'),
            SubNavItem(label: 'Statistics', route: '/projects/$projectRef/auth/stats'),
            SubNavItem(label: 'Policies', route: '/projects/$projectRef/auth/policies'),
            SubNavItem(label: 'Providers', route: '/projects/$projectRef/auth/providers'),
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.lock_outline, size: 64, color: AppColors.textMuted),
              const SizedBox(height: 24),
              Text(
                'Service Role Key Required',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                'To manage and view users, you must provide your project\'s service_role secret key.',
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

  Widget _buildUserList(BuildContext context, WidgetRef ref) {
    final usersState = ref.watch(authUsersProvider(projectRef));
    final tablesState = ref.watch(tableListProvider(projectRef));
    final selectedTableNotifier = ref.watch(profileTableSelectorProvider(projectRef));

    return Scaffold(
      appBar: SupaAppBarSwitcher(
        title: 'Users',
        bottom: SupaSubNav(
          currentRoute: '/projects/$projectRef/auth',
          items: [
            SubNavItem(label: 'Users', route: '/projects/$projectRef/auth'),
            SubNavItem(label: 'Statistics', route: '/projects/$projectRef/auth/stats'),
            SubNavItem(label: 'Policies', route: '/projects/$projectRef/auth/policies'),
            SubNavItem(label: 'Providers', route: '/projects/$projectRef/auth/providers'),
          ],
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(authUsersProvider(projectRef).future),
        child: usersState.when(
          data: (users) {
            return ValueListenableBuilder<String?>(
              valueListenable: selectedTableNotifier,
              builder: (context, selectedTable, _) {
                return ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
                  itemCount: users.length + 1,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: SupaCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Icon(Icons.table_chart_outlined, color: AppColors.supaGreen, size: 20),
                                  const SizedBox(width: 8),
                                  const Text('Link Profile Table', style: TextStyle(fontWeight: FontWeight.bold)),
                                ],
                              ),
                              const SizedBox(height: 12),
                              tablesState.when(
                                data: (tables) => Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  decoration: BoxDecoration(
                                    color: AppColors.bgBase,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.borderDefault),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: selectedTable,
                                      isExpanded: true,
                                      hint: const Text('Select a table to link profiles...'),
                                      dropdownColor: AppColors.bgOverlay,
                                      items: tables.map((t) => DropdownMenuItem(
                                        value: t['table_name'] as String,
                                        child: Text(t['table_name'] as String),
                                      )).toList(),
                                      onChanged: (val) => selectedTableNotifier.value = val,
                                    ),
                                  ),
                                ),
                                loading: () => const LinearProgressIndicator(),
                                error: (e, s) => Text('Error: $e'),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    
                    final user = users[index - 1];
                    final email = user['email'] ?? 'No email';
                    final lastSignIn = SupaDateParser.format(user['last_sign_in_at'], fallback: 'Never');

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: SupaCard(
                        onTap: () => _showUserDetails(context, ref, user),
                        onLongPress: () {
                          Clipboard.setData(ClipboardData(text: email));
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Email copied to clipboard')));
                        },
                        child: Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: AppColors.supaGreenGlow,
                              child: Text(
                                email[0].toUpperCase(),
                                style: TextStyle(color: AppColors.supaGreen),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(email, style: const TextStyle(fontWeight: FontWeight.bold)),
                                  Text(
                                    'Last sign in: $lastSignIn',
                                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                            SupaBadge(
                              text: user['confirmed_at'] != null ? 'Confirmed' : 'Unconfirmed',
                              color: user['confirmed_at'] != null ? AppColors.statusActive : AppColors.statusPaused,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
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

  void _showUserDetails(BuildContext context, WidgetRef ref, dynamic user) {
    final selectedTable = ref.read(profileTableSelectorProvider(projectRef)).value;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgOverlay,
      isScrollControlled: true,
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('User Details', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 24),
              _buildDetailRow('Email', user['email'] ?? 'N/A'),
              _buildDetailRow('User ID', user['id'] ?? 'N/A', isCode: true),
              _buildDetailRow('Created At', SupaDateParser.format(user['created_at'])),
              _buildDetailRow('Last Sign In', SupaDateParser.format(user['last_sign_in_at'], fallback: 'Never')),
              
              if (selectedTable != null) ...[
                const SizedBox(height: 24),
                const Divider(),
                const SizedBox(height: 24),
                Row(
                  children: [
                    const Icon(Icons.person_pin_rounded, color: AppColors.supaGreen, size: 20),
                    const SizedBox(width: 8),
                    Text('PROFILE DATA ($selectedTable)', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                  ],
                ),
                const SizedBox(height: 16),
                Consumer(
                  builder: (context, ref, _) {
                    final dataState = ref.watch(tableDataProvider((projectRef: projectRef, tableName: selectedTable)));
                    return dataState.when(
                      data: (rows) {
                        // Try to find the row matching this user ID
                        final profile = rows.firstWhere(
                          (r) => r['id'] == user['id'] || r['user_id'] == user['id'],
                          orElse: () => null,
                        );

                        if (profile == null) {
                          return const Text('No profile record found matching this User ID.', style: TextStyle(color: Colors.orangeAccent, fontSize: 12));
                        }

                        // We can also show the full record in a sortable way if we want, 
                        // but for a single user it's just a JSON block.
                        // However, if the user meant the GENERAL table viewer (which I already fixed), 
                        // I should also check if the SQL results table needs it.

                        return Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppColors.bgBase,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.borderDefault),
                          ),
                          child: Text(
                            JsonEncoder.withIndent('  ').convert(profile),
                            style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: AppColors.textCode),
                          ),
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (e, s) => Text('Error: $e'),
                    );
                  },
                ),
              ],
              
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 24),
              const Text('MetaData', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  JsonEncoder.withIndent('  ').convert(user['user_metadata'] ?? {}),
                  style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, color: AppColors.textCode),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isCode = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          Text(
            value,
            style: TextStyle(
              fontFamily: isCode ? 'JetBrains Mono' : null,
              color: isCode ? AppColors.textCode : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

