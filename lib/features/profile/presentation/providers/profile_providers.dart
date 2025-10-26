import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final profileProvider = FutureProvider<Map<String, dynamic>?>((ref) async {
  final sb = Supabase.instance.client;
  final uid = sb.auth.currentUser?.id;
  if (uid == null) return null;
  return await sb.from('profiles').select().eq('id', uid).maybeSingle();
});
