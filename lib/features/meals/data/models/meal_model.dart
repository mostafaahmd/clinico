// lib/features/meals/data/meal_model.dart
class Meal {
  final String id;
  final String userId;
  final String title;
  final int? calories;
  final DateTime time;
  final DateTime createdAt;

  Meal({
    required this.id,
    required this.userId,
    required this.title,
    required this.time,
    required this.createdAt,
    this.calories,
  });

  factory Meal.fromMap(Map<String, dynamic> m) => Meal(
        id: m['id'] as String,
        userId: m['user_id'] as String,
        title: m['title'] as String,
        calories: m['calories'] as int?,
        time: DateTime.parse(m['time'] as String),
        createdAt: DateTime.parse(m['created_at'] as String),
      );

  Map<String, dynamic> toInsert() => {
        'title': title,
        'calories': calories,
        'time': time.toIso8601String(),
      };
}
