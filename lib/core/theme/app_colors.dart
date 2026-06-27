import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Constant across themes)
  static const Color supaGreen = Color(0xFF3ECF8E);
  static const Color supaGreenDark = Color(0xFF34B27B);
  static const Color supaGreenGlow = Color(0x3034B27B);
  static const Color supaWarning = Color(0xFFF5A623);
  static const Color colorError = Color(0xFFE55353);

  // Status colors
  static const Color colorSuccess = Color(0xFF3ECF8E);
  static const Color colorWarning = Color(0xFFF5A623);
  static const Color colorInfo = Color(0xFF3B82F6);
  
  // Backward compatibility for status colors
  static Color get statusActive => supaGreen;
  static Color get statusPaused => colorWarning;
  static Color get statusInactive => textMuted;

  // Helper to get true platform brightness (with manual override support)
  static Brightness? _overrideBrightness;
  static set brightness(Brightness? b) => _overrideBrightness = b;

  static bool get _isDark {
    if (_overrideBrightness != null) return _overrideBrightness == Brightness.dark;
    // Fallback to platform if no manual override
    try {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    } catch (_) {
      return true; // Default to dark for premium look if dispatcher is not ready
    }
  }

  // Backgrounds
  static Color get bgBase => _isDark ? const Color(0xFF0F0F0F) : const Color(0xFFF8F9FA);
  static Color get bgSurface => _isDark ? const Color(0xFF1C1C1C) : Colors.white;
  static Color get bgOverlay => _isDark ? const Color(0xFF262626) : const Color(0xFFF1F3F5);
  static Color get bgSubtle => _isDark ? const Color(0xFF171717) : const Color(0xFFF1F3F5);

  // Borders
  static Color get borderDefault => _isDark ? const Color(0xFF2E2E2E) : const Color(0xFFE9ECEF);
  static Color get borderStrong => _isDark ? const Color(0xFF3E3E3E) : const Color(0xFFDEE2E6);

  // Text
  static Color get textPrimary => _isDark ? const Color(0xFFEDEDED) : const Color(0xFF1C1C1C);
  static Color get textSecondary => _isDark ? const Color(0xFF9A9A9A) : const Color(0xFF495057);
  static Color get textMuted => _isDark ? const Color(0xFF636363) : const Color(0xFFADB5BD);

  static Color get textCode => supaGreen;
}

