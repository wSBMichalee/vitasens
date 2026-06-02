import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/features/recipes/data/models/recipe_model.dart';

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

  Future<List<RecipeModel>> getMyRecipes() async {
    final response = await _supabase.functions.invoke(
      'manage-user-recipes',
      body: {'action': 'my_recipes'},
    );
    final data = response.data as List<dynamic>;
    return data.map((e) => RecipeModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<RecipeModel> createRecipe({
    required String title,
    required String description,
    required List<Map<String, dynamic>> ingredients,
    required List<String> steps,
    required int cookTimeMinutes,
    required int servings,
    String? cuisineType,
    List<String> dietTags = const [],
  }) async {
    final response = await _supabase.functions.invoke(
      'manage-user-recipes',
      body: {
        'action': 'create',
        'title': title,
        'description': description,
        'ingredients': ingredients,
        'steps': steps,
        'cookTimeMinutes': cookTimeMinutes,
        'servings': servings,
        'cuisineType': cuisineType,
        'dietTags': dietTags,
      },
    );
    return RecipeModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> publishRecipe(String recipeId) async {
    await _supabase.functions.invoke(
      'manage-user-recipes',
      body: {
        'action': 'publish',
        'recipeId': recipeId,
      },
    );
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _supabase.functions.invoke(
      'manage-user-recipes',
      body: {
        'action': 'delete',
        'recipeId': recipeId,
      },
    );
  }

  Future<void> likeRecipe(String recipeId) async {
    await _supabase.functions.invoke(
      'manage-user-recipes',
      body: {
        'action': 'like',
        'recipeId': recipeId,
      },
    );
  }
}
