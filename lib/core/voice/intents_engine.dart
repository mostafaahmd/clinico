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
  // تطبيع عربي بسيط: يشيل التشكيل، يوحّد الألفات، يحوّل ة→ه، ى→ي، يشيل المدّة، ويحذف "ال" للتطبيع.
  String _normalize(String input) {
    var s = input.toLowerCase();

    // إزالة التشكيل والمدّة
    s = s.replaceAll(RegExp(r'[\u0617-\u061A\u064B-\u0652\u0640]'), '');

    // توحيد الحروف
    const repl = {
      'أ': 'ا', 'إ': 'ا', 'آ': 'ا', 'ٱ': 'ا',
      'ة': 'ه',
      'ى': 'ي',
      'ؤ': 'و', 'ئ': 'ي',
    };
    repl.forEach((k, v) => s = s.replaceAll(k, v));

    // تصغير تأثير أداة التعريف "ال"
    s = s.replaceAll(RegExp(r'\bال'), ' ');

    // مسافات إضافية
    s = s.replaceAll(RegExp(r'\s+'), ' ').trim();
    return s;
  }

  bool _hasAny(String s, List<String> keys) => keys.any((k) => s.contains(k));

  IntentResult parse(String q) {
    final s = _normalize(q);

    // فتح صفحات
    if (_hasAny(s, ['progress', 'بروجريس', 'تقدم'])) {
      return IntentResult(IntentType.openProgress);
    }

    if (_hasAny(s, ['settings', 'اعدادات', 'الاعدادات', 'ضبط'])) {
      return IntentResult(IntentType.openSettings);
    }

    // وجبات
    if (_hasAny(s, ['meal', 'meals', 'وجبه', 'وجبات', 'اكل', 'وجبه', 'meal plan'])) {
      if (_hasAny(s, ['add', 'اضف', 'سجل', 'اضافه'])) {
        return IntentResult(IntentType.addMeal);
      }
      return IntentResult(IntentType.openMeals);
    }

    // أدوية (مرادفات + أشكال كتابة مختلفة)
    if (_hasAny(s, [
      'medicine', 'دواء', 'ادويه', 'ادويه', 'ادويتي', 'دوائي'
    ])) {
      if (_hasAny(s, ['add', 'اضف', 'سجل', 'اضافه'])) {
        return IntentResult(IntentType.addMedicine);
      }
      return IntentResult(IntentType.openMedicines);
    }

    if (_hasAny(s, ['help', 'مساعده', 'تساعدني'])) {
      return IntentResult(IntentType.help);
    }

    return IntentResult(IntentType.unknown);
  }
}

/// تنفيذ الفعل + الرد الصوتي
Future<String> handleIntent(IntentResult r, GoRouter router) async {
  switch (r.type) {
    case IntentType.addMeal:
      router.push('/add-meal');
      return 'تمام. افتحت لك إضافة وجبه.';
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
      return 'معلش، ما فهمتش. جرّب تقول: افتح الأدوية، أو أضف وجبه.';
  }
}
