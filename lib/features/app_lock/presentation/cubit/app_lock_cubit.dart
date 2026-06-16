import 'package:clinico/core/security/app_lock_vault.dart';
import 'package:clinico/core/security/biometric_auth_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'app_lock_state.dart';

class AppLockCubit extends Cubit<AppLockState> {
  AppLockCubit({
    required AppLockVault vault,
    required BiometricAuthService biometricService,
  })  : _vault = vault,
        _biometricService = biometricService,
        super(AppLockInitial());

  final AppLockVault _vault;
  final BiometricAuthService _biometricService;

  Future<void> startup() async {
    emit(AppLockLoading());

    final seen = await _vault.isUserSeen();
    final enabled = await _vault.isBiometricEnabled();

    if (!seen) {
      emit(AppLockNeedEnable());
      return;
    }

    if (!enabled) {
      emit(AppLockUnlocked());
      return;
    }

    await unlock();
  }

  Future<void> enableBiometric() async {
    emit(AppLockLoading());

    final supported = await _biometricService.isSupported();
    if (!supported) {
      emit(AppLockUnavailable('Biometric is not available on this device'));
      return;
    }

    final result = await _biometricService.authenticate();

    switch (result) {
      case BiometricResult.success:
        await _vault.setUserSeen(true);
        await _vault.setBiometricEnabled(true);
        emit(AppLockUnlocked());
        break;

      case BiometricResult.unavailable:
        emit(AppLockUnavailable('No biometric hardware or no biometrics enrolled'));
        break;

      case BiometricResult.lockedOut:
        emit(AppLockLocked(message: 'Biometric is temporarily locked'));
        break;

      case BiometricResult.canceled:
        emit(AppLockNeedEnable());
        break;

      case BiometricResult.failed:
        emit(AppLockNeedEnable());
        break;
    }
  }

  Future<void> skipBiometric() async {
    await _vault.setUserSeen(true);
    await _vault.setBiometricEnabled(false);
    emit(AppLockUnlocked());
  }

  Future<void> unlock() async {
    emit(AppLockLoading());

    final result = await _biometricService.authenticate();

    switch (result) {
      case BiometricResult.success:
        emit(AppLockUnlocked());
        break;

      case BiometricResult.unavailable:
        emit(AppLockUnavailable('Biometric unavailable on this device'));
        break;

      case BiometricResult.lockedOut:
        emit(AppLockLocked(message: 'Biometric locked. Try device passcode'));
        break;

      case BiometricResult.canceled:
        emit(AppLockLocked(message: 'Authentication canceled'));
        break;

      case BiometricResult.failed:
        emit(AppLockLocked(message: 'Authentication failed'));
        break;
    }
  }

  Future<void> disableBiometric() async {
    await _vault.setBiometricEnabled(false);
    emit(AppLockUnlocked());
  }

  Future<void> logoutLikeReset() async {
    await _vault.clear();
    emit(AppLockNeedEnable());
  }
}