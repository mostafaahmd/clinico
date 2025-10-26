import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/core/widgets/common_widgets.dart';
import 'package:clinico/features/meals/data/models/meal_model.dart';
import 'package:clinico/features/meals/data/repo/meal_repository.dart';
import 'package:clinico/features/meals/presentation/widgets/meal_form_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealListPage extends ConsumerWidget {
  const MealListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(mealsStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Meal Plan'),
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: mealsAsync.when(
        data: (list) {
          if (list.isEmpty) {
            return const EmptyState(           // 👈 بدل _EmptyState
              title: 'No meals yet',
              message: 'Tap the button below to add your first meal.',
              icon: Icons.restaurant,          // 👈 بدل assetIcon
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.refresh(mealsStreamProvider);
            },
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
              itemCount: list.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _MealCard(meal: list[i]),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
      floatingActionButton: PrimaryFAB(      // 👈 بدل _PrimaryFAB
        label: 'Add Meal',
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const MealFormPage()),
          );
        },
      ),
    );
  }
}

class _MealCard extends ConsumerWidget {
  const _MealCard({required this.meal});
  final Meal meal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sub = <String>[
      if (meal.calories != null) '${meal.calories} cal',
      _fmt(meal.time),
    ].join(' • ');

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => MealFormPage(existing: meal)),
      ),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE9EEF9)),
          boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))],
        ),
        child: Row(
          children: [
            const IconCapsule(icon: Icons.restaurant), // 👈 بدل _IconCapsule
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(meal.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text(sub, style: const TextStyle(color: AppColors.textSoft)),
                ],
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (v) async {
                final repo = ref.read(mealsRepoProvider);
                if (v == 'edit') {
                  await Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => MealFormPage(existing: meal)),
                  );
                } else if (v == 'delete') {
                  final ok = await confirmDelete(context, 'meal "${meal.title}"'); // 👈 helper تحت
                  if (ok != true) return;
                  await repo.deleteMeal(meal.id);
                  _ok(context, 'Meal deleted');
                }
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _fmt(DateTime dt) {
    final y = dt.year;
    final mo = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$y/$mo/$d  $h:$m';
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
