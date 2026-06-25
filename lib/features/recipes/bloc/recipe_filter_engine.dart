// recipe_filter_engine.dart
// Klasa odpowiedzialna wyłącznie za filtrowanie przepisów
class RecipeFilterEngine {
  static List<Map<String, dynamic>> apply({
    required List<Map<String, dynamic>> recipes,
    required String category,
    required Set<String> activeFilters,
    required int minCookTime,
    required int maxCookTime,
    required int minCalories,
    required int maxCalories,
    required int minIngredients,
  }) {
    List<Map<String, dynamic>> filtered = List.from(recipes);

    // Filtr kategorii
    if (category != 'ALL') {
      filtered = filtered.where((r) {
        final mealType = (r['mealType'] ?? r['meal_type'] ?? '').toString().toLowerCase();
        return mealType == category.toLowerCase();
      }).toList();
    }

    // Filtry zakresowe
    filtered = filtered.where((r) {
      final cookTime = r['cookTimeMinutes'] as int? ?? 999;
      if (cookTime < minCookTime || (maxCookTime < 120 && cookTime > maxCookTime)) return false;

      final calories = r['calories'] as num? ?? 999;
      if (calories < minCalories || (maxCalories < 1200 && calories > maxCalories)) return false;

      // the Edge Function maps Spoonacular ingredients:
      // it sends `ingredients` as an array. `usedIngredientCount` wasn't mapped specifically in Edge,
      // but we mapped `matchPercent`. The prompt uses usedIngredientCount. Let's just use `ingredients.length` if `usedIngredientCount` is missing,
      // or we can just rely on `matchPercent` if they want? The prompt explicitly said `usedIngredientCount`.
      // Let's support `matchPercent` too or just parse `usedIngredientCount` if available.
      // Wait, in `search-recipes` edge function: it's not mapped from DB, but we have `ingredients` array length which includes used+missed.
      // Actually, if we just check `ingredients` length for `minIngredients`... no, the user wrote:
      // "filtruje _allRecipes po cookTimeMinutes, calories i usedIngredientCount"
      // If it doesn't exist, fallback to `ingredients.length` or 0
      final usedCount = r['usedIngredientCount'] as int? ?? (r['ingredients'] as List?)?.length ?? 0;
      if (minIngredients > 0 && usedCount < minIngredients) return false;

      return true;
    }).toList();

    // Filtry szczegółowe
    for (final filter in activeFilters) {
      switch (filter) {
        case 'QUICK':
          filtered = filtered.where((r) => (r['cookTimeMinutes'] as int? ?? 999) <= 30).toList();
        case 'HIGH PROTEIN':
          filtered = filtered.where((r) => (r['proteinG'] ?? r['protein'] as num? ?? 0) >= 25).toList();
        case 'LOW CARB':
          filtered = filtered.where((r) => (r['carbsG'] ?? r['carbs'] as num? ?? 999) <= 20).toList();
        case 'LOW CALORIE':
          filtered = filtered.where((r) => (r['calories'] as num? ?? 999) <= 400).toList();
        case 'VEGETARIAN':
          filtered = filtered.where((r) {
            final tags = (r['dietTags'] ?? r['diet_tags'] ?? []) as List;
            return tags.any((t) => t.toString().contains('vegetarian'));
          }).toList();
        case 'VEGAN':
          filtered = filtered.where((r) {
            final tags = (r['dietTags'] ?? r['diet_tags'] ?? []) as List;
            return tags.any((t) => t.toString().contains('vegan'));
          }).toList();
        case 'KETO':
          filtered = filtered.where((r) {
            final tags = (r['dietTags'] ?? r['diet_tags'] ?? []) as List;
            return tags.any((t) => t.toString().contains('keto'));
          }).toList();
        case 'mild':
        case 'medium':
        case 'hot':
        case 'very-hot':
          // Reserved for future Spice Level implementation in DB. No-op for now.
          break;
        case 'ITALIAN':
        case 'ASIAN':
        case 'MEXICAN':
        case 'MEDITERRANEAN':
        case 'INDIAN':
        case 'AMERICAN':
        case 'FRENCH':
          filtered = filtered.where((r) {
            final cuisine = (r['cuisineType'] ?? r['cuisine_type'] ?? '').toString().toLowerCase();
            return cuisine == filter.toLowerCase();
          }).toList();
      }
    }

    return filtered;
  }
}
