// supabase_service.dart
// غلاف بسيط لتجميع استدعاءات Supabase في مكان واحد

import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService(this.client);
  final SupabaseClient client;

  // Auth: تسجيل دخول بالبريد/كلمة سر
  Future<void> signIn({required String email, required String password}) =>
      client.auth.signInWithPassword(email: email, password: password);

  // Auth: إنشاء حساب بالبريد/كلمة سر
  Future<void> signUp({required String email, required String password}) =>
      client.auth.signUp(email: email, password: password);

  // بث تغيّرات حالة المستخدم/الجلسة
  Stream<AuthState> onAuthState() => client.auth.onAuthStateChange;

  // TODO: لاحقًا — دوال الشات: fetchMessages, sendMessage … إلخ
}
