// prefs_service.dart
import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _onboardingSeen = 'onboarding_seen';
  static const _supportHour = 'support_hour';
  static const _supportMinute = 'support_minute';

  // مفاتيح للأوث
  static const _keepLoggedIn = 'keep_logged_in';
  static const _userId = 'user_id';
  static const _userEmail = 'user_email';

  Future<void> setOnboardingSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_onboardingSeen, true);
  }
  Future<bool> getOnboardingSeen() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_onboardingSeen) ?? false;
  }

  Future<void> setSupportTime(int h, int m) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_supportHour, h);
    await p.setInt(_supportMinute, m);
  }

  // ======== Auth helpers ========
  Future<void> setKeepLoggedIn(bool v) async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_keepLoggedIn, v);
  }
  Future<bool> getKeepLoggedIn() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_keepLoggedIn) ?? true; // افتراضي: مفعّل
  }

  Future<void> cacheUser({required String id, String? email}) async {
    final p = await SharedPreferences.getInstance();
    await p.setString(_userId, id);
    if (email != null) await p.setString(_userEmail, email);
  }
  Future<String?> getUserId() async {
    final p = await SharedPreferences.getInstance();
    return p.getString(_userId);
  }
  Future<void> clearUser() async {
    final p = await SharedPreferences.getInstance();
    await p.remove(_userId);
    await p.remove(_userEmail);
  }
}
