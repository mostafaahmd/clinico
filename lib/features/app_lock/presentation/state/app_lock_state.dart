// lib/features/app_lock/presentation/state/app_lock_state.dart

sealed class AppLockState {
  const AppLockState();
}

final class AppLockInitial extends AppLockState {
  const AppLockInitial();
}

final class AppLockNeedEnable extends AppLockState {
  const AppLockNeedEnable();
}

final class AppLockUnlocked extends AppLockState {
  const AppLockUnlocked();
}

final class AppLockLocked extends AppLockState {
  const AppLockLocked({
    this.message,
  });

  final String? message;
}

final class AppLockUnavailable extends AppLockState {
  const AppLockUnavailable(this.message);

  final String message;
}