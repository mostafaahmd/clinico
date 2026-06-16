import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/features/medicine/domain/medicine.dart';
import 'package:clinico/features/medicine/provider/medicines_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicinesPage extends ConsumerWidget {
  const MedicinesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<MedicineProduct> allMedicines = ref.watch(medicinesProvider);
    final query = ref.watch(medicineSearchQueryProvider).toLowerCase();

    final filtered = allMedicines.where((m) {
      if (query.isEmpty) return true;
      return m.name.toLowerCase().contains(query) ||
          m.description.toLowerCase().contains(query);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Search Medicines',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: Column(
          children: [
            TextField(
              onChanged: (value) =>
                  ref.read(medicineSearchQueryProvider.notifier).state = value,
              decoration: InputDecoration(
                hintText: 'Search by medicine name...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: AppColors.primary),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Text(
                        'No medicines found.',
                        style: TextStyle(
                          color: AppColors.textSoft,
                          fontSize: 14,
                        ),
                      ),
                    )
                  : ListView.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final medicine = filtered[index];
                        return _MedicineCard(medicine: medicine);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MedicineCard extends StatelessWidget {
  const _MedicineCard({required this.medicine});

  final MedicineProduct medicine;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE9EEF9)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F6FF),
              borderRadius: BorderRadius.circular(14),
            ),
            clipBehavior: Clip.antiAlias,
            child: medicine.imageUrl.isNotEmpty
                ? Image.network(
                    medicine.imageUrl,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.medication, color: AppColors.primary),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  medicine.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medicine.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSoft,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  medicine.dose,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                if (medicine.requiresPrescription)
                  const Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 14,
                        color: Color(0xFFF97316),
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Requires prescription',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFFF97316),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${medicine.price.toStringAsFixed(0)} EGP',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Added ${medicine.name} to cart (coming soon)',
                      ),
                    ),
                  );
                },
                child: const Text(
                  'Buy',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
