import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:clinico/features/doctors/domain/doctor.dart';
// لو هتوصلينه بـ Supabase بعدين
// import 'package:clinico/core/providers/supabase_providers.dart';

final doctorsProvider = Provider<List<Doctor>>((ref) {
  // دلوقتي بيانات ثابتة (mock)
  // بعدين تقدري تعملي FutureProvider وتجيبي البيانات من Supabase
  return const [
    Doctor(
      id: '1',
      name: 'Dr. Ahmed Ali',
      specialty: 'Nutrition Specialist',
      imageUrl: 'https://i.pravatar.cc/150?img=1',
      isOnline: true,
    ),
    Doctor(
      id: '2',
      name: 'Dr. Sara Mohamed',
      specialty: 'Diabetes Consultant',
      imageUrl: 'https://i.pravatar.cc/150?img=2',
      isOnline: false,
    ),
    Doctor(
      id: '3',
      name: 'Dr. Omar Youssef',
      specialty: 'Cardiologist',
      imageUrl: 'https://i.pravatar.cc/150?img=3',
      isOnline: true,
    ),
  ];
});
