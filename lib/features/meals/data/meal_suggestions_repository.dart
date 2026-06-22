import 'package:supabase_flutter/supabase_flutter.dart';
import 'meal_suggestion_model.dart';

class MealSuggestionsRepository {
  final SupabaseClient _supabase;

  MealSuggestionsRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<MealSuggestionModel>> getSuggestions({
    required String mealType,
    List<String> excludeIds = const [],
  }) async {
    final response = await _supabase.functions.invoke(
      'suggest-meals',
      body: {'mealType': mealType, 'excludeIds': excludeIds},
    );
    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) throw Exception(body['error'] ?? 'Unknown error');
    final data = body['data'] as Map<String, dynamic>;
    final list = data['recipes'] as List<dynamic>? ?? [];
    return list.map((e) => MealSuggestionModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> logMeal({
    required String foodName,
    required String mealTime,
    required int calories,
    required double proteinG,
    required double carbsG,
    required double fatG,
    required String userId,
    double servings = 1.0,
  }) async {
    final multiplier = servings;
    await _supabase.from('meals').insert({
      'user_id': userId,
      'meal_date': DateTime.now().toIso8601String().split('T')[0],
      'meal_time': mealTime,
      'food_name': foodName,
      'calories': (calories * multiplier).round(),
      'protein_g': (proteinG * multiplier).roundToDouble(),
      'carbs_g': (carbsG * multiplier).roundToDouble(),
      'fat_g': (fatG * multiplier).roundToDouble(),
      'source': 'recipe',
      'log_source': 'suggestion',
    });
  }
}
