import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';

class RecipesBloc extends Bloc<RecipesEvent, RecipesState> {
  final RecipesRepository repository;
  List<Map<String, dynamic>> _allRecipes = [];

  RecipesBloc({required this.repository}) : super(const RecipesInitial()) {
    on<LoadRecipes>(_onLoadRecipes);
    on<FilterRecipes>(_onFilterRecipes);
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
        selectedFilter: 'ALL',
      ));
    } catch (e) {
      emit(RecipesError(_parseError(e)));
    }
  }

  void _onFilterRecipes(
    FilterRecipes event,
    Emitter<RecipesState> emit,
  ) {
    if (state is RecipesLoaded) {
      List<Map<String, dynamic>> filtered = List.from(_allRecipes);
      
      if (event.filter == 'QUICK ✓') {
        filtered = filtered.where((r) => (r['cookTimeMinutes'] as int? ?? 999) <= 30).toList();
      } else if (event.filter == 'HIGH PROTEIN 🏃') {
        filtered = filtered.where((r) => (r['protein'] as int? ?? 0) > 20).toList();
      } else if (event.filter == 'LOW SUGAR 🅰') {
        filtered = filtered.where((r) => (r['sugar'] as int? ?? 999) < 10).toList();
      }

      emit(RecipesLoaded(
        recipes: filtered,
        selectedFilter: event.filter,
      ));
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
