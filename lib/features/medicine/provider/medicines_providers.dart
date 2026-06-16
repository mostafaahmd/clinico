import 'package:clinico/features/medicine/domain/medicine.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final medicinesProvider = Provider<List<MedicineProduct>>((ref) {
  return const [
    MedicineProduct(
      id: '1',
      name: 'Metformin',
      description: 'Helps control blood sugar levels.',
      dose: '500 mg – twice daily',
      price: 95.0,
      imageUrl: 'https://i.imgur.com/2nCt3Sb.png',
      requiresPrescription: true,
    ),
    MedicineProduct(
      id: '2',
      name: 'Vitamin D3',
      description: 'Supports bone and immune health.',
      dose: '1000 IU – once daily',
      price: 60.0,
      imageUrl: '',
      requiresPrescription: false,
    ),
    MedicineProduct(
      id: '3',
      name: 'Omega-3',
      description: 'Supports heart and brain function.',
      dose: '1 capsule – once daily',
      price: 120.0,
      imageUrl: '',
      requiresPrescription: false,
    ),
  ];
});

final medicineSearchQueryProvider = StateProvider<String>((_) => '');
