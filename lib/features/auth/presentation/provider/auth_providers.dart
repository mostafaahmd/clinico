import 'package:clinico/features/auth/data/domain/registration_data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../data/domain/auth_repository.dart';
import '../../data/repo/auth_repository_impl.dart';

/// Supabase client
final supabaseProvider = Provider<SupabaseClient>(
  (ref) => Supabase.instance.client,
);

/// Registration controller
final registerControllerProvider =
    StateNotifierProvider<RegisterController, AsyncValue<void>>((ref) {
  return RegisterController(ref);
});

/// Auth repository (واحد بس)
final authRepoProvider = Provider<AuthRepository>(
  (ref) => AuthRepositoryImpl(ref.read(supabaseProvider)),
);

/// (اختياري) كنترولر بسيط يغلّف signIn/signUp
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

class RegisterController extends StateNotifier<AsyncValue<void>> {
  RegisterController(this.ref) : super(const AsyncData(null));
  final Ref ref;

  Future<void> register(RegistrationData data) async {
    state = const AsyncLoading();
    try {
      await ref.read(authRepoProvider).register(data);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}