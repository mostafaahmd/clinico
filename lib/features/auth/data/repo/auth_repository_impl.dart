import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clinico/features/auth/data/domain/auth_repository.dart';
import 'package:clinico/features/auth/data/domain/registration_data.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl(this._sb);
  final SupabaseClient _sb;

  @override
  Future<void> signIn(String email, String password) async {
    final res = await _sb.auth.signInWithPassword(email: email, password: password);
    if (res.session == null) throw Exception('Login failed');
  }

  @override
  Future<void> signUp(String email, String password) async {
    await _sb.auth.signUp(email: email, password: password);
  }

  @override
  Future<void> signOut() => _sb.auth.signOut();

  @override
  Stream<AuthState> onAuthStateChanged() => _sb.auth.onAuthStateChange;

  /// Register = إنشاء المستخدم + تحديث profiles
  @override
  Future<void> register(RegistrationData data) async {
    // مرّر full_name في user_metadata عشان التريجر يكتبه في profiles
    final res = await _sb.auth.signUp(
      email: data.email.trim(),
      password: data.password,
      data: {
        'full_name': data.fullName,
      },
    );

    // لو Email confirmation شغال، ممكن مايكونش في Session:
    final uid = res.user?.id ?? _sb.auth.currentUser?.id;
    if (uid == null) {
      // الحساب اتعمل بس محتاج verification قبل تحديث profiles
      throw Exception('Account created. Please verify your email, then login.');
    }

    // حدّث صف البروفايل (التريجر كان كتب full_name بالفعل)
    await _sb.from('profiles').update({
      if (data.phone != null && data.phone!.isNotEmpty) 'phone': data.phone,
      'gender': data.gender,
      if (data.birthDate != null) 'birth_date': data.birthDate!.toIso8601String(),
      if (data.heightCm != null) 'height_cm': data.heightCm,
      if (data.weightKg != null) 'weight_kg': data.weightKg,
      'activity_level': data.activityLevel,
      'goal': data.goal,
      if (data.targetWeightKg != null) 'target_weight_kg': data.targetWeightKg,
      if (data.conditions.isNotEmpty) 'conditions': data.conditions,
      if (data.allergies.isNotEmpty) 'allergies': data.allergies,
      if (data.dietPrefs.isNotEmpty) 'diet_prefs': data.dietPrefs,
    }).eq('id', uid);
  }

  // ===== Passwordless OTP reset flow =====
  @override
  Future<void> sendResetOtp(String email) async {
    await _sb.auth.signInWithOtp(
      email: email.trim(),
      shouldCreateUser: false,
      emailRedirectTo: null,
    );
  }

  @override
  Future<void> verifyResetOtp(String email, String code) async {
    final res = await _sb.auth.verifyOTP(
      email: email.trim(),
      token: code.trim(),
      type: OtpType.email,
    );
    if (res.session == null) {
      throw Exception('OTP verification failed');
    }
  }

  @override
  Future<void> setNewPassword(String newPassword) async {
    final p = newPassword.trim();
    if (p.length < 8) throw Exception('Password must be at least 8 characters');
    await _sb.auth.updateUser(UserAttributes(password: p));
  }
}
