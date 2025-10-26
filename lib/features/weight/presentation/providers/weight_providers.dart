import 'package:clinico/features/weight/data/weight_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final _sbProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final weightRepoProvider = Provider<WeightRepository>((ref) {
  return WeightRepository(ref.read(_sbProvider));
});

final weightStreamProvider = StreamProvider<List<Map<String, dynamic>>>((ref) {
  return ref.read(weightRepoProvider).streamWeights();
});
