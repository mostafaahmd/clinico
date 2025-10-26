import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/core/widgets/rounded_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../provider/auth_providers.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

class NewPasswordPage extends ConsumerStatefulWidget {
  const NewPasswordPage({super.key});

  @override
  ConsumerState<NewPasswordPage> createState() => _NewPasswordPageState();
}

class _NewPasswordPageState extends ConsumerState<NewPasswordPage> {
  final _pass = TextEditingController();
  final _confirm = TextEditingController();
  bool _obscure1 = true;
  bool _obscure2 = true;
  bool _loading = false;

  static const int _minLen = 8;

  @override
  void dispose() {
    _pass.dispose();
    _confirm.dispose();
    super.dispose();
  }

  String? _localValidate(String p, String c) {
    if (p.isEmpty) return 'Password is required';
    if (p.contains(' ')) return 'Password must not contain spaces';
    if (p.length < _minLen) return 'Password must be at least $_minLen characters';
    if (p != c) return 'Passwords do not match';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('New password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            RoundedTextField(
              controller: _pass,
              label: 'New password',
              obscureText: _obscure1,
              autofillHints: const [AutofillHints.newPassword],
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              suffix: IconButton(
                onPressed: () => setState(() => _obscure1 = !_obscure1),
                icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            const SizedBox(height: 12),
            RoundedTextField(
              controller: _confirm,
              label: 'Confirm password',
              obscureText: _obscure2,
              autofillHints: const [AutofillHints.newPassword],
              inputFormatters: [
                FilteringTextInputFormatter.deny(RegExp(r'\s')),
              ],
              suffix: IconButton(
                onPressed: () => setState(() => _obscure2 = !_obscure2),
                icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _loading
                    ? null
                    : () async {
                        final pass = _pass.text;
                        final confirm = _confirm.text;

                        final localErr = _localValidate(pass, confirm);
                        if (localErr != null) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text(localErr)));
                          return;
                        }

                        setState(() => _loading = true);
                        try {
                          await ref.read(authRepoProvider).setNewPassword(pass);
                          if (!mounted) return;
                          context.go('/login');
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Password changed. Please login.')),
                          );
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context)
                                .showSnackBar(SnackBar(content: Text(e.toString())));
                          }
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: _loading ? const CircularProgressIndicator() : const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}








// import 'package:clinico/core/theming/app_colors.dart';
// import 'package:clinico/core/widgets/rounded_text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:flutter/services.dart';
// import 'package:go_router/go_router.dart';
// import '../provider/providers.dart';

// class NewPasswordPage extends ConsumerStatefulWidget {
//   const NewPasswordPage({super.key, this.email, this.otp});
//   final String? email;
//   final String? otp;

//   @override
//   ConsumerState<NewPasswordPage> createState() => _NewPasswordPageState();
// }

// class _NewPasswordPageState extends ConsumerState<NewPasswordPage> {
//   final _pass = TextEditingController();
//   final _confirm = TextEditingController();
//   bool _obscure1 = true;
//   bool _obscure2 = true;
//   bool _loading = false;

//   static const int _minLen = 8; // طابق إعداد Supabase Auth → Email → Min length

//   @override
//   void dispose() {
//     _pass.dispose();
//     _confirm.dispose();
//     super.dispose();
//   }

//   String? _localValidate(String p, String c) {
//     if (p.isEmpty) return 'Password is required';
//     if (p.contains(' ')) return 'Password must not contain spaces';
//     if (p.length < _minLen) return 'Password must be at least $_minLen characters';
//     if (p != c) return 'Passwords do not match';
//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {
//     final extras = GoRouterState.of(context).extra as Map<String, dynamic>?;
//     final email = widget.email ?? extras?['email'] as String?;
//     final otp   = widget.otp   ?? extras?['otp'] as String?;

//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       appBar: AppBar(title: const Text('New password')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             RoundedTextField(
//               controller: _pass,
//               label: 'New password',
//               obscureText: _obscure1,
//               autofillHints: const [AutofillHints.newPassword],
//               inputFormatters: [
//                 // اختياري: امنع المسافات
//                 FilteringTextInputFormatter.deny( RegExp(r'\s')),
//               ],
//               suffix: IconButton(
//                 onPressed: () => setState(() => _obscure1 = !_obscure1),
//                 icon: Icon(_obscure1 ? Icons.visibility_off : Icons.visibility),
//               ),
//             ),
//             const SizedBox(height: 12),
//             RoundedTextField(
//               controller: _confirm,
//               label: 'Confirm password',
//               obscureText: _obscure2,
//               autofillHints: const [AutofillHints.newPassword],
//               inputFormatters: [
//                 FilteringTextInputFormatter.deny( RegExp(r'\s')),
//               ],
//               suffix: IconButton(
//                 onPressed: () => setState(() => _obscure2 = !_obscure2),
//                 icon: Icon(_obscure2 ? Icons.visibility_off : Icons.visibility),
//               ),
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: FilledButton(
//                 onPressed: _loading
//                     ? null
//                     : () async {
//                         final pass = _pass.text;
//                         final confirm = _confirm.text;

//                         final localErr = _localValidate(pass, confirm);
//                         if (localErr != null) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             SnackBar(content: Text(localErr)),
//                           );
//                           return;
//                         }
//                         if (email == null || otp == null) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Missing email or OTP')),
//                           );
//                           return;
//                         }

//                         setState(() => _loading = true);
//                         try {
//                           final sb = ref.read(supabaseProvider);
//                           final res = await sb.functions.invoke(
//                             'set-new-password',
//                             body: {
//                               'email': email,
//                               'otp': otp,
//                               'new_password': pass,
//                             },
//                           );

//                           // Debug: اطبع الرد عشان تشوف التفاصيل لو في خطأ
//                           // ignore: avoid_print
//                           print('set-new-password status=${res.status} data=${res.data}');

//                           if (res.status != 200) {
//                             // نحاول نطلع رسالة واضحة من الرد
//                             String message = 'Failed to set new password';
//                             final data = res.data;
//                             if (data is Map && data['error'] != null) {
//                               message = data['error'].toString();
//                             } else if (data is String && data.isNotEmpty) {
//                               message = data;
//                             }
//                             throw Exception(message);
//                           }

//                           if (!mounted) return;
//                           context.go('/login');
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Password changed. Please login.')),
//                           );
//                         } catch (e) {
//                           if (mounted) {
//                             ScaffoldMessenger.of(context)
//                                 .showSnackBar(SnackBar(content: Text(e.toString())));
//                           }
//                         } finally {
//                           if (mounted) setState(() => _loading = false);
//                         }
//                       },
//                 child: _loading ? const CircularProgressIndicator() : const Text('Save'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
