// service_locator.dart
// ملف حقن الاعتمادية (Dependency Injection) — كل الخدمات/الريبو تتسجّل هنا.

import 'package:clinico/features/auth/data/repo/auth_repository_impl.dart';
import 'package:clinico/features/auth/data/domain/auth_repository.dart';
import 'package:get_it/get_it.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../services/supabase_service.dart';
import '../services/notification_service.dart';
import '../services/prefs_service.dart';


final sl = GetIt.instance; // Service Locator

Future<void> setupDi() async {
  // External clients
  sl.registerLazySingleton<SupabaseClient>(() => Supabase.instance.client);

  // Services (طبقة عامة يعاد استخدامها)
  sl.registerLazySingleton(() => SupabaseService(sl<SupabaseClient>()));
  sl.registerLazySingleton(() => NotificationService());
  sl.registerLazySingleton(() => PrefsService());

  // Repositories (تتعامل مع الـ services/clients وتخدم الـ domain)
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl<SupabaseService>()));

  // TODO: لاحقًا — سجّل chatRepo, medsRepo, appointmentsRepo … إلخ
}
