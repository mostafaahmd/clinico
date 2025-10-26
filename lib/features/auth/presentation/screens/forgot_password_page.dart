import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/core/widgets/rounded_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_providers.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({super.key});
  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  final _email = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Forgot password')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            RoundedTextField(
              controller: _email,
              label: 'Email',
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              inputFormatters: const [],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  foregroundColor: Colors.white,
                ),
                onPressed: _loading
                    ? null
                    : () async {
                        final email = _email.text.trim();
                        if (!email.contains('@')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter a valid email')),
                          );
                          return;
                        }
                        setState(() => _loading = true);
                        try {
                          await ref.read(authRepoProvider).sendResetOtp(email);
                          if (!mounted) return;
                          context.push('/verify-reset', extra: email);
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        } finally {
                          if (mounted) setState(() => _loading = false);
                        }
                      },
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Send code'),
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
// import 'package:go_router/go_router.dart';
// import '../provider/providers.dart';

// class ForgotPasswordPage extends ConsumerStatefulWidget {
//   const ForgotPasswordPage({super.key});
//   @override
//   ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
// }

// class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
//   final _email = TextEditingController();
//   bool _loading = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       appBar: AppBar(title: const Text('Forgot password')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             RoundedTextField(
//               controller: _email,
//               label: 'Email',
//               keyboardType: TextInputType.emailAddress,
//               autofillHints: const [AutofillHints.email],
//               inputFormatters: const [],
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: FilledButton(
//                 style: FilledButton.styleFrom(
//                   backgroundColor: AppColors.blue,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.circular(16),
//                   ),
//                   foregroundColor: Colors.white,
//                 ),
//                 onPressed: _loading
//                     ? null
//                     : () async {
//                         final email = _email.text.trim();
//                         if (!email.contains('@')) {
//                           ScaffoldMessenger.of(context).showSnackBar(
//                             const SnackBar(content: Text('Please enter a valid email')),
//                           );
//                           return;
//                         }
//                         setState(() => _loading = true);
//                         try {
//                           await ref.read(authRepoProvider).sendResetOtp(email);
//                           if (!mounted) return;
//                           context.push('/verify-reset', extra: email);
//                         } catch (e) {
//                           if (mounted) {
//                             ScaffoldMessenger.of(context).showSnackBar(
//                               SnackBar(content: Text(e.toString())),
//                             );
//                           }
//                         } finally {
//                           if (mounted) setState(() => _loading = false);
//                         }
//                       },
//                 child: _loading
//                     ? const CircularProgressIndicator()
//                     : const Text('Send code'),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
