// lib/core/notifications/notification_service.dart
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationService {
  /// نادِها مرة في main() قبل runApp
  static Future<void> ensureInit() async {
    AwesomeNotifications().initialize(
      null,
      [
        NotificationChannel(
          channelKey: 'meds',
          channelName: 'Med Reminders',
          channelDescription: 'Medicine intake reminders',
          importance: NotificationImportance.Max,
          defaultRingtoneType: DefaultRingtoneType.Alarm,
        ),
      ],
      debug: false,
    );

    if (!await AwesomeNotifications().isNotificationAllowed()) {
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    AwesomeNotifications().setListeners(
      onActionReceivedMethod: onActionReceivedMethod,
    );
  }

  /// نولّد ID ثابت لكل (دواء + وقت)
  static int _idFor(String medId, int hour, int minute) =>
      ('${medId}_$hour:$minute').hashCode;

  /// جدولة تذكير يومي لدواء في ساعة/دقيقة محددين
  static Future<void> scheduleDailyMed({
    required String medId,
    required String title, // اسم الدواء
    String? body,          // الجرعة
    required int hour,
    required int minute,
  }) async {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: _idFor(medId, hour, minute),
        channelKey: 'meds',
        title: 'وقت $title',
        body: (body != null && body.isNotEmpty) ? body : 'حان وقت الدواء',
        category: NotificationCategory.Reminder,
        payload: {'med_id': medId, 'hour': '$hour', 'minute': '$minute'},
      ),
      // ✅ الأزرار هنا مش جوه content
      actionButtons: [
        NotificationActionButton(
          key: 'TAKEN',
          label: 'تمّ التناول',
          actionType: ActionType.Default,
        ),
        NotificationActionButton(
          key: 'SKIP',
          label: 'تخطي',
          actionType: ActionType.Default,
          isDangerousOption: true,
        ),
      ],
      schedule: NotificationCalendar(
        hour: hour,
        minute: minute,
        second: 0,
        millisecond: 0,
        repeats: true,
        allowWhileIdle: true,
        preciseAlarm: true,
      ),
    );
  }

  /// إلغاء كل جداول الإشعارات لدواء معيّن
  static Future<void> cancelMedSchedule(String medId) async {
    final all = await AwesomeNotifications().listScheduledNotifications();
    for (final n in all) {
      final payload = n.content?.payload;
      if (payload != null && payload['med_id'] == medId) {
        final id = n.content!.id!;
        await AwesomeNotifications().cancel(id);
      }
    }
  }
}

/// كول باك أزرار الإشعار (لا تسحب UI؛ بتشتغل بالخلفية)
@pragma('vm:entry-point')
Future<void> onActionReceivedMethod(ReceivedAction action) async {
  final medId = action.payload?['med_id'];
  final key = action.buttonKeyPressed; // 'TAKEN' أو 'SKIP' أو ''
  if (medId == null || key.isEmpty) return;

  try {
    final sb = Supabase.instance.client;
    final uid = sb.auth.currentUser?.id;
    if (uid == null) return;

    await sb.from('med_intake_logs').insert({
      'user_id': uid,
      'medicine_id': medId,
      'at': DateTime.now().toIso8601String(),
      'status': key == 'TAKEN' ? 'taken' : 'skipped',
    });
  } catch (_) {
    // تجاهل أي error — المهم ميتعطلش
  }
}
