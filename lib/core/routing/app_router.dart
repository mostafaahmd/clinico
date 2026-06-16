// lib/core/routing/app_router.dart

import 'dart:async';

import 'package:clinico/core/providers/base_providers.dart';
import 'package:clinico/core/security/biometric_auth_service.dart';
import 'package:clinico/features/app_lock/presentation/screens/lock_page.dart';
import 'package:clinico/features/auth/presentation/screens/auth_page.dart';
import 'package:clinico/features/auth/presentation/screens/forgot_password_page.dart';
import 'package:clinico/features/auth/presentation/screens/new_password_page.dart';
import 'package:clinico/features/auth/presentation/screens/register_page.dart';
import 'package:clinico/features/auth/presentation/screens/verify_reset_page.dart';
import 'package:clinico/features/doctors/provider/doctors_providers.dart';
import 'package:clinico/features/home/presentation/home_page.dart';
import 'package:clinico/features/meals/presentation/screens/meal_list_page.dart';
import 'package:clinico/features/meals/presentation/widgets/meal_form_page.dart';
import 'package:clinico/features/medicine/presentation/medicines_page.dart';
import 'package:clinico/features/medicines/presentation/screens/medicine_list_page.dart';
import 'package:clinico/features/medicines/presentation/widgets/medicine_form_page.dart';
import 'package:clinico/features/onboarding/presentation/screens/onboarding_health_page.dart';
import 'package:clinico/features/progress/presentation/screens/progress_page.dart';
import 'package:clinico/features/settings/presentation/screens/settings_page.dart';
import 'package:clinico/features/voice/presentation/screens/voice_assisstant_page.dart';
import 'package:clinico/features/weight/presentation/screens/weight_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  final supabase = ref.watch(supabaseProvider);

  final refreshNotifier = _RouterRefreshNotifier();

  final authSubscription = supabase.auth.onAuthStateChange.listen((_) {
    refreshNotifier.refresh();
  });

  ref.listen<bool>(appLockSessionProvider, (previous, next) {
    refreshNotifier.refresh();
  });

  ref.onDispose(() {
    authSubscription.cancel();
    refreshNotifier.dispose();
  });

  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.decide,
    refreshListenable: refreshNotifier,
    routes: [
      GoRoute(
        path: AppRoutes.decide,
        builder: (_, __) => const _DecideScreen(),
      ),

      // Auth
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const AuthPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        builder: (_, __) => const RegisterPage(),
      ),
      GoRoute(
        path: AppRoutes.forgot,
        builder: (_, __) => const ForgotPasswordPage(),
      ),
      GoRoute(
        path: AppRoutes.verifyReset,
        builder: (context, state) {
          final email = state.extra;

          if (email is! String || email.trim().isEmpty) {
            return const AuthPage();
          }

          return VerifyResetPage(email: email);
        },
      ),
      GoRoute(
        path: AppRoutes.newPassword,
        builder: (_, __) => const NewPasswordPage(),
      ),

      // Onboarding
      GoRoute(
        path: AppRoutes.onboardingHealth,
        builder: (_, __) => const OnboardingHealthPage(),
      ),

      // Lock
      GoRoute(
        path: AppRoutes.lock,
        builder: (_, __) => const Scaffold(
          body: Center(
            child: LockPage(),
          ),
        ),
      ),

      // App
      GoRoute(
        path: AppRoutes.home,
        builder: (_, __) => const HomePage(),
      ),
      GoRoute(
        path: AppRoutes.mealPlan,
        builder: (_, __) => const MealListPage(),
      ),
      GoRoute(
        path: AppRoutes.addMeal,
        builder: (_, __) => const MealFormPage(),
      ),
      GoRoute(
        path: AppRoutes.myMedicine,
        builder: (_, __) => const MedicineListPage(),
      ),
      GoRoute(
        path: AppRoutes.addMedicine,
        builder: (_, __) => const MedicineFormPage(),
      ),
      GoRoute(
        path: AppRoutes.progress,
        builder: (_, __) => const ProgressPage(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        builder: (_, __) => const SettingsPage(),
      ),
      GoRoute(
        path: AppRoutes.myWeight,
        builder: (_, __) => const WeightListPage(),
      ),
      GoRoute(
        path: AppRoutes.voice,
        builder: (_, __) => const VoiceAssistantPage(),
      ),
      GoRoute(
        path: AppRoutes.doctors,
        builder: (_, __) => const DoctorsPage(),
      ),
      GoRoute(
        path: AppRoutes.medicines,
        builder: (_, __) => const MedicinesPage(),
      ),
    ],
    redirect: (context, state) {
      final session = supabase.auth.currentSession;
      final unlocked = ref.read(appLockSessionProvider);
      final path = state.uri.path;

      final isAuthRoute = _authRoutes.contains(path);
      final isDecisionRoute = path == AppRoutes.decide;
      final isLockRoute = path == AppRoutes.lock;
      final isOnboardingRoute = path == AppRoutes.onboardingHealth;

      final isPublicRoute = isAuthRoute ||
          isDecisionRoute ||
          isLockRoute ||
          isOnboardingRoute;

      // User is not authenticated.
      // Protected routes must go through /decide.
      if (session == null) {
        if (!isPublicRoute || isLockRoute) {
          return AppRoutes.decide;
        }

        return null;
      }

      // User is authenticated but app-lock is not unlocked.
      // Only /decide and /lock are allowed until unlock succeeds.
      if (!unlocked) {
        if (!isDecisionRoute && !isLockRoute) {
          return AppRoutes.decide;
        }

        return null;
      }

      // User is authenticated and unlocked.
      // Do not let them go back to auth/onboarding/lock/decide pages.
      if (isPublicRoute) {
        return AppRoutes.home;
      }

      return null;
    },
  );
});

