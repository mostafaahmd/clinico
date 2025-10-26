import 'package:supabase_flutter/supabase_flutter.dart';

class WeightRepository {
  WeightRepository(this._sb);
  final SupabaseClient _sb;

  Stream<List<Map<String, dynamic>>> streamWeights() {
    final uid = _sb.auth.currentUser?.id;
    if (uid == null) return const Stream.empty();
    return _sb.from('weight_entries')
      .stream(primaryKey: ['id'])
      .eq('user_id', uid)
      .order('at', ascending: false);
  }

  Future<void> addWeight(double kg, {DateTime? at, String? note}) async {
    final uid = _sb.auth.currentUser!.id;
    await _sb.from('weight_entries').insert({
      'user_id': uid,
      'weight_kg': kg,
      if (at != null) 'at': at.toIso8601String(),
      if (note != null && note.trim().isNotEmpty) 'note': note.trim(),
    });
  }

  Future<void> deleteEntry(String id) async {
    await _sb.from('weight_entries').delete().eq('id', id);
  }
}
