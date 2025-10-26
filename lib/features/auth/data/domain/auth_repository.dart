import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:clinico/features/auth/data/domain/registration_data.dart';

abstract class AuthRepository {
  Future<void> signIn(String email, String password);
  Future<void> signUp(String email, String password);
  Future<void> signOut();

  /// تسجيل بحزمة بيانات كاملة + إنشاء/تحديث profile
  Future<void> register(RegistrationData data);

  Stream<AuthState> onAuthStateChanged();

  // Passwordless OTP reset flow
  Future<void> sendResetOtp(String email);
  Future<void> verifyResetOtp(String email, String code);
  Future<void> setNewPassword(String newPassword);
}




// import 'package:supabase_flutter/supabase_flutter.dart';

// abstract class AuthRepository {
//   Future<void> signIn(String email, String password);
//   Future<void> signUp(String email, String password);
//   Stream<AuthState> onAuthStateChanged();

//   Future<void> sendResetOtp(String email);
//   Future<void> verifyResetOtp(String email, String code); // dummy بالفلو الحالي
//   Future<void> setNewPasswordWithOtp({
//     required String email,
//     required String otp,
//     required String newPassword,
//   });
// }
