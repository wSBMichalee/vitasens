import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/features/extract/data/models/extracted_recipe_model.dart';

class ExtractRepository {
  final SupabaseClientService _supabaseService;

  ExtractRepository({SupabaseClientService? supabaseService})
      : _supabaseService = supabaseService ?? SupabaseClientService.instance;

  Future<ExtractedRecipeModel> extractRecipeFromUrl(String url) async {
    final result = await _supabaseService.invokeFunction(
      'extract-recipe',
      body: {'action': 'extract', 'url': url},
    );

    return ExtractedRecipeModel.fromJson(result as Map<String, dynamic>);
  }

  Future<void> saveExtractedRecipe(ExtractedRecipeModel recipe) async {
    await _supabaseService.invokeFunction(
      'extract-recipe',
      body: {
        'action': 'save',
        'recipe': recipe.toJson(),
      },
    );
  }
}
