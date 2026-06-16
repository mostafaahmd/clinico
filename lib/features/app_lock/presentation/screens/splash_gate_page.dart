import 'package:clinico/core/providers/app_lock_controller.dart';
import 'package:clinico/features/app_lock/presentation/cubit/app_lock_state.dart';
import 'package:clinico/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'enable_biometric_page.dart';
import 'lock_page.dart';

class SplashGatePage extends ConsumerStatefulWidget {
  const SplashGatePage({super.key});

  @override
  ConsumerState<SplashGatePage> createState() => _SplashGatePageState();
}

class _SplashGatePageState extends ConsumerState<SplashGatePage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      ref.read(appLockControllerProvider.notifier).startup();
    });
  }

  @override
  Widget build(BuildContext context) {
    final lockState = ref.watch(appLockControllerProvider);

    return Scaffold(
      body: Center(
        child: lockState.when(
          loading: () => const CircularProgressIndicator(),
          error: (error, stackTrace) {
            return LockPage(message: error.toString());
          },
          data: (state) {
            if (state is AppLockNeedEnable) {
              return const EnableBiometricPage();
            }

            if (state is AppLockUnlocked) {
              return const HomePage();
            }

            if (state is AppLockLocked) {
              return LockPage(message: state.message);
            }

            if (state is AppLockUnavailable) {
              return LockPage(message: state.message);
            }

            return const CircularProgressIndicator();
          },
        ),
      ),
    );
  }
}