import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/features/doctors/domain/doctor.dart';
import 'package:clinico/features/doctors/presentation/doctors_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DoctorsPage extends ConsumerWidget {
  const DoctorsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final doctors = ref.watch(doctorsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        backgroundColor: AppColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textDark),
        title: const Text(
          'Contact Doctor',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
        child: ListView.separated(
          itemCount: doctors.length,
          separatorBuilder: (_, __) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final doctor = doctors[index];
            return _DoctorCard(doctor: doctor);
          },
        ),
      ),
    );
  }
}

class _DoctorCard extends StatelessWidget {
  const _DoctorCard({required this.doctor});

  final Doctor doctor;

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
          // صورة الدكتور
          CircleAvatar(
            radius: 26,
            backgroundColor: const Color(0xFFF2F6FF),
            backgroundImage:
                doctor.imageUrl.isNotEmpty ? NetworkImage(doctor.imageUrl) : null,
            child: doctor.imageUrl.isEmpty
                ? const Icon(Icons.person, color: AppColors.primary)
                : null,
          ),
          const SizedBox(width: 12),

          // الاسم + التخصص + أونلاين
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  doctor.specialty,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textSoft,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: doctor.isOnline
                            ? const Color(0xFF22C55E)
                            : const Color(0xFF9CA3AF),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      doctor.isOnline ? 'Online now' : 'Offline',
                      style: TextStyle(
                        fontSize: 12,
                        color: doctor.isOnline
                            ? const Color(0xFF16A34A)
                            : const Color(0xFF9CA3AF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // زرار التواصل
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            onPressed: () {
              // هنا تحطى بقى منطق التواصل: شات / مكالمة / واتساب
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Contacting ${doctor.name}... (coming soon)'),
                ),
              );
            },
            child: const Text(
              'Contact',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
