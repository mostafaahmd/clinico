import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/features/health/presentation/providers/health_summary_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HealthSummaryCard extends ConsumerWidget {
  const HealthSummaryCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hs = ref.watch(healthSummaryProvider);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF9)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: hs.when(
        loading: () => const SizedBox(height: 60, child: Center(child: CircularProgressIndicator())),
        error: (e, _) => Text('Error: $e'),
        data: (d) {
          if (d.bmi == null) return const Text('Add your height/weight to see your health summary.');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Health summary', style: TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _tile('BMI', '${d.bmi} (${d.bmiCategory})'),
                  const SizedBox(width: 12),
                  _tile('TDEE', d.tdee?.toStringAsFixed(0) ?? '-'),
                  const SizedBox(width: 12),
                  _tile('Daily kcal', d.dailyCalories?.toString() ?? '-'),
                ],
              ),
              const SizedBox(height: 8),
              Text('Ideal weight: ${d.idealMin}–${d.idealMax} kg',
                  style: const TextStyle(color: AppColors.textSoft)),
            ],
          );
        },
      ),
    );
  }

  Widget _tile(String k, String v) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF6F8FF),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(k, style: const TextStyle(fontSize: 12, color: AppColors.textSoft)),
          const SizedBox(height: 4),
          Text(v, style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
      ),
    );
  }
}
