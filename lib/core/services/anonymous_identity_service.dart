import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

class AnonymousIdentity {
  final String id;
  final DateTime createdAt;

  AnonymousIdentity({required this.id, required this.createdAt});
}

class AnonymousIdentityNotifier extends AsyncNotifier<AnonymousIdentity> {
  static const _key = 'supamobile_anon_id';
  static const _createdKey = 'supamobile_created_at';
  final _storage = const FlutterSecureStorage();

  @override
  FutureOr<AnonymousIdentity> build() async {
    String? id = await _storage.read(key: _key);
    String? createdAtStr = await _storage.read(key: _createdKey);
    
    if (id == null) {
      id = 'supporter_${const Uuid().v4().substring(0, 8)}';
      await _storage.write(key: _key, value: id);
    }

    DateTime createdAt;
    if (createdAtStr == null) {
      createdAt = DateTime.now();
      await _storage.write(key: _createdKey, value: createdAt.toIso8601String());
    } else {
      createdAt = DateTime.parse(createdAtStr);
    }

    return AnonymousIdentity(id: id, createdAt: createdAt);
  }

  Future<void> resetIdentity() async {
    state = const AsyncValue.loading();
    await _storage.delete(key: _key);
    ref.invalidateSelf();
  }
}

final anonymousIdentityProvider = AsyncNotifierProvider<AnonymousIdentityNotifier, AnonymousIdentity>(() {
  return AnonymousIdentityNotifier();
});
