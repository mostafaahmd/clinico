// lib/app_router.dart
import 'package:clinico/core/services/prefs_service.dart';
import 'package:clinico/features/auth/presentation/screens/auth_page.dart';
import 'package:clinico/features/auth/presentation/screens/register_page.dart';
import 'package:clinico/features/auth/presentation/screens/forgot_password_page.dart';
import 'package:clinico/features/auth/presentation/screens/new_password_page.dart';
import 'package:clinico/features/auth/presentation/screens/verify_reset_page.dart';
import 'package:clinico/features/home/presentation/home_page.dart';
import 'package:clinico/features/meals/presentation/screens/meal_list_page.dart';
import 'package:clinico/features/meals/presentation/widgets/meal_form_page.dart';
import 'package:clinico/features/medicines/presentation/screens/medicine_list_page.dart';
import 'package:clinico/features/medicines/presentation/widgets/medicine_form_page.dart';
import 'package:clinico/features/onboarding/presentation/screens/onboarding_health_page.dart';
import 'package:clinico/features/progress/presentation/screens/progress_page.dart';
import 'package:clinico/features/settings/presentation/screens/settings_page.dart';
import 'package:clinico/features/weight/presentation/screens/weight_list_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'router_refresh.dart';

final _sb = Supabase.instance.client;

final appRouter = GoRouter(
  // نخلي البداية Route وسيطة تقرر لنا نروح فين
  initialLocation: '/decide',
  // يحدّث الراوتر عند تغيّر السيشن
  refreshListenable: GoRouterRefreshStream(_sb.auth.onAuthStateChange),
  routes: [
    // وسيط لتحديد وجهة البداية بعد السبلاتش
    GoRoute(path: '/decide', builder: (_, __) => const _DecideScreen()),

    // Auth
    GoRoute(path: '/login',    builder: (_, __) => const AuthPage()),
    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),
    GoRoute(path: '/forgot',   builder: (_, __) => const ForgotPasswordPage()),
    GoRoute(
      path: '/verify-reset',
      builder: (context, state) {
        final email = state.extra as String;
        return VerifyResetPage(email: email);
      },
    ),
    GoRoute(path: '/new-password', builder: (_, __) => const NewPasswordPage()),

    // Onboarding
    GoRoute(
      path: '/onboarding-health',
      builder: (_, __) => const OnboardingHealthPage(),
    ),

    // App
    GoRoute(path: '/home',          builder: (_, __) => const HomePage()),
    GoRoute(path: '/meal-plan',     builder: (_, __) => const MealListPage()),
    GoRoute(path: '/add-meal',      builder: (_, __) => const MealFormPage()),
    GoRoute(path: '/my-medicine',   builder: (_, __) => const MedicineListPage()),
    GoRoute(path: '/add-medicine',  builder: (_, __) => const MedicineFormPage()),
    GoRoute(path: '/progress',      builder: (_, __) => const ProgressPage()),
    GoRoute(path: '/settings',      builder: (_, __) => const SettingsPage()),
    GoRoute(path: '/my-weight',     builder: (_, __) => const WeightListPage()),
  ],

  // Guard/Redirect بسيط
  redirect: (context, state) {
    final session = _sb.auth.currentSession;

    // مسارات الأوث/البداية المسموح دخولها بدون سيشن
    final isAuthRoute = switch (state.uri.path) {
      '/login' ||
      '/register' ||
      '/forgot' ||
      '/verify-reset' ||
      '/new-password' ||
      '/onboarding-health' ||
      '/decide' => true,
      _ => false
    };

    // لو Logged-in ورايح لأي مسار Auth (غير /decide) → روح /home
    if (session != null && isAuthRoute && state.uri.path != '/decide') {
      return '/home';
    }

    // لو Not logged-in ورايح مسار محمي → خليه يعدّي على /decide
    if (session == null && !isAuthRoute) {
      return '/decide';
    }

    return null; // بدون تغيير
  },
);

// شاشة خفيفة لتقرير البداية (بعد السبلاتش النيتف)
class _DecideScreen extends StatefulWidget {
  const _DecideScreen();

  @override
  State<_DecideScreen> createState() => _DecideScreenState();
}

class _DecideScreenState extends State<_DecideScreen> {
  @override
  void initState() {
    super.initState();
    _decide();
  }

  Future<void> _decide() async {
    final session = Supabase.instance.client.auth.currentSession;
    final seen = await PrefsService().getOnboardingSeen();

    if (!mounted) return;

    if (session != null) {
      context.go('/home');
      return;
    }

    // مفيش سيشن
    if (seen) {
      context.go('/login');
    } else {
      context.go('/onboarding-health');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
