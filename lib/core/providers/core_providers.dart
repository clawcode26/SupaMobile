import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import '../models/project.dart';
import 'analytics_providers.dart';

final secureStorageProvider = Provider<SecureStorageService>((ref) => SecureStorageService());

final patProvider = FutureProvider<String?>((ref) async {
  final storage = ref.watch(secureStorageProvider);
  return await storage.getPAT();
});

class PatActions {
  final Ref ref;
  PatActions(this.ref);

  Future<void> setPat(String pat) async {
    final storage = ref.read(secureStorageProvider);
    await storage.savePAT(pat);
    ref.invalidate(patProvider);
  }

  Future<void> clearPat() async {
    final storage = ref.read(secureStorageProvider);
    await storage.deletePAT();
    ref.invalidate(patProvider);
  }
}

final patActionsProvider = Provider((ref) => PatActions(ref));

// Nuclear option: Using basic ValueNotifier to guarantee stability on V2443.
// This is pure Flutter and will NOT fail due to Riverpod version mismatches.
final activeProjectProvider = Provider<ValueNotifier<Project?>>((ref) => ValueNotifier<Project?>(null));

final serviceRoleKeyProvider = FutureProvider.family<String?, String>((ref, projectRef) async {
  final storage = ref.watch(secureStorageProvider);
  String? key = await storage.getServiceKey(projectRef);
  if (key == null || key.isEmpty) {
    try {
      final api = ref.read(managementApiProvider);
      final keys = await api.getApiKeys(projectRef);
      if (keys['service_role'] != null && keys['service_role']!.isNotEmpty) {
        await storage.saveServiceKey(projectRef, keys['service_role']!);
        key = keys['service_role'];
      }
      if (keys['anon'] != null && keys['anon']!.isNotEmpty) {
        await storage.saveAnonKey(projectRef, keys['anon']!);
      }
    } catch (_) {}
  }
  return key;
});

class ServiceKeyActions {
  final Ref ref;
  final String projectRef;
  ServiceKeyActions(this.ref, this.projectRef);

  Future<void> setKey(String key) async {
    final storage = ref.read(secureStorageProvider);
    await storage.saveServiceKey(projectRef, key);
    ref.invalidate(serviceRoleKeyProvider(projectRef));
  }
}

final serviceRoleKeyActionProvider = Provider.family<ServiceKeyActions, String>((ref, projectRef) {
  return ServiceKeyActions(ref, projectRef);
});

// Anon Key (Per Project)
final anonKeyProvider = FutureProvider.family<String?, String>((ref, projectRef) async {
  final storage = ref.watch(secureStorageProvider);
  String? key = await storage.getAnonKey(projectRef);
  if (key == null || key.isEmpty) {
    try {
      final api = ref.read(managementApiProvider);
      final keys = await api.getApiKeys(projectRef);
      if (keys['anon'] != null && keys['anon']!.isNotEmpty) {
        await storage.saveAnonKey(projectRef, keys['anon']!);
        key = keys['anon'];
      }
      if (keys['service_role'] != null && keys['service_role']!.isNotEmpty) {
        await storage.saveServiceKey(projectRef, keys['service_role']!);
      }
    } catch (_) {}
  }
  return key;
});

class AnonKeyActions {
  final Ref ref;
  final String projectRef;
  AnonKeyActions(this.ref, this.projectRef);

  Future<void> setKey(String key) async {
    final storage = ref.read(secureStorageProvider);
    await storage.saveAnonKey(projectRef, key);
    ref.invalidate(anonKeyProvider(projectRef));
  }
}

final anonKeyActionProvider = Provider.family<AnonKeyActions, String>((ref, projectRef) {
  return AnonKeyActions(ref, projectRef);
});

// Added for manual theme override support
final themeModeProvider = Provider<ValueNotifier<ThemeMode>>((ref) => ValueNotifier<ThemeMode>(ThemeMode.system));

