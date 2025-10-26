import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class HealthSummary {
  final double? bmi;
  final String? bmiCategory;
  final double? bmr;
  final double? tdee;
  final int? dailyCalories;
  final double? idealMin;
  final double? idealMax;
  HealthSummary({
    this.bmi,
    this.bmiCategory,
    this.bmr,
    this.tdee,
    this.dailyCalories,
    this.idealMin,
    this.idealMax,
  });
}

final healthSummaryProvider = FutureProvider<HealthSummary>((ref) async {
  final sb = Supabase.instance.client;
  final uid = sb.auth.currentUser?.id;
  if (uid == null) return HealthSummary();

  // ⬅️ select() بدون Generics + cast بعد maybeSingle()
  final raw = await sb
      .from('profiles')
      .select()            // لا تضع <T> هنا
      .eq('id', uid)
      .maybeSingle();      // ممكن يرجّع null

  if (raw == null) return HealthSummary();

  // cast آمن
  final Map<String, dynamic> p =
      raw is Map ? raw.cast<String, dynamic>() : Map<String, dynamic>.from(raw as Map);

  final gender   = (p['gender'] as String?) ?? 'other';
  final height   = (p['height_cm'] as num?)?.toDouble();
  final weight   = (p['weight_kg'] as num?)?.toDouble();
  final goal     = (p['goal'] as String?) ?? 'maintain';
  final activity = (p['activity_level'] as String?) ?? 'sedentary';
  final birth    = (p['birth_date'] as String?);
  final age      = _ageFromBirth(birth);

  if (height == null || weight == null || age == null) {
    return HealthSummary();
  }

  final hM = height / 100.0;
  final bmi = weight / (hM * hM);

  String cat;
  if (bmi < 18.5)       cat = 'Underweight';
  else if (bmi < 25.0)  cat = 'Normal';
  else if (bmi < 30.0)  cat = 'Overweight';
  else                  cat = 'Obese';

  final isMale = gender == 'male';
  final bmr = (isMale
      ? 10 * weight + 6.25 * height - 5 * age + 5
      : 10 * weight + 6.25 * height - 5 * age - 161);

  final factor = switch (activity) {
    'sedentary'   => 1.2,
    'light'       => 1.375,
    'moderate'    => 1.55,
    'active'      => 1.725,
    'very_active' => 1.9,
    _             => 1.2,
  };

  final tdee  = bmr * factor;
  final delta = switch (goal) {
    'lose' => -500,
    'gain' =>  300,
    _      =>    0,
  };

  final daily    = (tdee + delta).round();
  final idealMin = 18.5 * hM * hM;
  final idealMax = 24.9 * hM * hM;

  double r1(double x) => double.parse(x.toStringAsFixed(1));
  double r0(double x) => double.parse(x.toStringAsFixed(0));

  return HealthSummary(
    bmi: r1(bmi),
    bmiCategory: cat,
    bmr: r0(bmr),
    tdee: r0(tdee),
    dailyCalories: daily,
    idealMin: r1(idealMin),
    idealMax: r1(idealMax),
  );
});

int? _ageFromBirth(String? iso) {
  if (iso == null) return null;
  final d = DateTime.tryParse(iso);
  if (d == null) return null;
  final now = DateTime.now();
  var age = now.year - d.year;
  if (now.month < d.month || (now.month == d.month && now.day < d.day)) age--;
  return max(0, age);
}
