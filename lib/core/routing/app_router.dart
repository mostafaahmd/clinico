// app_router.dart
// تعريف المسارات الأساسية للتطبيق باستخدام GoRouter

import 'package:clinico/features/auth/presentation/screens/auth_page.dart';
import 'package:clinico/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// مبدئيًا: نبدأ من صفحة تسجيل الدخول
final appRouter = GoRouter(
  initialLocation: '/login',
  routes: [
    // شاشة تسجيل الدخول/التسجيل
    GoRoute(
      path: '/login',
      builder: (BuildContext context, GoRouterState state) => const AuthPage(),
    ),


    GoRoute(
      path: '/home',
      builder: (_, __) => const HomePage(),
    ),

    /*
    GoRoute(
      path: '/chat/:id',
      builder: (_, state) => ChatPage(chatId: int.parse(state.pathParameters['id']!)),
    ),
*/
  ],
);
