// notification_service.dart
// تهيئة قنوات الإشعارات + بناء جداول للتذكير (أدوية/دعم نفسي)

import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  // تهيئة القنوات وطلب الإذن (Android 13+ يحتاج POST_NOTIFICATIONS)
  static Future<void> ensureInit() async {
    AwesomeNotifications().initialize(
      null, // أيقونة افتراضية من mipmap
      [
        // قناة مخصصة لتذكير الأدوية — نبرة تنبيه أعلى (Alarm)
        NotificationChannel(
          channelKey: 'meds',
          channelName: 'Med Reminders',
          channelDescription: 'Medicine intake reminders',
          importance: NotificationImportance.Max,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
        ),
        // قناة للدعم النفسي اليومي
        NotificationChannel(
          channelKey: 'support',
          channelName: 'Mental Support',
          channelDescription: 'Motivational daily notes',
          importance: NotificationImportance.High,
        ),
      ],
      debug: false,
    );

    final allowed = await AwesomeNotifications().isNotificationAllowed();
    if (!allowed) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }
  }

  // جدولة تذكير دواء في وقت معيّن (Exact Alarm إن أمكن)
  Future<void> scheduleMedReminder({
    required String id,        // معرّف فريد للتذكير (نستخدمه في الإلغاء)
    required DateTime dateTime,
    required String title,
    required String body,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: id.hashCode,
        channelKey: 'meds',
        title: title,
        body: body,
        wakeUpScreen: true,
        category: NotificationCategory.Alarm,
      ),
      schedule: NotificationCalendar.fromDate(
        date: dateTime,
        preciseAlarm: true,     // يطلب Exact إن متاح
        allowWhileIdle: true,
      ),
    );
  }

  // جدولة رسالة دعم يومية مكرّرة
  Future<void> scheduleDailySupport({required int hour, required int minute}) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: 'support_$hour$minute'.hashCode,
        channelKey: 'support',
        title: 'مساحتك الآمنة 💙',
        body: 'كيف حالك اليوم؟ خطوة صغيرة تكفي.',
      ),
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        repeats: true,
      ),
    );
  }
}
