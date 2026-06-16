import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/app_lock_cubit.dart';

class LockPage extends StatelessWidget {
  final String? message;
  const LockPage({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<AppLockCubit>();

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.lock, size: 80),
          const SizedBox(height: 24),
          const Text(
            'App Locked',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          if (message != null) ...[
            const SizedBox(height: 12),
            Text(
              message!,
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: cubit.unlock,
              child: const Text('Try Again'),
            ),
          ),
        ],
      ),
    );
  }
}