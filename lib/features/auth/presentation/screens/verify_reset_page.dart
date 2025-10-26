import 'package:clinico/core/theming/app_colors.dart';
import 'package:clinico/core/widgets/rounded_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../provider/auth_providers.dart';

class VerifyResetPage extends ConsumerStatefulWidget {
  const VerifyResetPage({super.key, required this.email});
  final String email;

  @override
  ConsumerState<VerifyResetPage> createState() => _VerifyResetPageState();
}

class _VerifyResetPageState extends ConsumerState<VerifyResetPage> {
  final _code = TextEditingController();
  bool _loading = false;
  int _counter = 0;

  static const int _otpLen = 6;

  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    final code = _code.text.trim();
    if (code.length != _otpLen) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Code must be $_otpLen digits')),
      );
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authRepoProvider).verifyResetOtp(widget.email, code);
      if (!mounted) return;
      // بعد التحقق بقى فيه Session — روح على صفحة الباسورد
      context.push('/new-password');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(e.toString())));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _resend() async {
    setState(() => _counter = 60);
    try {
      await ref.read(authRepoProvider).sendResetOtp(widget.email);
    } catch (_) {}
    if (!mounted) return;
    Future.doWhile(() async {
      if (!mounted || _counter <= 0) return false;
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) setState(() => _counter--);
      return _counter > 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(title: const Text('Enter code')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'We sent a code to ${widget.email}',
              style: const TextStyle(color: AppColors.textSoft),
            ),
            const SizedBox(height: 12),
            RoundedTextField(
              controller: _code,
              label: 'Code',
              keyboardType: TextInputType.number,
              autofillHints: const [AutofillHints.oneTimeCode],
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(_otpLen),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: _loading ? null : _verify,
                child: _loading
                    ? const CircularProgressIndicator()
                    : const Text('Verify'),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: (_loading || _counter > 0) ? null : _resend,
              child: Text(_counter > 0 ? 'Resend in $_counter s' : 'Resend code'),
            ),
          ],
        ),
      ),
    );
  }
}




// // lib/features/auth/presentation/screens/verify_reset_page.dart
// import 'package:clinico/core/theming/app_colors.dart';
// import 'package:clinico/core/widgets/rounded_text_field.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:go_router/go_router.dart';
// import '../provider/providers.dart';

// class VerifyResetPage extends ConsumerStatefulWidget {
//   const VerifyResetPage({super.key, required this.email});
//   final String email;

//   @override
//   ConsumerState<VerifyResetPage> createState() => _VerifyResetPageState();
// }

// class _VerifyResetPageState extends ConsumerState<VerifyResetPage> {
//   final _code = TextEditingController();
//   bool _loading = false;
//   int _counter = 0;

//   static const int _otpLen = 6;

//   @override
//   void dispose() {
//     _code.dispose();
//     super.dispose();
//   }

//   Future<void> _verifyOnServer() async {
//     final code = _code.text.trim();
//     if (code.length != _otpLen) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Code must be $_otpLen digits')),
//       );
//       return;
//     }

//     setState(() => _loading = true);
//     try {
//       final sb = ref.read(supabaseProvider);
//       final res = await sb.functions.invoke(
//         'verify-otp',
//         body: {'email': widget.email, 'otp': code},
//       );

//       // Debug (اختياري):
//       // ignore: avoid_print
//       print('verify-otp status=${res.status} data=${res.data}');

//       final ok = res.status == 200 &&
//           (res.data is Map && (res.data as Map)['success'] == true);

//       if (!ok) {
//         throw Exception(res.data ?? 'Verification failed');
//       }

//       if (!mounted) return;
//       context.push('/new-password', extra: {'email': widget.email, 'otp': code});
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context)
//             .showSnackBar(SnackBar(content: Text(e.toString())));
//       }
//     } finally {
//       if (mounted) setState(() => _loading = false);
//     }
//   }

//   Future<void> _resend() async {
//     setState(() => _counter = 60);
//     try {
//       final sb = ref.read(supabaseProvider);
//       await sb.functions.invoke('send-otp', body: {'email': widget.email});
//     } catch (_) {}
//     // عدّاد بسيط
//     if (!mounted) return;
//     Future.doWhile(() async {
//       if (!mounted || _counter <= 0) return false;
//       await Future.delayed(const Duration(seconds: 1));
//       if (mounted) setState(() => _counter--);
//       return _counter > 0;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.bg,
//       appBar: AppBar(title: const Text('Enter code')),
//       body: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           children: [
//             Text(
//               'We sent a code to ${widget.email}',
//               style: const TextStyle(color: AppColors.subtitle),
//             ),
//             const SizedBox(height: 12),
//             RoundedTextField(
//               controller: _code,
//               label: 'Code',
//               keyboardType: TextInputType.number,
//               autofillHints: const [AutofillHints.oneTimeCode],
//               inputFormatters: [
//                 FilteringTextInputFormatter.digitsOnly,
//                 LengthLimitingTextInputFormatter(_otpLen),
//               ],
//             ),
//             const SizedBox(height: 16),
//             SizedBox(
//               width: double.infinity,
//               height: 52,
//               child: FilledButton(
//                 onPressed: _loading ? null : _verifyOnServer,
//                 child: _loading
//                     ? const CircularProgressIndicator()
//                     : const Text('Verify'),
//               ),
//             ),
//             const SizedBox(height: 12),
//             TextButton(
//               onPressed: (_loading || _counter > 0) ? null : _resend,
//               child: Text(_counter > 0 ? 'Resend in $_counter s' : 'Resend code'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
