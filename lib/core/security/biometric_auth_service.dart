import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

enum BiometricResult {
  success,
  unavailable,
  failed,
  canceled,
  lockedOut,
}

class BiometricAuthService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isSupported() async {
    final canCheckBiometrics = await _auth.canCheckBiometrics;
    final isDeviceSupported = await _auth.isDeviceSupported();
    return canCheckBiometrics || isDeviceSupported;
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  Future<BiometricResult> authenticate() async {
    try {
      final supported = await isSupported();
      if (!supported) return BiometricResult.unavailable;

      final didAuthenticate = await _auth.authenticate(
        localizedReason: 'Authenticate to unlock the app',
        authMessages: const [
          AndroidAuthMessages(
            signInTitle: 'Authentication required',
            cancelButton: 'Cancel',
          ),
          IOSAuthMessages(
            cancelButton: 'Cancel',
          ),
        ],
        options: const AuthenticationOptions(
          biometricOnly: false,
          stickyAuth: true,
        ),
      );

      return didAuthenticate
          ? BiometricResult.success
          : BiometricResult.failed;
    } on PlatformException catch (e) {
      final code = e.code.toLowerCase();

      if (code.contains('nobiometrichardware') ||
          code.contains('notavailable') ||
          code.contains('passcode_not_set') ||
          code.contains('notenrolled')) {
        return BiometricResult.unavailable;
      }

      if (code.contains('lockedout') || code.contains('permanently_locked_out')) {
        return BiometricResult.lockedOut;
      }

      if (code.contains('canceled') || code.contains('system_cancel')) {
        return BiometricResult.canceled;
      }

      return BiometricResult.failed;
    } catch (_) {
      return BiometricResult.failed;
    }
  }
}