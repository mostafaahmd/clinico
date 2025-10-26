import 'package:flutter/material.dart';
import 'package:clinico/core/theming/app_colors.dart';

/// Capsule لأيقونة داخل مربع بزوايا ناعمة
class IconCapsule extends StatelessWidget {
  const IconCapsule({
    super.key,
    required this.icon,
    this.size = 52,
    this.radius = 14,
    this.background,
    this.iconColor,
  });

  final IconData icon;
  final double size;
  final double radius;
  final Color? background;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background ?? const Color(0xFFF2F6FF),
        borderRadius: BorderRadius.circular(radius),
      ),
      child: Icon(icon, color: iconColor ?? AppColors.primary),
    );
  }
}

/// زر إضافة أساسي (Extended FAB) بنفس ستايل الأب
class PrimaryFAB extends StatelessWidget {
  const PrimaryFAB({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.add,
  });

  final String label;
  final VoidCallback onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: onPressed,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      icon: Icon(icon),
    );
  }
}

/// حالة فارغة أنيقة مع أيقونة ورسالة
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.title,
    required this.message,
    required this.icon,
  });

  final String title;
  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 56, color: AppColors.primary),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSoft),
            ),
          ],
        ),
      ),
    );
  }
}
