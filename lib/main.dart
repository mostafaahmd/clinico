// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'core/routing/app_router.dart';        
import 'core/services/notification_service.dart'; 

Future<void> main() async {
  // init Flutter bindings
  WidgetsFlutterBinding.ensureInitialized();


  // supabase url
  const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  // supabase anon key
  const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  // make sure we have the necessary keys
  assert(
    supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty,
    'Missing SUPABASE_URL or SUPABASE_ANON_KEY. Pass them via --dart-define.',
  );

  // initialize Supabase client
await Supabase.initialize(
  url: supabaseUrl,
  anonKey: supabaseAnonKey,
  authOptions: const FlutterAuthClientOptions(
    autoRefreshToken: true,
  ),
);

  // initialize notification channels and request permissions when needed
  await NotificationService.ensureInit();


  // run the app within ProviderScope (Riverpod)
  runApp(const ProviderScope(child: ClinicoApp()));
}

class ClinicoApp extends ConsumerWidget {
  const ClinicoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true),
      routerConfig: router,
    );
  }
}
