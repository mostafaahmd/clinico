// prefs_service.dart
// غلاف بسيط لـ SharedPreferences (مفاتيح شائعة الاستخدام)

import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  // مفاتيح
  static const _onboardingSeen = 'onboarding_seen';
  static const _supportHour = 'support_hour';
  static const _supportMinute = 'support_minute';

  // وضع علامة إن المستخدم شاف شاشات البداية
  Future<void> setOnboardingSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_onboardingSeen, true);
  }

  // قراءة حالة شاشات البداية
  Future<bool> getOnboardingSeen() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_onboardingSeen) ?? false;
  }

  // حفظ وقت رسالة الدعم اليومي
  Future<void> setSupportTime(int h, int m) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_supportHour, h);
    await p.setInt(_supportMinute, m);
  }
}
