import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// The pattern used throughout this project: Provider of ValueNotifier
// This ensures maximum compatibility and avoids "Type Not Found" errors in Riverpod 3.x
final profileTableSelectorProvider = Provider.family<ValueNotifier<String?>, String>((ref, projectRef) {
  return ValueNotifier<String?>(null);
});
