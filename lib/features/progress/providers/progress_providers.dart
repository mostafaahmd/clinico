// lib/features/progress/providers/progress_providers.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:postgrest/postgrest.dart';

/// نقطة يومية للكالوريز
@immutable
class DailyPoint {
  final DateTime day;
  final int value;
  const DailyPoint(this.day, this.value);
  String get label => '${day.month}/${day.day}';
}

/// نقطة يومية للالتزام: taken / expected
@immutable
class DailyAdherence {
  final DateTime day;
  final int taken;
  final int expected;
  const DailyAdherence({required this.day, required this.taken, required this.expected});
  String get label => '${day.month}/${day.day}';
  double get ratio => expected == 0 ? 0 : taken / expected;
}

/// آخر 14 يوم من السعرات (مجمّعة باليوم)
final last14MealsProvider = FutureProvider<List<DailyPoint>>((ref) async {
  final sb = Supabase.instance.client;
  final uid = sb.auth.currentUser?.id;
  if (uid == null) return const [];

  final from = DateTime.now().toUtc().subtract(const Duration(days: 13));
  final data = await sb
      .from('meals')
      .select('time, calories')
      .gte('time', from.toIso8601String())
      .eq('user_id', uid)
      .order('time');

  // group by yyyy-mm-dd
  final map = <String, int>{};
  for (final r in data) {
    final d = DateTime.parse(r['time']).toLocal();
    final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final c = (r['calories'] as int?) ?? 0;
    map[key] = (map[key] ?? 0) + c;
  }

  // build 14 days series, oldest → newest
  return List.generate(14, (i) {
    final d = DateTime.now().toLocal().subtract(Duration(days: 13 - i));
    final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return DailyPoint(d, map[key] ?? 0);
  });
});

/// سلسلة الالتزام اليومي (آخر 7 أيام) – عدد taken أمام expected
final medsAdherence7dSeriesProvider = FutureProvider<List<DailyAdherence>>((ref) async {
  final sb = Supabase.instance.client;
  final uid = sb.auth.currentUser?.id;
  if (uid == null) return const [];

  // 1) كم جرعة متوقعة في اليوم؟ (عدد أوقات كل الأدوية الحالية)
  int perDayExpected = 0;
  try {
    final meds = await sb.from('medicines').select('schedule').eq('user_id', uid);
    for (final m in meds) {
      final sch = (m['schedule'] as List?) ?? [];
      perDayExpected += sch.length;
    }
  } on PostgrestException {
    // لو الجدول مش موجود أو RLS تمنع، رجّع صفر
    return List.generate(7, (i) {
      final d = DateTime.now().toLocal().subtract(Duration(days: 6 - i));
      return DailyAdherence(day: d, taken: 0, expected: 0);
    });
  }

  // 2) اجمع اللوجز (taken/ skipped) لآخر 7 أيام
  final from = DateTime.now().toUtc().subtract(const Duration(days: 6));
  List<dynamic> logs = const [];
  try {
    logs = await sb
        .from('med_intake_logs')
        .select('at, status')
        .gte('at', from.toIso8601String())
        .eq('user_id', uid);
  } on PostgrestException {
    // الجدول مش موجود → رجّع السلسلة كلها بصفر
    return List.generate(7, (i) {
      final d = DateTime.now().toLocal().subtract(Duration(days: 6 - i));
      return DailyAdherence(day: d, taken: 0, expected: perDayExpected);
    });
  }

  final takenMap = <String, int>{};
  for (final r in logs) {
    if (r['status'] != 'taken') continue;
    final d = DateTime.parse(r['at']).toLocal();
    final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    takenMap[key] = (takenMap[key] ?? 0) + 1;
  }

  return List.generate(7, (i) {
    final d = DateTime.now().toLocal().subtract(Duration(days: 6 - i));
    final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final taken = takenMap[key] ?? 0;
    return DailyAdherence(day: d, taken: taken, expected: perDayExpected);
  });
});

/// نسبة الالتزام المجمّعة (0..1) لآخر 7 أيام – تُستخدم للـ LinearProgress
final adherence7dProvider = FutureProvider<double>((ref) async {
  final series = await ref.watch(medsAdherence7dSeriesProvider.future);
  final totExpected = series.fold<int>(0, (a, e) => a + e.expected);
  final totTaken = series.fold<int>(0, (a, e) => a + e.taken);
  if (totExpected == 0) return 0;
  return totTaken / totExpected;
});
