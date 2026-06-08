import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final RecipesRepository repository;
  List<Map<String, dynamic>> _allRecipes = [];

  RecipesBloc({required this.repository}) : super(const RecipesInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<SetRecipeCategory>(_onSetCategory);
    on<ToggleRecipeFilter>(_onToggleFilter);
    on<ClearRecipeFilters>(_onClearFilters);
    on<ApplyRangeFilters>(_onApplyRangeFilters);
    on<SelectRecipe>(_onSelectRecipe);
    on<CookRecipe>(_onCookRecipe);
    on<LoadMyRecipes>(_onLoadMyRecipes);
    on<CreateRecipe>(_onCreateRecipe);
    on<PublishRecipe>(_onPublishRecipe);
    on<DeleteRecipe>(_onDeleteRecipe);
    on<LikeRecipe>(_onLikeRecipe);
  }

  Future<void> _onLoadRecipes(
    LoadRecipes event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipesLoading());
    try {
      final recipes = await repository.searchRecipes(event.pantryIngredients);
      _allRecipes = recipes;
      emit(RecipesLoaded(
        recipes: _allRecipes,
        activeFilters: const {},
        selectedCategory: 'ALL',
      ));
    } catch (e) {
      emit(RecipesError(_parseError(e)));
    }
  }

  void _applyFilters(
    Emitter<RecipesState> emit,
    String category,
    Set<String> activeFilters,
    int minCookTime,
    int maxCookTime,
    int minCalories,
    int maxCalories,
    int minIngredients,
  ) {
    List<Map<String, dynamic>> filtered = List.from(_allRecipes);

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

    emit(RecipesLoaded(
      recipes: filtered,
      activeFilters: activeFilters,
      selectedCategory: category,
      minCookTime: minCookTime,
      maxCookTime: maxCookTime,
      minCalories: minCalories,
      maxCalories: maxCalories,
      minIngredients: minIngredients,
    ));
  }

  void _onSetCategory(SetRecipeCategory event, Emitter<RecipesState> emit) {
    if (state is RecipesLoaded) {
      final s = state as RecipesLoaded;
      _applyFilters(emit, event.category, s.activeFilters, s.minCookTime, s.maxCookTime, s.minCalories, s.maxCalories, s.minIngredients);
    }
  }

  void _onToggleFilter(ToggleRecipeFilter event, Emitter<RecipesState> emit) {
    if (state is RecipesLoaded) {
      final s = state as RecipesLoaded;
      final newFilters = Set<String>.from(s.activeFilters);
      if (newFilters.contains(event.filter)) {
        newFilters.remove(event.filter);
      } else {
        newFilters.add(event.filter);
      }
      _applyFilters(emit, s.selectedCategory, newFilters, s.minCookTime, s.maxCookTime, s.minCalories, s.maxCalories, s.minIngredients);
    }
  }

  void _onClearFilters(ClearRecipeFilters event, Emitter<RecipesState> emit) {
    if (state is RecipesLoaded) {
      emit(RecipesLoaded(recipes: _allRecipes, activeFilters: const {}, selectedCategory: 'ALL'));
    }
  }

  void _onApplyRangeFilters(ApplyRangeFilters event, Emitter<RecipesState> emit) {
    if (state is RecipesLoaded) {
      final s = state as RecipesLoaded;
      _applyFilters(emit, s.selectedCategory, s.activeFilters, event.minCookTime, event.maxCookTime, event.minCalories, event.maxCalories, event.minIngredients);
    }
  }

  void _onSelectRecipe(
    SelectRecipe event,
    Emitter<RecipesState> emit,
  ) {
    // Handle recipe selection if needed in the bloc
  }

  Future<void> _onCookRecipe(
    CookRecipe event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipesCooking());
    try {
      await repository.cookRecipe(event.recipeId, 'default', event.servings);
      emit(const RecipesCookingSuccess());
    } catch (e) {
      emit(RecipesError(_parseError(e)));
    }
  }
  Future<void> _onLoadMyRecipes(
    LoadMyRecipes event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipesLoading());
    try {
      final recipes = await repository.getMyRecipes();
      emit(MyRecipesLoaded(recipes));
    } catch (e) {
      emit(RecipesError(_parseError(e)));
    }
  }

  Future<void> _onCreateRecipe(
    CreateRecipe event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipeCreating());
    try {
      final recipe = await repository.createRecipe(
        title: event.title,
        description: event.description,
        ingredients: event.ingredients,
        steps: event.steps,
        cookTimeMinutes: event.cookTimeMinutes,
        servings: event.servings,
        cuisineType: event.cuisineType,
        dietTags: event.dietTags,
      );
      emit(RecipeCreated(recipe));
    } catch (e) {
      emit(RecipesError(_parseError(e)));
    }
  }

  Future<void> _onPublishRecipe(
    PublishRecipe event,
    Emitter<RecipesState> emit,
  ) async {
    try {
      await repository.publishRecipe(event.recipeId);
      add(const LoadMyRecipes());
    } catch (e) {
      emit(RecipesError(_parseError(e)));
    }
  }

  Future<void> _onDeleteRecipe(
    DeleteRecipe event,
    Emitter<RecipesState> emit,
  ) async {
    try {
      await repository.deleteRecipe(event.recipeId);
      add(const LoadMyRecipes());
    } catch (e) {
      emit(RecipesError(_parseError(e)));
    }
  }

  Future<void> _onLikeRecipe(
    LikeRecipe event,
    Emitter<RecipesState> emit,
  ) async {
    try {
      await repository.likeRecipe(event.recipeId);
      add(const LoadMyRecipes());
    } catch (e) {
      emit(RecipesError(_parseError(e)));
    }
  }

  // ─── Error Parser ──────────────────────────────────────────────────────────────
  String _parseError(dynamic e) {
    final raw = e.toString().toLowerCase();

    if (raw.contains('not found')) return 'Recipe not found.';
    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('connection')) {
      return 'No internet connection.';
    }
    if (raw.contains('ingredients')) return 'Not enough ingredients in pantry.';
    return 'Could not load recipes. Try again.';
  }
}
