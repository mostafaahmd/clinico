import 'package:clinico/core/providers/base_providers.dart';
import 'package:clinico/features/meals/data/models/meal_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
final mealsRepoProvider = Provider<MealsRepository>((ref) {
  return MealsRepository(ref.read(supabaseProvider));
});

class MealsRepository {
  MealsRepository(this._sb);
  final SupabaseClient _sb;

  Stream<List<Meal>> streamMeals(String uid) {
    return _sb
        .from('meals')
        .stream(primaryKey: ['id'])
        .eq('user_id', uid)
        .order('time', ascending: false)
        .map((rows) => rows.map((r) => Meal.fromMap(r)).toList());
  }

  Future<void> addMeal(String uid, Meal meal) async {
    await _sb.from('meals').insert({
      'user_id': uid,
      ...meal.toInsert(),
    });
  }

  Future<void> updateMeal(String id, Meal meal) async {
    await _sb.from('meals').update(meal.toInsert()).eq('id', id);
  }

  Future<void> deleteMeal(String id) async {
    await _sb.from('meals').delete().eq('id', id);
  }
}

final mealsStreamProvider = StreamProvider.autoDispose<List<Meal>>((ref) {
  final uid = ref.watch(uidProvider);
  if (uid == null) return const Stream.empty();
  return ref.watch(mealsRepoProvider).streamMeals(uid);
});
