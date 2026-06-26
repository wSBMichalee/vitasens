import 'package:flutter/foundation.dart';
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
    try {
      final multiplier = servings;
      final data = {
        'user_id': userId,
        'meal_date': DateTime.now().toIso8601String().split('T')[0],
        'meal_time': mealTime,
        'food_name': foodName,
        'calories': (calories * multiplier).round(),
        'protein_g': double.parse((proteinG * multiplier).toStringAsFixed(1)),
        'carbs_g': double.parse((carbsG * multiplier).toStringAsFixed(1)),
        'fat_g': double.parse((fatG * multiplier).toStringAsFixed(1)),
        'source': 'manual',
        'log_source': 'manual',
      };
      debugPrint('Logging meal: $data');
      final response = await _supabase.from('meals').insert(data).select();
      debugPrint('Meal logged successfully: $response');
    } catch (e, stack) {
      debugPrint('Error logging meal: $e');
      debugPrint('Stack: $stack');
      rethrow;
    }
  }
}
