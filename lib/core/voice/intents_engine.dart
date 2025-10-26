import 'package:go_router/go_router.dart';

enum IntentType {
  addMeal, openMeals, addMedicine, openMedicines, openProgress, openSettings,
  help, unknown
}

class IntentResult {
  final IntentType type;
  final Map<String, dynamic> slots;
  IntentResult(this.type, [this.slots = const {}]);
}

class IntentsEngine {
  // كلمات مفتاحية بالعربي/الإنجليزي
  IntentResult parse(String q) {
    final s = q.toLowerCase();

    // فتح صفحات
    if (_hasAny(s, ['progress', 'البروجريس', 'التقدم'])) {
      return IntentResult(IntentType.openProgress);
    }
    if (_hasAny(s, ['settings', 'سيتي', 'الإعدادات', 'الاعدادات'])) {
      return IntentResult(IntentType.openSettings);
    }
    if (_hasAny(s, ['meals', 'الوجبات', 'اكل', 'meal plan'])) {
      if (_hasAny(s, ['add', 'اضف', 'سجل', 'اضافة'])) {
        return IntentResult(IntentType.addMeal);
      }
      return IntentResult(IntentType.openMeals);
    }
    if (_hasAny(s, ['medicine', 'الدواء', 'ادوية', 'دوائي'])) {
      if (_hasAny(s, ['add', 'اضف', 'سجل', 'اضافة'])) {
        return IntentResult(IntentType.addMedicine);
      }
      return IntentResult(IntentType.openMedicines);
    }

    // مساعدة
    if (_hasAny(s, ['help', 'مساعدة', 'تساعدني'])) {
      return IntentResult(IntentType.help);
    }

    return IntentResult(IntentType.unknown);
  }

  bool _hasAny(String s, List<String> keys) =>
      keys.any((k) => s.contains(k));
}

/// تنفيذ الفعل + الرد الصوتي
Future<String> handleIntent(IntentResult r, GoRouter router) async {
  switch (r.type) {
    case IntentType.addMeal:
      router.push('/add-meal');
      return 'تمام. افتحت لك إضافة وجبة.';
    case IntentType.openMeals:
      router.push('/meal-plan');
      return 'تمام. دي خطة وجباتك.';
    case IntentType.addMedicine:
      router.push('/add-medicine');
      return 'ماشي. افتحت إضافة دواء.';
    case IntentType.openMedicines:
      router.push('/my-medicine');
      return 'تمام. دي قائمة أدويتك.';
    case IntentType.openProgress:
      router.push('/progress');
      return 'هنا تقدمك خلال الأيام اللي فاتت.';
    case IntentType.openSettings:
      router.push('/settings');
      return 'دي صفحة الإعدادات.';
    case IntentType.help:
      return 'تقدر تقول: افتح الأدوية، أضف وجبة، افتح الإعدادات، أو اعرض التقدم.';
    case IntentType.unknown:
      return 'معلش، ما فهمتش. جرّب تقول: افتح الأدوية، أو أضف وجبة.';
  }
}
