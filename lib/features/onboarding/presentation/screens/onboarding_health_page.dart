import 'dart:convert';
import 'package:clinico/core/theming/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class OnboardingHealthPage extends StatefulWidget {
  const OnboardingHealthPage({super.key});

  @override
  State<OnboardingHealthPage> createState() => _OnboardingHealthPageState();
}

class _OnboardingHealthPageState extends State<OnboardingHealthPage> {
  final _form = GlobalKey<FormState>();
  final _height = TextEditingController();
  final _weight = TextEditingController();
  final _target = TextEditingController();

  String _activity = 'sedentary';
  String _goal = 'maintain';

  final _conditions = <String>{};
  final _allergies = <String>{};
  final _dietPrefs = <String>{};

  bool _saving = false;

  final _ALL_CONDITIONS = const ['diabetes', 'hypertension', 'thyroid', 'cardiac'];
  final _ALL_ALLERGIES  = const ['lactose', 'gluten', 'nuts', 'seafood', 'egg'];
  final _ALL_DIETS      = const ['vegetarian', 'vegan', 'keto', 'low_carb', 'low_fodmap'];

  @override
  void dispose() {
    _height.dispose();
    _weight.dispose();
    _target.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;

    final sb = Supabase.instance.client;
    final uid = sb.auth.currentUser?.id;

    setState(() => _saving = true);
    try {
      final h = double.tryParse(_height.text.trim());
      final w = double.tryParse(_weight.text.trim());
      final t = _target.text.trim().isEmpty ? null : double.tryParse(_target.text.trim());

      if (uid == null) {
        await _cachePendingHealth(
          heightCm: h,
          weightKg: w,
          targetWeightKg: t,
          activityLevel: _activity,
          goal: _goal,
          conditions: _conditions.toList(),
          allergies: _allergies.toList(),
          dietPrefs: _dietPrefs.toList(),
        );
        await _setOnboardingSeen();
        if (!mounted) return;
        context.go('/register');
        return;
      }

      await sb.from('profiles').update({
        if (h != null) 'height_cm': h,
        if (w != null) 'weight_kg': w,
        'activity_level': _activity,
        'goal': _goal,
        if (t != null) 'target_weight_kg': t,
        if (_conditions.isNotEmpty) 'conditions': _conditions.toList(),
        if (_allergies.isNotEmpty)  'allergies':  _allergies.toList(),
        if (_dietPrefs.isNotEmpty)  'diet_prefs': _dietPrefs.toList(),
      }).eq('id', uid);

      await _setOnboardingSeen();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved!')),
      );
      context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _cachePendingHealth({
    double? heightCm,
    double? weightKg,
    double? targetWeightKg,
    required String activityLevel,
    required String goal,
    required List<String> conditions,
    required List<String> allergies,
    required List<String> dietPrefs,
  }) async {
    final p = await SharedPreferences.getInstance();
    final payload = {
      if (heightCm != null) 'height_cm': heightCm,
      if (weightKg != null) 'weight_kg': weightKg,
      'activity_level': activityLevel,
      'goal': goal,
      if (targetWeightKg != null) 'target_weight_kg': targetWeightKg,
      if (conditions.isNotEmpty) 'conditions': conditions,
      if (allergies.isNotEmpty) 'allergies': allergies,
      if (dietPrefs.isNotEmpty) 'diet_prefs': dietPrefs,
    };
    await p.setString('pending_health', jsonEncode(payload));
  }

  Future<void> _setOnboardingSeen() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool('onboarding_seen', true);
  }

