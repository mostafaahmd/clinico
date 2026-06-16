import 'package:clinico/core/providers/base_providers.dart';
import 'package:clinico/core/theming/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({super.key});

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  bool medsReminders = true;

  @override
  void initState() {
    super.initState();

    Future.microtask(_init);
  }

  Future<void> _init() async {
    final vault = ref.read(appLockVaultProvider);

    await vault.setBiometricEnabled(true);
  }

  Future<void> _signOut() async {
    final navigator = Navigator.of(context);
    final supabase = ref.read(supabaseProvider);
    final lockSession = ref.read(appLockSessionProvider.notifier);

    await supabase.auth.signOut();

    lockSession.reset();

    if (!mounted) return;

    navigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Medicine reminders'),
            value: medsReminders,
            onChanged: (value) {
              setState(() {
                medsReminders = value;
              });
            },
          ),
          ListTile(
            title: const Text('Sign out'),
            trailing: const Icon(Icons.logout),
            onTap: _signOut,
          ),
        ],
      ),
    );
  }
}