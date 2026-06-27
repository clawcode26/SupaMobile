import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../storage/secure_storage_service.dart';
import '../services/security_service.dart';

final securityServiceProvider = Provider<SecurityService>((ref) => SecurityService());

final biometricsEnabledProvider = FutureProvider<bool>((ref) async {
  final storage = SecureStorageService();
  return await storage.isBiometricsEnabled();
});

class SecurityActions {
  final Ref ref;
  SecurityActions(this.ref);

  Future<void> toggleBiometrics(bool enabled) async {
    final storage = SecureStorageService();
    final security = ref.read(securityServiceProvider);

    if (enabled) {
      final success = await security.authenticate(
        message: 'Authenticate to enable biometric protection'
      );
      if (!success) return;
    }

    await storage.setBiometricsEnabled(enabled);
    ref.invalidate(biometricsEnabledProvider);
  }

  Future<bool> verify() async {
    final enabled = ref.read(biometricsEnabledProvider).asData?.value ?? false;
    if (!enabled) return true;
    
    final security = ref.read(securityServiceProvider);
    return await security.authenticate(
      message: 'Authenticate to perform this action'
    );
  }
}

final securityProvider = Provider((ref) => SecurityActions(ref));

