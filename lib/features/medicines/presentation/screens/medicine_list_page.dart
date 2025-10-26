import 'package:clinico/core/services/notification_service.dart';
import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/core/widgets/common_widgets.dart';
import 'package:clinico/features/medicines/data/models/medicine_model.dart';
import 'package:clinico/features/medicines/data/repo/medicine_repository.dart';
import 'package:clinico/features/medicines/presentation/widgets/medicine_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicineListPage extends ConsumerWidget {
  const MedicineListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final medsAsync = ref.watch(medsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('My Medicine'),
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: medsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(                 // 👈 بدل _EmptyState
              title: 'No medicines',
              message: 'Add your medicines and get reminders on time.',
              icon: Icons.medication,                // 👈 بدل assetIcon
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(medsStreamProvider);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _MedicineCard(med: list[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: PrimaryFAB(      // 👈 بدل _PrimaryFAB
        label: 'Add Medicine',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MedicineFormPage()),
          );
        },
      ),
    );
  }
}

class _MedicineCard extends ConsumerWidget {
  const _MedicineCard({required this.med});
  final Medicine med;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MedicineFormPage(existing: med)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EEF9)),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const IconCapsule(icon: Icons.medication), // 👈 بدل _IconCapsule
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    med.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark),
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (v) async {
                    final repo = ref.read(medsRepoProvider);
                    if (v == 'edit') {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => MedicineFormPage(existing: med)),
                      );
                    } else if (v == 'delete') {
                      final ok = await confirmDelete(context, 'medicine "${med.name}"');
                      if (ok != true) return;
                      try {
                        await NotificationService.cancelMedSchedule(med.id);
                        await repo.deleteMed(med.id);
                        _ok(context, 'Medicine deleted');
                      } catch (e) {
                        _err(context, 'Delete failed: $e');
                      }
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'edit', child: Text('Edit')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ],
            ),
            if (med.dose?.isNotEmpty == true) ...[
              const SizedBox(height: 6),
              Text(med.dose!, style: const TextStyle(color: AppColors.textSoft)),
            ],
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: med.schedule.map((t) {
                final label = '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F6FF),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: const Color(0xFFE0E7FF)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.schedule, size: 16, color: AppColors.primary),
                      const SizedBox(width: 6),
                      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

Future<bool?> confirmDelete(BuildContext context, String what) {
  return showDialog<bool>(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Delete'),
      content: Text('Are you sure you want to delete $what?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Cancel')),
        FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Delete')),
      ],
    ),
  );
}

void _ok(BuildContext c, String msg) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));
}

void _err(BuildContext c, String msg) {
  ScaffoldMessenger.of(c).showSnackBar(
    SnackBar(content: Text(msg), backgroundColor: Colors.red),
  );
}
