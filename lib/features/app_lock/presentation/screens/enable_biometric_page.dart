import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/app_lock_cubit.dart';

class EnableBiometricPage extends StatelessWidget {
  const EnableBiometricPage({super.key});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppLockCubit>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fingerprint, size: 80),
          const SizedBox(height: 24),
          const Text(
            'Enable biometric lock for this app',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'This will protect access to the app using Face ID or fingerprint.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cubit.enableBiometric,
              child: const Text('Enable'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: cubit.skipBiometric,
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}