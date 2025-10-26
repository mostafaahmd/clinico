import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/features/weight/presentation/providers/weight_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WeightListPage extends ConsumerWidget {
  const WeightListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(weightStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('My Weight'),
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(child: Text('No entries yet. Tap + to add.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemCount: list.length,
            itemBuilder: (_, i) {
              final r = list[i];
              final dt = DateTime.parse(r['at'] as String).toLocal();
              final kg = (r['weight_kg'] as num).toStringAsFixed(1);
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                child: ListTile(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  title: Text('$kg kg', style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text('${dt.year}/${dt.month.toString().padLeft(2,'0')}/${dt.day.toString().padLeft(2,'0')} '
                                 '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      final ok = await showDialog<bool>(context: context, builder: (c) {
                        return AlertDialog(
                          title: const Text('Delete entry?'),
                          content: Text('Remove $kg kg record?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(c,false), child: const Text('Cancel')),
                            FilledButton(onPressed: () => Navigator.pop(c,true), child: const Text('Delete')),
                          ],
                        );
                      });
                      if (ok == true) {
                        await ref.read(weightRepoProvider).deleteEntry(r['id'] as String);
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Entry deleted')));
                      }
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showDialog(context: context, builder: (_) => const _AddWeightDialog()),
        label: const Text('Add weight'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}

class _AddWeightDialog extends ConsumerStatefulWidget {
  const _AddWeightDialog();

  @override
  ConsumerState<_AddWeightDialog> createState() => _AddWeightDialogState();
}

class _AddWeightDialogState extends ConsumerState<_AddWeightDialog> {
  final _kg = TextEditingController();
  DateTime _at = DateTime.now();
  bool _saving = false;

  @override
  void dispose() { _kg.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New weight'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _kg,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Weight (kg)'),
          ),
          const SizedBox(height: 8),
          ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            title: const Text('Date & time'),
            subtitle: Text(_fmt(_at)),
            trailing: const Icon(Icons.schedule),
            onTap: () async {
              final d = await showDatePicker(
                context: context, initialDate: _at,
                firstDate: DateTime(2000), lastDate: DateTime(2100));
              if (d == null) return;
              final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_at));
              if (t == null) return;
              setState(() => _at = DateTime(d.year, d.month, d.day, t.hour, t.minute));
            },
          )
        ],
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.pop(context), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : () async {
            final v = double.tryParse(_kg.text.trim());
            if (v == null || v < 20 || v > 400) {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid weight (20–400).')));
              return;
            }
            setState(() => _saving = true);
            try {
              await ref.read(weightRepoProvider).addWeight(v, at: _at);
              if (mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Saved')));
              }
            } catch (e) {
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red));
              }
            } finally {
              if (mounted) setState(() => _saving = false);
            }
          },
          child: _saving ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                         : const Text('Save'),
        ),
      ],
    );
  }

  String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}/${dt.month.toString().padLeft(2,'0')}/${dt.day.toString().padLeft(2,'0')}  $h:$m';
  }
}
