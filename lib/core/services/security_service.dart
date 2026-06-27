import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

class SecurityService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canCheckBiometrics() async {
    return await _auth.canCheckBiometrics || await _auth.isDeviceSupported();
  }

  Future<bool> authenticate({String message = 'Authenticate to continue'}) async {
    try {
      if (!await canCheckBiometrics()) return true; // Fallback if no biometrics supported

      return await _auth.authenticate(
        localizedReason: message,
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Biometric Login',
            cancelButton: 'No thanks',
          ),
          IOSAuthMessages(
            cancelButton: 'No thanks',
          ),
        ],
      );
    } catch (e) {
      return false;
    }
  }
}

