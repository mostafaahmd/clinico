// settings_page.dart
import 'package:clinico/core/theming/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool medsReminders = true;

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
            onChanged: (v) => setState(() => medsReminders = v),
          ),
          ListTile(
            title: const Text('Sign out'),
            trailing: const Icon(Icons.logout),
            onTap: () async {
              await Supabase.instance.client.auth.signOut();
              if (mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
