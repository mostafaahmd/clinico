import 'package:clinico/core/theming/app_colors.dart';
import 'package:flutter/material.dart';
import '../widgets/auth_logo_title.dart';
import '../widgets/auth_form.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final logoH = w < 360 ? 140.0 : 170.0;
    final titleSize = w < 360 ? 36.0 : 42.0;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 12),
                  AuthLogoTitle(logoHeight: logoH, titleSize: titleSize),
                  const SizedBox(height: 28),
                  const AuthForm(),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
