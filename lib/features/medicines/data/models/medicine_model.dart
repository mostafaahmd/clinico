import 'package:flutter/material.dart';

class Medicine {
  final String id;
  final String userId;
  final String name;
  final String? dose; // e.g., "500 mg"
  final List<TimeOfDay> schedule; // نختزنها JSON في DB
  final DateTime createdAt;

  Medicine({
    required this.id,
    required this.userId,
    required this.name,
    required this.schedule,
    required this.createdAt,
    this.dose,
  });

  factory Medicine.fromMap(Map<String, dynamic> m) {
    final sch = (m['schedule'] as List?) ?? [];
    final times = sch.map((e) {
      final map = (e as Map).map((k, v) => MapEntry(k.toString(), v));
      return TimeOfDay(hour: map['hour'] as int, minute: map['minute'] as int);
    }).toList();
    return Medicine(
      id: m['id'] as String,
      userId: m['user_id'] as String,
      name: m['name'] as String,
      dose: m['dose'] as String?,
      schedule: times,
      createdAt: DateTime.parse(m['created_at'] as String),
    );
  }

  List<Map<String, int?>> _scheduleToJson() =>
      schedule.map((t) => {'hour': t.hour, 'minute': t.minute}).toList();

  Map<String, dynamic> toInsert() => {
        'name': name,
        'dose': dose,
        'schedule': _scheduleToJson(),
      };
}
