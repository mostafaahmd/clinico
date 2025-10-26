import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Supabase client
final supabaseProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// اسم المستخدم لواجهة الترحيب.
/// الأولوية: profile.full_name -> user.email -> "Guest".
final displayNameProvider = FutureProvider<String>((ref) async {
  final sb = ref.read(supabaseProvider);
  final user = sb.auth.currentUser;
  if (user == null) return 'Guest';

  // لو عندك جدول profiles فيه full_name
  try {
    final data = await sb
        .from('profiles')
        .select('full_name')
        .eq('id', user.id)
        .maybeSingle();

    final fullName = (data?['full_name'] as String?)?.trim();
    if (fullName != null && fullName.isNotEmpty) return fullName;
  } catch (_) {
    // تجاهل لو مفيش جدول أو صلاحيات
  }

  // fallback على الإيميل
  final email = user.email ?? '';
  final namePart = email.split('@').first;
  return namePart.isEmpty ? 'Guest' : namePart[0].toUpperCase() + namePart.substring(1);
});

/// تبويب البوتوم بار
final navIndexProvider = StateProvider<int>((_) => 0);
