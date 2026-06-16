// lib/features/app_lock/presentation/providers/app_lock_controller.dart

import 'package:clinico/core/providers/base_providers.dart';
import 'package:clinico/core/security/biometric_auth_service.dart';
import 'package:clinico/features/app_lock/presentation/cubit/app_lock_state.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLockControllerProvider =
    AsyncNotifierProvider<AppLockController, AppLockState>(
  AppLockController.new,
);

class AppLockController extends AsyncNotifier<AppLockState> {
  @override
  Future<AppLockState> build() async {
    return AppLockInitial();
  }

  Future<void> startup() async {
    state = const AsyncLoading();

    try {
      final vault = ref.read(appLockVaultProvider);

      final seen = await vault.isUserSeen();
      final enabled = await vault.isBiometricEnabled();

      if (!seen) {
        _lockSession();
        state = AsyncData(AppLockNeedEnable());
        return;
      }

      if (!enabled) {
        _unlockSession();
        state = AsyncData(AppLockUnlocked());
        return;
      }

      await unlock();
    } catch (error, stackTrace) {
      _lockSession();
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> enableBiometric() async {
    state = const AsyncLoading();

    try {
      final vault = ref.read(appLockVaultProvider);
      final biometricService = ref.read(biometricAuthServiceProvider);

      final supported = await biometricService.isSupported();

      if (!supported) {
        _lockSession();
        state = AsyncData(
          AppLockUnavailable('Biometric is not available on this device'),
        );
        return;
      }

      final result = await biometricService.authenticate();

      switch (result) {
        case BiometricResult.success:
          await vault.setUserSeen(true);
          await vault.setBiometricEnabled(true);

          _unlockSession();
          state = AsyncData(AppLockUnlocked());
          return;

        case BiometricResult.unavailable:
          _lockSession();
          state = AsyncData(
            AppLockUnavailable('No biometric hardware or no biometrics enrolled'),
          );
          return;

        case BiometricResult.lockedOut:
          _lockSession();
          state = AsyncData(
            AppLockLocked(message: 'Biometric is temporarily locked'),
          );
          return;

        case BiometricResult.canceled:
        case BiometricResult.failed:
          _lockSession();
          state = AsyncData(AppLockNeedEnable());
          return;
      }
    } catch (error, stackTrace) {
      _lockSession();
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> skipBiometric() async {
    state = const AsyncLoading();

    try {
      final vault = ref.read(appLockVaultProvider);

      await vault.setUserSeen(true);
      await vault.setBiometricEnabled(false);

      _unlockSession();
      state = AsyncData(AppLockUnlocked());
    } catch (error, stackTrace) {
      _lockSession();
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> unlock() async {
    state = const AsyncLoading();

    try {
      final biometricService = ref.read(biometricAuthServiceProvider);

      final result = await biometricService.authenticate();

      switch (result) {
        case BiometricResult.success:
          _unlockSession();
          state = AsyncData(AppLockUnlocked());
          return;

        case BiometricResult.unavailable:
          _lockSession();
          state = AsyncData(
            AppLockUnavailable('Biometric unavailable on this device'),
          );
          return;

        case BiometricResult.lockedOut:
          _lockSession();
          state = AsyncData(
            AppLockLocked(message: 'Biometric locked. Try device passcode'),
          );
          return;

        case BiometricResult.canceled:
          _lockSession();
          state = AsyncData(
            AppLockLocked(message: 'Authentication canceled'),
          );
          return;

        case BiometricResult.failed:
          _lockSession();
          state = AsyncData(
            AppLockLocked(message: 'Authentication failed'),
          );
          return;
      }
    } catch (error, stackTrace) {
      _lockSession();
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> disableBiometric() async {
    state = const AsyncLoading();

    try {
      final vault = ref.read(appLockVaultProvider);

      await vault.setBiometricEnabled(false);

      _unlockSession();
      state = AsyncData(AppLockUnlocked());
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
    }
  }

  Future<void> logoutLikeReset() async {
    state = const AsyncLoading();

    try {
      final vault = ref.read(appLockVaultProvider);

      await vault.clear();

      _lockSession();
      state = AsyncData(AppLockNeedEnable());
    } catch (error, stackTrace) {
      _lockSession();
      state = AsyncError(error, stackTrace);
    }
  }

  void _unlockSession() {
    ref.read(appLockSessionProvider.notifier).markUnlocked();
  }

  void _lockSession() {
    ref.read(appLockSessionProvider.notifier).reset();
  }
}