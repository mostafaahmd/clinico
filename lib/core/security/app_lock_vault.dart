import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AppLockVault {
  static const _biometricEnabledKey = 'biometric_enabled';
  static const _userSeenKey = 'user_seen';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<void> setBiometricEnabled(bool value) async {
    await _storage.write(
      key: _biometricEnabledKey,
      value: value.toString(),
    );
  }

  Future<bool> isBiometricEnabled() async {
    final value = await _storage.read(key: _biometricEnabledKey);
    return value == 'true';
  }

  Future<void> setUserSeen(bool value) async {
    await _storage.write(
      key: _userSeenKey,
      value: value.toString(),
    );
  }

  Future<bool> isUserSeen() async {
    final value = await _storage.read(key: _userSeenKey);
    return value == 'true';
  }

  Future<void> clear() async {
    await _storage.deleteAll();
  }
}