class AppRoutes {
  const AppRoutes._();

  static const decide = '/decide';

  static const login = '/login';
  static const register = '/register';
  static const forgot = '/forgot';
  static const verifyReset = '/verify-reset';
  static const newPassword = '/new-password';

  static const onboardingHealth = '/onboarding-health';

  static const lock = '/lock';

  static const home = '/home';
  static const mealPlan = '/meal-plan';
  static const addMeal = '/add-meal';
  static const myMedicine = '/my-medicine';
  static const addMedicine = '/add-medicine';
  static const progress = '/progress';
  static const settings = '/settings';
  static const myWeight = '/my-weight';
  static const voice = '/voice';
  static const doctors = '/doctors';
  static const medicines = '/medicines';
}

const _authRoutes = <String>{
  AppRoutes.login,
  AppRoutes.register,
  AppRoutes.forgot,
  AppRoutes.verifyReset,
  AppRoutes.newPassword,
};

class _RouterRefreshNotifier extends ChangeNotifier {
  void refresh() {
    notifyListeners();
  }
}

class _DecideScreen extends ConsumerStatefulWidget {
  const _DecideScreen();

  @override
  ConsumerState<_DecideScreen> createState() => _DecideScreenState();
}

class _DecideScreenState extends ConsumerState<_DecideScreen> {
  @override
  void initState() {
    super.initState();

    Future.microtask(_decide);
  }

  Future<void> _decide() async {
    final supabase = ref.read(supabaseProvider);
    final prefs = ref.read(prefsServiceProvider);
    final vault = ref.read(appLockVaultProvider);
    final biometric = ref.read(biometricAuthServiceProvider);
    final lockSession = ref.read(appLockSessionProvider.notifier);

    try {
      final session = supabase.auth.currentSession;
      final onboardingSeen = await prefs.getOnboardingSeen();

      if (!mounted) return;

      if (session == null) {
        lockSession.reset();

        if (onboardingSeen) {
          context.go(AppRoutes.login);
        } else {
          context.go(AppRoutes.onboardingHealth);
        }

        return;
      }

      final biometricEnabled = await vault.isBiometricEnabled();

      if (!mounted) return;

      if (!biometricEnabled) {
        lockSession.markUnlocked();
        context.go(AppRoutes.home);
        return;
      }

      final result = await biometric.authenticate();

      if (!mounted) return;

      switch (result) {
        case BiometricResult.success:
          lockSession.markUnlocked();
          context.go(AppRoutes.home);
          return;

        case BiometricResult.unavailable:
        case BiometricResult.failed:
        case BiometricResult.canceled:
        case BiometricResult.lockedOut:
          lockSession.reset();
          context.go(AppRoutes.lock);
          return;
      }
    } catch (_) {
      if (!mounted) return;

      lockSession.reset();
      context.go(AppRoutes.lock);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}