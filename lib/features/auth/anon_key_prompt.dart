import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/supa_text_field.dart';
import '../../widgets/supa_button.dart';
import '../../core/providers/core_providers.dart';

class AnonKeyPrompt extends ConsumerStatefulWidget {
  final String projectRef;
  const AnonKeyPrompt({super.key, required this.projectRef});

  @override
  ConsumerState<AnonKeyPrompt> createState() => _AnonKeyPromptState();
}

class _AnonKeyPromptState extends ConsumerState<AnonKeyPrompt> {
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
          .read(anonKeyActionProvider(widget.projectRef))
          .setKey(key);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save anon key')),
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
                'Enter Anon Key',
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
            'The anon key is required for public data requests and standard project communication.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 24),
          SupaTextField(
            label: 'Anon Key',
            placeholder: 'eyJhbG...',
            controller: _keyController,
            isPassword: true,
            isCode: true,
          ),
          const SizedBox(height: 32),
          SupaButton(
            text: _isLoading ? 'Saving...' : 'Update Key',
            isLoading: _isLoading,
            onPressed: _handleSave,
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }
}

void showAnonKeyPrompt(BuildContext context, String projectRef) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.bgOverlay,
    builder: (modalContext) => AnonKeyPrompt(projectRef: projectRef),
  );
}
