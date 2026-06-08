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

    final body = response.data as Map<String, dynamic>;
    final payload = body['data'] as Map<String, dynamic>;
    final list = payload['recipes'] as List<dynamic>;
    final pantrySet = pantryIngredients.map((e) => e.toLowerCase()).toSet();

    return list.map((e) {
      final r = Map<String, dynamic>.from(e as Map);
      final allIngredients = (r['ingredients'] as List<dynamic>? ?? [])
          .map((i) => Map<String, dynamic>.from(i as Map))
          .toList();
      final used = allIngredients
          .where((i) => pantrySet.any((p) =>
              (i['name']?.toString().toLowerCase() ?? '').contains(p)))
          .toList();
      final missed = allIngredients
          .where((i) => !pantrySet.any((p) =>
              (i['name']?.toString().toLowerCase() ?? '').contains(p)))
          .toList();
      return {
        ...r,
        'image': r['imageUrl'],
        'readyInMinutes': r['cookTimeMinutes'],
        'usedIngredients': used,
        'missedIngredients': missed,
      };
    }).toList();
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
  Future<void> addFavorite(String recipeId) async {
    await _supabase.functions.invoke(
      'search-recipes',
      body: {'action': 'add_favorite', 'recipeId': recipeId},
    );
  }

  Future<void> removeFavorite(String recipeId) async {
    await _supabase.functions.invoke(
      'search-recipes',
      body: {'action': 'remove_favorite', 'recipeId': recipeId},
    );
  }

  Future<List<Map<String, dynamic>>> getFavorites() async {
    final response = await _supabase.functions.invoke(
      'search-recipes',
      body: {'action': 'favorites'},
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as List? ?? [];
    return data.map((e) {
      final r = Map<String, dynamic>.from(e as Map);
      r['imageUrl'] = r['imageUrl'] ?? r['image_url'];
      r['cookTimeMinutes'] = r['cookTimeMinutes'] ?? r['cook_time_minutes'];
      r['proteinG'] = (r['proteinG'] ?? r['protein_g'] ?? 0).toDouble();
      r['carbsG'] = (r['carbsG'] ?? r['carbs_g'] ?? 0).toDouble();
      r['fatG'] = (r['fatG'] ?? r['fat_g'] ?? 0).toDouble();
      r['calories'] = (r['calories'] ?? 0).toInt();
      r['usedIngredients'] = [];
      r['missedIngredients'] = [];
      return r;
    }).toList();
  }

  Future<bool> isFavorite(String recipeId) async {
    final response = await _supabase.functions.invoke(
      'search-recipes',
      body: {'action': 'is_favorite', 'recipeId': recipeId},
    );
    final body = response.data as Map<String, dynamic>;
    final data = body['data'] as Map<String, dynamic>;
    return data['isFavorite'] as bool? ?? false;
  }
}
