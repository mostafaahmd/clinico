import 'package:clinico/core/security/app_lock_vault.dart';
import 'package:clinico/core/security/biometric_auth_service.dart';
import 'package:clinico/core/services/prefs_service.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final uidProvider = Provider<String?>((ref) {
  return ref.watch(supabaseProvider).auth.currentUser?.id;
});

final prefsServiceProvider = Provider<PrefsService>((ref) {
  return PrefsService();
});

final appLockVaultProvider = Provider<AppLockVault>((ref) {
  return AppLockVault();
});

final biometricAuthServiceProvider = Provider<BiometricAuthService>((ref) {
  return BiometricAuthService();
});

class AppLockSessionController extends Notifier<bool> {
  @override
  bool build() {
    return false;
  }

  void markUnlocked() {
    state = true;
  }

  void reset() {
    state = false;
  }
}

final appLockSessionProvider =
    NotifierProvider<AppLockSessionController, bool>(
  AppLockSessionController.new,
);