import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class SupaTextField extends StatefulWidget {
  final String label;
  final String placeholder;
  final TextEditingController? controller;
  final bool isPassword;
  final bool isCode;
  final int maxLines;
  final IconData? prefixIcon;

  const SupaTextField({
    super.key,
    required this.label,
    this.placeholder = '',
    this.controller,
    this.isPassword = false,
    this.isCode = false,
    this.maxLines = 1,
    this.prefixIcon,
  });

  @override
  State<SupaTextField> createState() => _SupaTextFieldState();
}

class _SupaTextFieldState extends State<SupaTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: widget.controller,
          obscureText: widget.isPassword ? _obscureText : false,
          maxLines: widget.isPassword ? 1 : widget.maxLines,
          style: widget.isCode
              ? AppTheme.codeStyle.copyWith(fontSize: 15)
              : null,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            prefixIcon: widget.prefixIcon != null ? Icon(widget.prefixIcon, size: 20, color: AppColors.textMuted) : null,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textMuted,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureText = !_obscureText;
                      });
                    },
                  )
                : null,
          ),
        ),
      ],
    );
  }
}

