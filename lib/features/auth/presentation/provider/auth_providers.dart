import 'dart:async';

import 'package:clinico/core/providers/base_providers.dart';
import 'package:clinico/features/auth/data/domain/auth_repository.dart';
import 'package:clinico/features/auth/data/domain/registration_data.dart';
import 'package:clinico/features/auth/data/repo/auth_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final authRepoProvider = Provider<AuthRepository>((ref) {
  final supabase = ref.watch(supabaseProvider);

  return AuthRepositoryImpl(supabase);
});

final authStateChangesProvider = StreamProvider<AuthState>((ref) {
  final repository = ref.watch(authRepoProvider);

  return repository.onAuthStateChanged();
});

final authControllerProvider =
    AsyncNotifierProvider<AuthController, void>(
  AuthController.new,
);

final registerControllerProvider =
    AsyncNotifierProvider<RegisterController, void>(
  RegisterController.new,
);

final passwordResetControllerProvider =
    AsyncNotifierProvider<PasswordResetController, void>(
  PasswordResetController.new,
);

class AuthController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial idle state.
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepoProvider);

      await repository.signIn(
        email.trim(),
        password,
      );

      ref.read(appLockSessionProvider.notifier).markUnlocked();
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepoProvider);

      await repository.signOut();

      ref.read(appLockSessionProvider.notifier).reset();
    });
  }
}

class RegisterController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial idle state.
  }

  Future<void> register(RegistrationData data) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepoProvider);

      await repository.register(data);
    });
  }
}

class PasswordResetController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {
    // Initial idle state.
  }

  Future<void> sendResetOtp(String email) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepoProvider);

      await repository.sendResetOtp(email.trim());
    });
  }

  Future<void> verifyResetOtp({
    required String email,
    required String code,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepoProvider);

      await repository.verifyResetOtp(
        email.trim(),
        code.trim(),
      );
    });
  }

  Future<void> setNewPassword(String password) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepoProvider);

      await repository.setNewPassword(password);
    });
  }

  void resetState() {
    state = const AsyncData(null);
  }
}