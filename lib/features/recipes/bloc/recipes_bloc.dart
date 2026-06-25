import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';
import 'recipe_filter_engine.dart';

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
    on<ToggleFavorite>(_onToggleFavorite);
    on<LoadFavorites>(_onLoadFavorites);
    on<CheckFavorite>(_onCheckFavorite);
  }

  Future<void> _onLoadRecipes(
    LoadRecipes event,
    Emitter<RecipesState> emit,
  ) async {
    emit(const RecipesLoading());
    try {
      // Faza 1 — szybkie pobranie z Spoonacular bez makr
      final fastResponse = await repository.searchRecipesFast(event.pantryIngredients);
      final rawList = fastResponse['recipes'] as List<dynamic>? ?? [];
      final fastRecipes = rawList.map((e) => Map<String, dynamic>.from(e as Map)).toList();
      final spoonacularIds = <int>[];
      
      _allRecipes = fastRecipes;
      final isPersonalized = fastRecipes.any((r) => r['geminiReason'] != null && r['geminiReason'].toString().isNotEmpty);
      
      emit(RecipesLoaded(
        recipes: _allRecipes,
        activeFilters: const {},
        selectedCategory: 'ALL',
        geminiPersonalized: isPersonalized,
        isEnriching: spoonacularIds.isNotEmpty,
      ));

      // Faza 2 — w tle doładuj makra i Gemini
      if (spoonacularIds.isNotEmpty) {
        final enriched = await repository.enrichRecipes(spoonacularIds);
        
        // Zastępujemy szybkie wyniki wzbogaconymi, zachowując te których Gemini nie zwrócił
        _allRecipes = enriched.map((e) {
          final original = fastRecipes.firstWhere((f) => f['sourceId'] == e['sourceId'], orElse: () => {});
          return {
            ...original,
            ...e,
          };
        }).toList();

        final enrichedIsPersonalized = _allRecipes.any((r) => r['geminiReason'] != null && r['geminiReason'].toString().isNotEmpty);
        
        emit(RecipesLoaded(
          recipes: _allRecipes,
          activeFilters: const {},
          selectedCategory: 'ALL',
          geminiPersonalized: enrichedIsPersonalized,
          isEnriching: false,
        ));
      }
    } catch (e) {
      final parsedErr = _parseError(e);
      if (parsedErr == 'SUBSCRIPTION_EXPIRED') {
        emit(const RecipesSubscriptionExpired());
      } else {
        emit(RecipesError(parsedErr));
      }
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
    bool geminiPersonalized,
    bool isEnriching,
  ) {
    final filtered = RecipeFilterEngine.apply(
      recipes: _allRecipes,
      category: category,
      activeFilters: activeFilters,
      minCookTime: minCookTime,
      maxCookTime: maxCookTime,
      minCalories: minCalories,
      maxCalories: maxCalories,
      minIngredients: minIngredients,
    );
    emit(RecipesLoaded(
      recipes: filtered,
      activeFilters: activeFilters,
      selectedCategory: category,
      minCookTime: minCookTime,
      maxCookTime: maxCookTime,
      minCalories: minCalories,
      maxCalories: maxCalories,
      minIngredients: minIngredients,
      geminiPersonalized: geminiPersonalized,
      isEnriching: isEnriching,
    ));
  }

  void _onSetCategory(SetRecipeCategory event, Emitter<RecipesState> emit) {
    if (state is RecipesLoaded) {
      final s = state as RecipesLoaded;
      _applyFilters(emit, event.category, s.activeFilters, s.minCookTime, s.maxCookTime, s.minCalories, s.maxCalories, s.minIngredients, s.geminiPersonalized, s.isEnriching);
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
      _applyFilters(emit, s.selectedCategory, newFilters, s.minCookTime, s.maxCookTime, s.minCalories, s.maxCalories, s.minIngredients, s.geminiPersonalized, s.isEnriching);
    }
  }

  void _onClearFilters(ClearRecipeFilters event, Emitter<RecipesState> emit) {
    if (state is RecipesLoaded) {
      final s = state as RecipesLoaded;
      emit(RecipesLoaded(recipes: _allRecipes, activeFilters: const {}, selectedCategory: 'ALL', geminiPersonalized: s.geminiPersonalized, isEnriching: s.isEnriching));
    }
  }

  void _onApplyRangeFilters(ApplyRangeFilters event, Emitter<RecipesState> emit) {
    if (state is RecipesLoaded) {
      final s = state as RecipesLoaded;
      _applyFilters(emit, s.selectedCategory, s.activeFilters, event.minCookTime, event.maxCookTime, event.minCalories, event.maxCalories, event.minIngredients, s.geminiPersonalized, s.isEnriching);
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
      final parsedErr = _parseError(e);
      if (parsedErr == 'SUBSCRIPTION_EXPIRED') {
        emit(const RecipesSubscriptionExpired());
      } else {
        emit(RecipesError(parsedErr));
      }
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

  // ─── Favorites Handlers ────────────────────────────────────────────────────────

  Future<void> _onToggleFavorite(ToggleFavorite event, Emitter<RecipesState> emit) async {
    try {
      if (event.currentlyFavorited) {
        await repository.removeFavorite(event.recipeId);
        emit(FavoriteToggled(recipeId: event.recipeId, isFavorite: false));
      } else {
        await repository.addFavorite(event.recipeId);
        emit(FavoriteToggled(recipeId: event.recipeId, isFavorite: true));
      }
    } catch (e) {
      emit(RecipesError(_parseError(e)));
    }
  }

  Future<void> _onLoadFavorites(LoadFavorites event, Emitter<RecipesState> emit) async {
    emit(const RecipesLoading());
    try {
      final recipes = await repository.getFavorites();
      emit(FavoritesLoaded(recipes));
    } catch (e) {
      emit(RecipesError(_parseError(e)));
    }
  }

  Future<void> _onCheckFavorite(CheckFavorite event, Emitter<RecipesState> emit) async {
    try {
      final isFav = await repository.isFavorite(event.recipeId);
      emit(FavoriteChecked(recipeId: event.recipeId, isFavorite: isFav));
    } catch (e) {
      // silent fail
    }
  }

  // ─── Error Parser ──────────────────────────────────────────────────────────────
  String _parseError(dynamic e) {
    final raw = e.toString().toLowerCase();

    if (raw.contains('recipe_not_found') || raw.contains('przepis nie istnieje')) return 'Przepis nie znaleziony — odśwież listę.';
    if (raw.contains('subscription_expired') || raw.contains('403')) return 'SUBSCRIPTION_EXPIRED';
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
