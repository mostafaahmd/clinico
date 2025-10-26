class RegistrationData {
  final String email;
  final String password;
  final String fullName;
  final String? phone;
  final String gender;         // male/female/other
  final DateTime? birthDate;

  // صحّة وتغذية
  final double? heightCm;
  final double? weightKg;
  final String activityLevel;  // sedentary/light/moderate/active/very_active
  final String goal;           // lose/maintain/gain
  final double? targetWeightKg;

  // تفضيلات/حساسيّات
  final List<String> conditions; // ['diabetes','hypertension', ...]
  final List<String> allergies;
  final List<String> dietPrefs;

  RegistrationData({
    required this.email,
    required this.password,
    required this.fullName,
    this.phone,
    this.gender = 'other',
    this.birthDate,

    this.heightCm,
    this.weightKg,
    this.activityLevel = 'sedentary',
    this.goal = 'maintain',
    this.targetWeightKg,
    this.conditions = const [],
    this.allergies = const [],
    this.dietPrefs = const [],
  });
}
