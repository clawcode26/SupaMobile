import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Using StateProvider-alternative (ValueNotifier) for maximum stability on current environment
final appUnlockedProvider = Provider<ValueNotifier<bool>>((ref) => ValueNotifier<bool>(false));
