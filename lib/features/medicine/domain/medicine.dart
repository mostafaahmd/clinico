import 'package:flutter/foundation.dart';

@immutable
class MedicineProduct {
  final String id;
  final String name;
  final String description;
  final String dose;
  final double price;
  final String imageUrl;
  final bool requiresPrescription;

  const MedicineProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.dose,
    required this.price,
    required this.imageUrl,
    required this.requiresPrescription,
  });
}
