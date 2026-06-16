import 'package:clinico/features/home/presentation/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/app_lock_cubit.dart';
import '../cubit/app_lock_state.dart';
import 'enable_biometric_page.dart';
import 'lock_page.dart';

class SplashGatePage extends StatefulWidget {
  const SplashGatePage({super.key});

  @override
  State<SplashGatePage> createState() => _SplashGatePageState();
}

class _SplashGatePageState extends State<SplashGatePage> {
  @override
  void initState() {
    super.initState();
    context.read<AppLockCubit>().startup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<AppLockCubit, AppLockState>(
          builder: (context, state) {
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