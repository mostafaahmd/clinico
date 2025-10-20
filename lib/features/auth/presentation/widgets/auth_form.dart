import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/core/widgets/rounded_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/providers.dart';
import 'package:go_router/go_router.dart';

class AuthForm extends ConsumerStatefulWidget {
  const AuthForm({super.key});
  @override
  ConsumerState<AuthForm> createState() => _AuthFormState();
}

class _AuthFormState extends ConsumerState<AuthForm> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _obscure = true;
  bool _isLogin = true;

  String? _validate() {
    final email = _email.text.trim();
    final pass = _pass.text;
    if (email.isEmpty || !email.contains('@')) return 'Please enter a valid email';
    if (pass.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> _submit() async {
    final err = _validate();
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    final ctrl = ref.read(authControllerProvider.notifier);
    final email = _email.text.trim();
    final pass = _pass.text;
    _isLogin ? await ctrl.signIn(email, pass) : await ctrl.signUp(email, pass);

    ref.read(authControllerProvider).when(
      data: (_) => context.go('/home'),
      loading: () {},
      error: (e, _) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);

    return Column(
      children: [
        RoundedTextField(
          controller: _email,
          label: 'Email',
          keyboardType: TextInputType.emailAddress,
          autofillHints: const [AutofillHints.email],
        ),
        const SizedBox(height: 14),
        RoundedTextField(
          controller: _pass,
          label: 'Password',
          obscureText: _obscure,
          autofillHints: const [AutofillHints.password],
          suffix: IconButton(
            onPressed: () => setState(() => _obscure = !_obscure),
            icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
          ),
        ),
        const SizedBox(height: 22),
        SizedBox(
          width: double.infinity,
          height: 56,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.blue,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
              foregroundColor: Colors.white,
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            onPressed: state.isLoading ? null : _submit,
            child: state.isLoading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : Text(_isLogin ? 'Login' : 'Create account'),
          ),
        ),
        const SizedBox(height: 18),
        // Toggle line
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              _isLogin ? "Don't have an account? " : "Already have an account? ",
              style: const TextStyle(color: AppColors.subtitle),
            ),
            GestureDetector(
              onTap: state.isLoading ? null : () => setState(() => _isLogin = !_isLogin),
              child: Text(
                _isLogin ? 'Sign up' : 'Login',
                style: const TextStyle(
                  color: AppColors.blue,
                  fontWeight: FontWeight.w700,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
