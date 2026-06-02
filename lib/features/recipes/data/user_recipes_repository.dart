import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/features/recipes/data/models/recipe_model.dart';

class UserRecipesRepository {
  final SupabaseClientService _supabaseService;

  UserRecipesRepository({SupabaseClientService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseClientService.instance;

  Future<List<RecipeModel>> getMyRecipes() async {
    final result = await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {'action': 'my_recipes'},
    );
    if (result == null) return [];
    return (result as List<dynamic>)
        .map((e) => RecipeModel.fromJson(e as Map<String, dynamic>))
        .toList();
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
    final result = await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {
        'action': 'create',
        'title': title,
        'description': description,
        'ingredients': ingredients,
        'steps': steps,
        'cookTimeMinutes': cookTimeMinutes,
        'servings': servings,
        if (cuisineType != null) 'cuisineType': cuisineType,
        'dietTags': dietTags,
      },
    );
    return RecipeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<RecipeModel> updateRecipe({
    required String recipeId,
    String? title,
    String? description,
    List<Map<String, dynamic>>? ingredients,
    List<String>? steps,
    int? cookTimeMinutes,
    int? servings,
    String? cuisineType,
    List<String>? dietTags,
  }) async {
    final result = await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {
        'action': 'update',
        'recipeId': recipeId,
        if (title != null) 'title': title,
        if (description != null) 'description': description,
        if (ingredients != null) 'ingredients': ingredients,
        if (steps != null) 'steps': steps,
        if (cookTimeMinutes != null) 'cookTimeMinutes': cookTimeMinutes,
        if (servings != null) 'servings': servings,
        if (cuisineType != null) 'cuisineType': cuisineType,
        if (dietTags != null) 'dietTags': dietTags,
      },
    );
    return RecipeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<void> deleteRecipe(String recipeId) async {
    await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {'action': 'delete', 'recipeId': recipeId},
    );
  }

  Future<void> publishRecipe(String recipeId) async {
    await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {'action': 'publish', 'recipeId': recipeId},
    );
  }

  Future<void> unpublishRecipe(String recipeId) async {
    await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {'action': 'unpublish', 'recipeId': recipeId},
    );
  }

  Future<void> likeRecipe(String recipeId) async {
    await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {'action': 'like', 'recipeId': recipeId},
    );
  }

  Future<void> unlikeRecipe(String recipeId) async {
    await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {'action': 'unlike', 'recipeId': recipeId},
    );
  }

  Future<bool> isLiked(String recipeId) async {
    final result = await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {'action': 'is_liked', 'recipeId': recipeId},
    );
    return (result as Map<String, dynamic>?)?['liked'] as bool? ?? false;
  }

  Future<Map<String, dynamic>> getStats(String recipeId) async {
    final result = await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {'action': 'stats', 'recipeId': recipeId},
    );
    return result as Map<String, dynamic>? ?? {};
  }

  Future<String?> uploadPhoto(String recipeId, List<int> bytes, String fileName) async {
    final result = await _supabaseService.invokeFunction(
      'manage-user-recipes',
      body: {
        'action': 'upload_photo',
        'recipeId': recipeId,
        'fileName': fileName,
        'bytes': bytes,
      },
    );
    return (result as Map<String, dynamic>?)?['imageUrl'] as String?;
  }
}