  @override
  Widget build(BuildContext context) {
    final maxW = MediaQuery.sizeOf(context).width;
    final twoCols = maxW >= 560; // Responsive: رقم بسيط عشان الأجهزة الواسعة

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Health Profile'),
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              // المقاسات
              _SectionCard(
                title: 'Body metrics',
                child: twoCols
                    ? Row(
                        children: [
                          Expanded(
                            child: _UnitField(
                              controller: _height,
                              label: 'Height',
                              unit: 'cm',
                              icon: Icons.height_rounded,
                              min: 80,
                              max: 260,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _UnitField(
                              controller: _weight,
                              label: 'Weight',
                              unit: 'kg',
                              icon: Icons.monitor_weight_outlined,
                              min: 20,
                              max: 400,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          _UnitField(
                            controller: _height,
                            label: 'Height',
                            unit: 'cm',
                            icon: Icons.height_rounded,
                            min: 80,
                            max: 260,
                          ),
                          const SizedBox(height: 12),
                          _UnitField(
                            controller: _weight,
                            label: 'Weight',
                            unit: 'kg',
                            icon: Icons.monitor_weight_outlined,
                            min: 20,
                            max: 400,
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 12),

              // النشاط
              _SectionCard(
                title: 'Activity level',
                child: _ChoiceGrid(
                  value: _activity,
                  onChanged: (v) => setState(() => _activity = v),
                  options: const [
                    ChoiceOpt('sedentary', 'Sedentary', Icons.chair_alt_outlined),
                    ChoiceOpt('light', 'Light', Icons.directions_walk),
                    ChoiceOpt('moderate', 'Moderate', Icons.hiking),
                    ChoiceOpt('active', 'Active', Icons.fitness_center),
                    ChoiceOpt('very_active', 'Very active', Icons.directions_run),
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // الهدف
              _SectionCard(
                title: 'Goal',
                child: _SegmentPills(
                  value: _goal,
                  options: const {
                    'lose': 'Lose',
                    'maintain': 'Maintain',
                    'gain': 'Gain',
                  },
                  onChanged: (v) => setState(() => _goal = v),
                ),
              ),
              const SizedBox(height: 12),

              // الهدف الوزني (اختياري)
              _SectionCard(
                title: 'Target weight (optional)',
                child: _UnitField(
                  controller: _target,
                  label: 'Target weight',
                  unit: 'kg',
                  icon: Icons.flag_outlined,
                  min: 20,
                  max: 400,
                  required: false,
                ),
              ),
              const SizedBox(height: 12),

              // Conditions / Allergies / Diet
              _SectionCard(
                title: 'Conditions',
                child: _MultiChipGroup(
                  all: _ALL_CONDITIONS,
                  selected: _conditions,
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: 'Allergies',
                child: _MultiChipGroup(
                  all: _ALL_ALLERGIES,
                  selected: _allergies,
                ),
              ),
              const SizedBox(height: 10),
              _SectionCard(
                title: 'Diet preferences',
                child: _MultiChipGroup(
                  all: _ALL_DIETS,
                  selected: _dietPrefs,
                ),
              ),
              const SizedBox(height: 22),

              // زرار
              SizedBox(
                height: 52,
                child: FilledButton(
                  onPressed: _saving ? null : _save,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _saving
                      ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Text('Save & continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ======= UI Helpers =======

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9EEF9)),
        boxShadow: const [
          BoxShadow(color: Color(0x0F000000), blurRadius: 14, offset: Offset(0, 6)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _UnitField extends StatelessWidget {
  const _UnitField({
    required this.controller,
    required this.label,
    required this.unit,
    required this.icon,
    required this.min,
    required this.max,
    this.required = true,
  });

  final TextEditingController controller;
  final String label;
  final String unit;
  final IconData icon;
  final double min;
  final double max;
  final bool required;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9.]'))],
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixText: unit,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
      validator: (v) {
        if (!required && (v == null || v.trim().isEmpty)) return null;
        final d = double.tryParse(v?.trim() ?? '');
        if (d == null) return 'Enter a number';
        if (d < min || d > max) return 'Range: $min–$max';
        return null;
      },
    );
  }
}

class ChoiceOpt {
  final String value;
  final String label;
  final IconData icon;
  const ChoiceOpt(this.value, this.label, this.icon);
}

class _ChoiceGrid extends StatelessWidget {
  const _ChoiceGrid({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final List<ChoiceOpt> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, c) {
      final isWide = c.maxWidth > 520;
      final cross = isWide ? 5 : 3;

      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: options.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cross,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: 1.05,
        ),
        itemBuilder: (_, i) {
          final opt = options[i];
          final sel = opt.value == value;
          return InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => onChanged(opt.value),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: sel ? const Color(0xFFEEF2FF) : Colors.white,
                border: Border.all(color: sel ? AppColors.primary : const Color(0xFFE7ECF7)),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(opt.icon, color: sel ? AppColors.primary : const Color(0xFF94A3B8)),
                  const SizedBox(height: 8),
                  Text(
                    opt.label,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: sel ? AppColors.primary : const Color(0xFF334155),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    });
  }
}

class _SegmentPills extends StatelessWidget {
  const _SegmentPills({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String value;
  final Map<String, String> options;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.entries.map((e) {
        final sel = e.key == value;
        return ChoiceChip(
          label: Text(e.value, style: const TextStyle(fontWeight: FontWeight.w600)),
          selected: sel,
          onSelected: (_) => onChanged(e.key),
          selectedColor: const Color(0xFFEEF2FF),
          labelStyle: TextStyle(color: sel ? AppColors.primary : const Color(0xFF334155)),
          side: BorderSide(color: sel ? AppColors.primary : const Color(0xFFE7ECF7)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
          backgroundColor: Colors.white,
        );
      }).toList(),
    );
  }
}

class _MultiChipGroup extends StatefulWidget {
  const _MultiChipGroup({required this.all, required this.selected});
  final List<String> all;
  final Set<String> selected;

  @override
  State<_MultiChipGroup> createState() => _MultiChipGroupState();
}

class _MultiChipGroupState extends State<_MultiChipGroup> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.all.map((v) {
        final sel = widget.selected.contains(v);
        return FilterChip(
          label: Text(v),
          selected: sel,
          onSelected: (s) => setState(() {
            if (s) {
              widget.selected.add(v);
            } else {
              widget.selected.remove(v);
            }
          }),
          selectedColor: const Color(0xFFEEF2FF),
          labelStyle: TextStyle(
            fontWeight: FontWeight.w600,
            color: sel ? AppColors.primary : const Color(0xFF334155),
          ),
          side: BorderSide(color: sel ? AppColors.primary : const Color(0xFFE7ECF7)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          visualDensity: VisualDensity.compact,
        );
      }).toList(),
    );
  }
}
