abstract class AppLockState {}

class AppLockInitial extends AppLockState {}

class AppLockLoading extends AppLockState {}

class AppLockNeedEnable extends AppLockState {}

class AppLockLocked extends AppLockState {
  final String? message;
  AppLockLocked({this.message});
}

class AppLockUnlocked extends AppLockState {}

class AppLockUnavailable extends AppLockState {
  final String message;
  AppLockUnavailable(this.message);
}