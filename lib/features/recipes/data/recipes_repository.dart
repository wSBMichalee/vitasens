import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/features/recipes/data/models/recipe_model.dart';

class RecipesRepository {
  final SupabaseClient _supabase;

  RecipesRepository({SupabaseClient? supabase})
      : _supabase = supabase ?? Supabase.instance.client;

  Future<Map<String, dynamic>> searchRecipesFast(List<String> pantryIngredients) async {
    final response = await _supabase.functions.invoke(
      'search-recipes',
      body: {'action': 'search_fast', 'pantryIngredients': pantryIngredients},
    );
    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) throw Exception(body['error'] ?? 'Unknown error');
    final payload = body['data'] as Map<String, dynamic>;
    final list = payload['recipes'] as List<dynamic>;
    final ids = (payload['spoonacularIds'] as List?) ?? [];
    
    final recipes = list.map((e) {
      final r = Map<String, dynamic>.from(e as Map);
      return {
        ...r,
        'imageUrl': r['imageUrl'] ?? r['image_url'] ?? '',
        'cookTimeMinutes': r['cookTimeMinutes'] ?? r['cook_time_minutes'] ?? 0,
        'proteinG': (r['proteinG'] ?? r['protein_g'] ?? 0.0).toDouble(),
        'carbsG': (r['carbsG'] ?? r['carbs_g'] ?? 0.0).toDouble(),
        'fatG': (r['fatG'] ?? r['fat_g'] ?? 0.0).toDouble(),
        'calories': (r['calories'] ?? 0).toInt(),
        'geminiReason': r['geminiReason'] as String?,
      };
    }).toList();
    
    return {'recipes': recipes, 'spoonacularIds': ids};
  }

  Future<List<Map<String, dynamic>>> enrichRecipes(List<int> spoonacularIds) async {
    final response = await _supabase.functions.invoke(
      'search-recipes',
      body: {'action': 'search_enrich', 'spoonacularIds': spoonacularIds},
    );
    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) throw Exception(body['error'] ?? 'Unknown error');
    final payload = body['data'] as Map<String, dynamic>;
    final list = payload['recipes'] as List<dynamic>;
    
    return list.map((e) {
      final r = Map<String, dynamic>.from(e as Map);
      return {
        ...r,
        'imageUrl': r['imageUrl'] ?? r['image_url'] ?? '',
        'cookTimeMinutes': r['cookTimeMinutes'] ?? r['cook_time_minutes'] ?? 0,
        'proteinG': (r['proteinG'] ?? r['protein_g'] ?? 0.0).toDouble(),
        'carbsG': (r['carbsG'] ?? r['carbs_g'] ?? 0.0).toDouble(),
        'fatG': (r['fatG'] ?? r['fat_g'] ?? 0.0).toDouble(),
        'calories': (r['calories'] ?? 0).toInt(),
        'geminiReason': r['geminiReason'] as String?,
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

  Future<void> cookRecipe(String recipeId, String familyId, int servings) async {
    final response = await _supabase.functions.invoke(
      'cook-recipe',
      body: {'recipeId': recipeId, 'familyId': familyId, 'servingsCooked': servings},
    );
    final body = response.data as Map<String, dynamic>;
    if (body['success'] != true) {
      final error = body['error'] as String? ?? '';
      throw Exception(error.isNotEmpty ? error : 'cook_recipe_failed');
    }
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
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase.from('favorite_recipes').upsert({
      'user_id': userId,
      'recipe_id': recipeId,
    }, onConflict: 'user_id,recipe_id');
  }

  Future<void> removeFavorite(String recipeId) async {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) return;
    await _supabase
        .from('favorite_recipes')
        .delete()
        .eq('user_id', userId)
        .eq('recipe_id', recipeId);
  }

  Future<Set<String>> getFavoriteIds() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return {};
      final data = await _supabase
          .from('favorite_recipes')
          .select('recipe_id')
          .eq('user_id', userId);
      if (data == null) return {};
      return (data as List)
          .map((row) => row['recipe_id']?.toString() ?? '')
          .where((id) => id.isNotEmpty)
          .toSet();
    } catch (e) {
      return {};
    }
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
