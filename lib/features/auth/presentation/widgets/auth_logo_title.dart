import 'package:clinico/core/theming/app_colors.dart';
import 'package:flutter/material.dart';

class AuthLogoTitle extends StatelessWidget {
  const AuthLogoTitle({super.key, required this.logoHeight, required this.titleSize});
  final double logoHeight;
  final double titleSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: logoHeight,
          child: Image.asset(
            'assets/logo_stethoscope.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(Icons.health_and_safety_rounded, size: 120, color: AppColors.blue),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Clinico',
          style: TextStyle(
            fontSize: titleSize,
            fontWeight: FontWeight.w800,
            color: AppColors.title,
            letterSpacing: 0.2,
            height: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Your smart health companion',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.subtitle,
                height: 1.4,
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
