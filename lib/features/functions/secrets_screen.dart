import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/supa_app_bar_switcher.dart';
import '../../widgets/supa_card.dart';
import '../../widgets/supa_sub_nav.dart';
import '../../widgets/supa_button.dart';
import '../../widgets/supa_text_field.dart';

class SecretsScreen extends ConsumerStatefulWidget {
  final String projectRef;
  const SecretsScreen({super.key, required this.projectRef});

  @override
  ConsumerState<SecretsScreen> createState() => _SecretsScreenState();
}

class _SecretsScreenState extends ConsumerState<SecretsScreen> {
  final List<Map<String, String>> _secrets = [
    {'name': 'STRIPE_SECRET_KEY', 'value': 'sk_test_••••••••'},
    {'name': 'CUSTOM_API_URL', 'value': 'https://api.example.com'},
    {'name': 'SENDGRID_API_KEY', 'value': 'SG.••••••••'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: SupaAppBarSwitcher(
        title: 'Edge Functions',
        bottom: SupaSubNav(
          currentRoute: '/projects/${widget.projectRef}/functions/secrets',
          items: [
            SubNavItem(label: 'Functions', route: '/projects/${widget.projectRef}/functions'),
            SubNavItem(label: 'Secrets', route: '/projects/${widget.projectRef}/functions/secrets'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Project Secrets', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Manage environment variables for your functions.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                    ],
                  ),
                ),
                SupaButton(
                  text: 'Add Secret',
                  onPressed: () => _showAddSecretDialog(),
                  width: 120,
                ),
              ],
            ),
            const SizedBox(height: 32),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _secrets.length,
              itemBuilder: (context, index) {
                final secret = _secrets[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: SupaCard(
                    child: Row(
                      children: [
                        Icon(Icons.vpn_key_outlined, color: AppColors.textMuted, size: 20),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(secret['name']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, fontFamily: 'JetBrains Mono')),
                              const SizedBox(height: 4),
                              Text(secret['value']!, style: TextStyle(color: AppColors.textMuted, fontSize: 12, fontFamily: 'JetBrains Mono')),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 20),
                          onPressed: () {
                            setState(() => _secrets.removeAt(index));
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddSecretDialog() {
    final nameController = TextEditingController();
    final valueController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgOverlay,
        title: const Text('Add New Secret', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SupaTextField(label: 'Name', placeholder: 'MY_SECRET_KEY', controller: nameController),
            const SizedBox(height: 16),
            SupaTextField(label: 'Value', placeholder: 'Value', controller: valueController),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel', style: TextStyle(color: Colors.white70))),
          TextButton(
            onPressed: () {
              setState(() {
                _secrets.add({'name': nameController.text.toUpperCase(), 'value': valueController.text});
              });
              Navigator.pop(context);
            },
            child: Text('Add Secret', style: TextStyle(color: AppColors.supaGreen, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

