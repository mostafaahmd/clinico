// lib/features/meals/presentation/meal_form_page.dart
import 'package:clinico/core/providers/base_providers.dart';
import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/features/meals/data/models/meal_model.dart';
import 'package:clinico/features/meals/data/repo/meal_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MealFormPage extends ConsumerStatefulWidget {
  const MealFormPage({super.key, this.existing});
  final Meal? existing;

  @override
  ConsumerState<MealFormPage> createState() => _MealFormPageState();
}

class _MealFormPageState extends ConsumerState<MealFormPage> {
  final _form = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _cal = TextEditingController();
  DateTime _time = DateTime.now();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _title.text = e.title;
      if (e.calories != null) _cal.text = e.calories.toString();
      _time = e.time;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _cal.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.existing != null;

    final fieldTheme = Theme.of(context).copyWith(
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Meal' : 'Add Meal'),
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      body: Theme(
        data: fieldTheme,
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              _SectionCard(
                child: Column(
                  children: [
                    TextFormField(
                      controller: _title,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Title'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _cal,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Calories (optional)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                child: _TimeTile(
                  label: 'Time',
                  subtitle: _fmt(_time),
                  onTap: _pickDateTime,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                height: 52,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _saving ? null : () => _submit(isEdit),
                  child: _saving
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : Text(isEdit ? 'Save Changes' : 'Add Meal'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDateTime() async {
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(2022),
      lastDate: DateTime(2100),
      initialDate: _time,
    );
    if (d == null) return;
    final t = await showTimePicker(context: context, initialTime: TimeOfDay.fromDateTime(_time));
    if (t == null) return;
    setState(() {
      _time = DateTime(d.year, d.month, d.day, t.hour, t.minute);
    });
  }

  Future<void> _submit(bool isEdit) async {
    if (!_form.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final repo = ref.read(mealsRepoProvider);
      final uid = ref.read(uidProvider);
      if (uid == null) throw Exception('Not authenticated');

      final meal = Meal(
        id: widget.existing?.id ?? 'tmp',
        userId: uid,
        title: _title.text.trim(),
        calories: _cal.text.trim().isEmpty ? null : int.tryParse(_cal.text.trim()),
        time: _time,
        createdAt: DateTime.now(),
      );

      if (isEdit) {
        await repo.updateMeal(widget.existing!.id, meal);
        _ok(context, 'Meal updated');
      } else {
        await repo.addMeal(uid, meal);
        _ok(context, 'Meal added');
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _err(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  static String _fmt(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '${dt.year}/${dt.month.toString().padLeft(2, '0')}/${dt.day.toString().padLeft(2, '0')}  $h:$m';
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF9)),
        boxShadow: const [BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6))],
      ),
      child: child,
    );
  }
}

class _TimeTile extends StatelessWidget {
  const _TimeTile({required this.label, required this.subtitle, required this.onTap});
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: const Color(0xFFF2F6FF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.schedule, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppColors.textSoft)),
                ],
              ),
            ),
            const Icon(Icons.edit_outlined, color: AppColors.textSoft),
          ],
        ),
      ),
    );
  }
}

void _ok(BuildContext c, String msg) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));
}

void _err(BuildContext c, String msg) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
}
