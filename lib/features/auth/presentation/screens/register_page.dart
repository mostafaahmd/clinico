import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/core/widgets/rounded_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../data/domain/registration_data.dart';
import '../provider/auth_providers.dart';

class RegisterPage extends ConsumerStatefulWidget {
  const RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _fullName = TextEditingController();
  final _phone = TextEditingController();
  String _gender = 'other';
  DateTime? _birth;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _fullName.dispose();
    _phone.dispose();
    super.dispose();
  }

  Future<void> _pickBirth() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year, now.month, now.day),
    );
    if (d != null) setState(() => _birth = d);
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;

    final data = RegistrationData(
      email: _email.text.trim(),
      password: _pass.text,
      fullName: _fullName.text.trim(),
      phone: _phone.text.trim().isEmpty ? null : _phone.text.trim(),
      gender: _gender,
      birthDate: _birth,
    );

    await ref.read(registerControllerProvider.notifier).register(data);

    ref.read(registerControllerProvider).when(
      data: (_) {
        // لو عندك email confirmation → ارجعه للوجين برسالة
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Account created. Please check your email to verify (if required).')),
        );
        context.go('/login');
      },
      loading: () {},
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerControllerProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Create account'),
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            RoundedTextField(
              controller: _fullName,
              label: 'Full name',
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
              inputFormatters: const [],
            ),
            const SizedBox(height: 12),
            RoundedTextField(
              controller: _email,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              validator: (v) => (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              inputFormatters: const [],
            ),
            const SizedBox(height: 12),
            RoundedTextField(
              controller: _pass,
              label: 'Password',
              obscureText: true,
              validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
              inputFormatters: const [],
            ),
            const SizedBox(height: 12),
            RoundedTextField(
              controller: _phone,
              label: 'Phone (optional)',
              keyboardType: TextInputType.phone,
              inputFormatters: const [],
            ),
            const SizedBox(height: 12),
            // Gender
            Row(
              children: [
                const Text('Gender', style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                DropdownButton<String>(
                  value: _gender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setState(() => _gender = v ?? 'other'),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _pickBirth,
                  icon: const Icon(Icons.cake_outlined),
                  label: Text(_birth == null
                      ? 'Birth date'
                      : '${_birth!.year}/${_birth!.month}/${_birth!.day}'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 56,
              child: FilledButton(
                onPressed: state.isLoading ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: state.isLoading
                    ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('Create account'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
