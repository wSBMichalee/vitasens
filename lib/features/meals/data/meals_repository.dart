import 'package:supabase_flutter/supabase_flutter.dart';
import 'meal_model.dart';

class MealsRepository {
  final _client = Supabase.instance.client;

  Future<List<MealModel>> getMealsForDate(DateTime date) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    final response = await _client
        .from('meals')
        .select()
        .eq('user_id', userId)
        .eq('meal_date', dateStr)
        .order('created_at');
    return (response as List).map((e) => MealModel.fromJson(e)).toList();
  }

  Future<void> deleteMeal(String mealId) async {
    await _client.from('meals').delete().eq('id', mealId);
  }
}
