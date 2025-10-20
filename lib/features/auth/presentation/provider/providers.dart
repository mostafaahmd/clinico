// lib/features/auth/presentation/auth_providers.dart
import 'package:clinico/core/di/service_locator.dart';
import 'package:clinico/features/auth/data/domain/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


final authRepoProvider = Provider<AuthRepository>((ref) => sl<AuthRepository>());

final authControllerProvider =
    StateNotifierProvider<AuthController, AsyncValue<void>>((ref) {
  return AuthController(ref);
});

class AuthController extends StateNotifier<AsyncValue<void>> {
  AuthController(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<void> signIn(String email, String pass) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepoProvider).signIn(email, pass);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }

  Future<void> signUp(String email, String pass) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepoProvider).signUp(email, pass);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}
