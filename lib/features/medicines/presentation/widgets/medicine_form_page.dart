// lib/features/medicines/presentation/medicine_form_page.dart
import 'package:clinico/core/providers/base_providers.dart';
import 'package:clinico/core/services/notification_service.dart';
import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/features/medicines/data/models/medicine_model.dart';
import 'package:clinico/features/medicines/data/repo/medicine_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MedicineFormPage extends ConsumerStatefulWidget {
  const MedicineFormPage({super.key, this.existing});
  final Medicine? existing;

  @override
  ConsumerState<MedicineFormPage> createState() => _MedicineFormPageState();
}

class _MedicineFormPageState extends ConsumerState<MedicineFormPage> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _dose = TextEditingController();
  final List<TimeOfDay> _times = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _name.text = e.name;
      if (e.dose != null) _dose.text = e.dose!;
      _times.addAll(e.schedule);
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
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
        title: Text(isEdit ? 'Edit Medicine' : 'Add Medicine'),
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
                      controller: _name,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _dose,
                      decoration: const InputDecoration(labelText: 'Dose (optional)'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text('Schedule times', style: TextStyle(fontWeight: FontWeight.w600)),
                        const Spacer(),
                        TextButton.icon(
                          onPressed: _addTime,
                          icon: const Icon(Icons.add),
                          label: const Text('Add time'),
                        ),
                      ],
                    ),
                    if (_times.isEmpty)
                      const Text('No times added yet', style: TextStyle(color: AppColors.textSoft)),
                    if (_times.isNotEmpty) const SizedBox(height: 8),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _times.asMap().entries.map((e) {
                        final t = e.value;
                        final label = _fmt(t);
                        return Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2F6FF),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: const Color(0xFFE0E7FF)),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.schedule, size: 18, color: AppColors.primary),
                              const SizedBox(width: 6),
                              Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
                              const SizedBox(width: 4),
                              InkWell(
                                onTap: () => _editTime(e.key),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.edit_outlined, size: 18, color: AppColors.textSoft),
                                ),
                              ),
                              InkWell(
                                onTap: () => setState(() => _times.removeAt(e.key)),
                                child: const Padding(
                                  padding: EdgeInsets.all(4.0),
                                  child: Icon(Icons.close, size: 18, color: Colors.redAccent),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ],
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
                      : Text(isEdit ? 'Save Changes' : 'Add Medicine'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _addTime() async {
    final t = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
    if (t != null) setState(() => _times.add(t));
  }

  Future<void> _editTime(int idx) async {
    final t = await showTimePicker(context: context, initialTime: _times[idx]);
    if (t != null) setState(() => _times[idx] = t);
  }

  Future<void> _submit(bool isEdit) async {
    if (!_form.currentState!.validate()) return;
    if (_times.isEmpty) {
      _err(context, 'Add at least one time');
      return;
    }
    setState(() => _saving = true);
    try {
      final repo = ref.read(medsRepoProvider);
      final uid = ref.read(uidProvider);
      if (uid == null) throw Exception('Not authenticated');

      final med = Medicine(
        id: widget.existing?.id ?? 'tmp',
        userId: uid,
        name: _name.text.trim(),
        dose: _dose.text.trim().isEmpty ? null : _dose.text.trim(),
        schedule: List.of(_times),
        createdAt: DateTime.now(),
      );

      late String medId;
      if (isEdit) {
        await repo.updateMed(widget.existing!.id, med);
        medId = widget.existing!.id;
        _ok(context, 'Medicine updated');
      } else {
        medId = await repo.addMed(uid, med);
        _ok(context, 'Medicine added');
      }

      // جدولة التنبيهات
      await NotificationService.cancelMedSchedule(medId);
      for (final t in _times) {
        await NotificationService.scheduleDailyMed(
          medId: medId,
          title: _name.text.trim(),
          body: _dose.text.trim(),
          hour: t.hour,
          minute: t.minute,
        );
      }

      if (mounted) Navigator.pop(context);
    } catch (e) {
      _err(context, e.toString());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  String _fmt(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}';
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

void _ok(BuildContext c, String msg) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg)));
}

void _err(BuildContext c, String msg) {
  ScaffoldMessenger.of(c).showSnackBar(SnackBar(content: Text(msg), backgroundColor: Colors.red));
}
