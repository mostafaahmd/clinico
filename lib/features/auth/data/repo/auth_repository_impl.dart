// lib/features/auth/data/auth_repository_impl.dart
import 'package:clinico/core/services/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._sb);
  final SupabaseService _sb;

  @override
  Future<void> signIn(String email, String password) =>
      _sb.signIn(email: email, password: password);

  @override
  Future<void> signUp(String email, String password) =>
      _sb.signUp(email: email, password: password);

  @override
  Stream<AuthState> onAuthStateChanged() => _sb.onAuthState();
}
