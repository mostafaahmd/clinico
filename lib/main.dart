// lib/main.dart
// نقطة بدء التطبيق: نهيّئ Supabase + DI + الإشعارات، ثم نشغّل Riverpod + GoRouter.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/app_router.dart';          // تأكد إن initialLocation = '/gate'
import 'core/di/service_locator.dart';          // تسجيل الخدمات في get_it
import 'core/services/notification_service.dart'; // تهيئة Awesome Notifications

Future<void> main() async {
  // لازم قبل أي عمليات async
  WidgetsFlutterBinding.ensureInitialized();


  // قيم Supabase من --dart-define أو ملف env
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // تحقّق بسيط أثناء التطوير
  assert(
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
    'Missing SUPABASE_URL or SUPABASE_ANON_KEY. Pass them via --dart-define.',
  );

  // تهيئة Supabase
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
  authOptions: const FlutterAuthClientOptions(
    autoRefreshToken: true,
  ),
);


  // تهيئة الـ DI (get_it)
  await setupDi();

  // تهيئة قنوات الإشعارات وطلب الصلاحيات عند الحاجة
  await NotificationService.ensureInit();


  // شغّل التطبيق داخل ProviderScope (Riverpod)
  runApp(const ProviderScope(child: ClinicoApp()));
}

class ClinicoApp extends ConsumerWidget {
  const ClinicoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routerConfig: appRouter, // لازم الراوتر يحتوي '/gate' → يشوف السِشن ويوجه تلقائي
    );
  }
}
