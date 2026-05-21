import 'package:supabase_flutter/supabase_flutter.dart';

class RecipesRepository {
  final SupabaseClient _supabase;

  RecipesRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<List<Map<String, dynamic>>> searchRecipes(
      List<String> pantryIngredients) async {
    final response = await _supabase.functions.invoke(
      'search-recipes',
      body: {
        'action': 'search',
        'pantryIngredients': pantryIngredients,
      },
    );

    final data = response.data as List<dynamic>;
    return data.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<Map<String, dynamic>> getRecipeDetails(String id) async {
    final response = await _supabase.functions.invoke(
      'browse-recipes',
      body: {
        'action': 'details',
        'recipeId': id,
      },
    );

    return response.data as Map<String, dynamic>;
  }

  Future<void> cookRecipe(
      String recipeId, String familyId, int servings) async {
    await _supabase.functions.invoke(
      'cook-recipe',
      body: {
        'action': 'cook',
        'recipeId': recipeId,
        'familyId': familyId,
        'servingsCooked': servings,
      },
    );
  }
}
