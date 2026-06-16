import 'package:clinico/core/providers/app_lock_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EnableBiometricPage extends ConsumerWidget {
  const EnableBiometricPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lockState = ref.watch(appLockControllerProvider);
    final isLoading = lockState.isLoading;

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
              onPressed: isLoading
                  ? null
                  : () {
                      ref
                          .read(appLockControllerProvider.notifier)
                          .enableBiometric();
                    },
              child: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Enable'),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: isLoading
                  ? null
                  : () {
                      ref
                          .read(appLockControllerProvider.notifier)
                          .skipBiometric();
                    },
              child: const Text('Skip'),
            ),
          ),
        ],
      ),
    );
  }
}