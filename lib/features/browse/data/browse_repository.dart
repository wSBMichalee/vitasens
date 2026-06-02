import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/features/browse/data/models/browse_filters_model.dart';

class BrowseRepository {
  final SupabaseClientService _supabaseService;

  BrowseRepository({SupabaseClientService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseClientService.instance;

  Future<List<Map<String, dynamic>>> getFeatured() async {
    final result = await _supabaseService.invokeFunction(
      'browse-recipes',
      body: {'action': 'featured'},
    );
    if (result == null) return [];
    return List<Map<String, dynamic>>.from(result as List);
  }

  Future<List<String>> getCuisines() async {
    final result = await _supabaseService.invokeFunction(
      'browse-recipes',
      body: {'action': 'cuisines'},
    );
    if (result == null) return [];
    return List<String>.from(result as List);
  }

  Future<List<String>> getDietTags() async {
    final result = await _supabaseService.invokeFunction(
      'browse-recipes',
      body: {'action': 'diet_tags'},
    );
    if (result == null) return [];
    return List<String>.from(result as List);
  }

  Future<Map<String, dynamic>> browseRecipes(BrowseFiltersModel filters) async {
    final result = await _supabaseService.invokeFunction(
      'browse-recipes',
      body: {
        'action': 'browse',
        'cuisines': filters.selectedCuisines,
        'dietTags': filters.selectedDietTags,
        'searchQuery': filters.searchQuery,
        'sortBy': filters.sortBy,
        'page': filters.page,
        'pageSize': filters.pageSize,
      },
    );
    return result as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> getDetails(String recipeId) async {
    final result = await _supabaseService.invokeFunction(
      'browse-recipes',
      body: {
        'action': 'details',
        'recipeId': recipeId,
      },
    );
    return result as Map<String, dynamic>? ?? {};
  }
}
