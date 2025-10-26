// lib/features/medicines/data/medicine_repository.dart
import 'package:clinico/core/providers/base_providers.dart';
import 'package:clinico/features/medicines/data/models/medicine_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final medsRepoProvider = Provider<MedicinesRepository>((ref) {
  return MedicinesRepository(ref.read(supabaseProvider));
});

class MedicinesRepository {
  MedicinesRepository(this._sb);
  final SupabaseClient _sb;

  Stream<List<Medicine>> streamMeds(String uid) {
    return _sb
        .from('medicines')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('created_at', ascending: false)
        .map((rows) => rows.map((r) => Medicine.fromMap(r)).toList());
  }

  /// رجّع id بعد الإضافة (عشان نربطه بالجدولة)
  Future<String> addMed(String uid, Medicine med) async {
    final inserted = await _sb
        .from('medicines')
        .insert({'user_id': uid, ...med.toInsert()})
        .select('id')
        .single();
    return inserted['id'] as String;
  }

  Future<void> updateMed(String id, Medicine med) async {
    await _sb.from('medicines').update(med.toInsert()).eq('id', id);
  }

  Future<void> deleteMed(String id) async {
    await _sb.from('medicines').delete().eq('id', id);
  }
}

final medsStreamProvider = StreamProvider.autoDispose<List<Medicine>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(medsRepoProvider).streamMeds(uid);
});
