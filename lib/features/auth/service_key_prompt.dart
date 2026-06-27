import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/supa_text_field.dart';
import '../../widgets/supa_button.dart';
import '../../core/providers/core_providers.dart';

class ServiceKeyPrompt extends ConsumerStatefulWidget {
  final String projectRef;
  const ServiceKeyPrompt({super.key, required this.projectRef});

  @override
  ConsumerState<ServiceKeyPrompt> createState() => _ServiceKeyPromptState();
}

class _ServiceKeyPromptState extends ConsumerState<ServiceKeyPrompt> {
  final _keyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _keyController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    final key = _keyController.text.trim();
    if (key.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref
          .read(serviceRoleKeyActionProvider(widget.projectRef))
          .setKey(key);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save service key')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 24,
        right: 24,
        top: 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enter Service Role Key',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The service_role key is required to manage Auth users and Storage buckets.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          SupaTextField(
            label: 'Service Role Key',
            placeholder: 'secret_...',
            controller: _keyController,
            isPassword: true,
            isCode: true,
          ),
          const SizedBox(height: 32),
          SupaButton(
            text: _isLoading ? 'Saving...' : 'Explore Project Data',
            isLoading: _isLoading,
            onPressed: _handleSave,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

void showServiceKeyPrompt(BuildContext context, String projectRef) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgOverlay,
    builder: (modalContext) => ServiceKeyPrompt(projectRef: projectRef),
  );
}

