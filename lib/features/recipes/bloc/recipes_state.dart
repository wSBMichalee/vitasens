import 'package:equatable/equatable.dart';
import 'package:vitasense/features/recipes/data/models/recipe_model.dart';

abstract class RecipesState extends Equatable {
  const RecipesState();

  @override
  List<Object?> get props => [];
}

class RecipesInitial extends RecipesState {
  const RecipesInitial();
}

class RecipesLoading extends RecipesState {
  const RecipesLoading();
}

class RecipesLoaded extends RecipesState {
  const RecipesLoaded({
    required this.recipes,
    this.activeFilters = const {},
    this.selectedCategory = 'ALL',
    this.minCookTime = 0,
    this.maxCookTime = 120,
    this.minCalories = 0,
    this.maxCalories = 1200,
    this.minIngredients = 0,
  });
  final List<Map<String, dynamic>> recipes;
  final Set<String> activeFilters;
  final String selectedCategory;
  final int minCookTime;
  final int maxCookTime;
  final int minCalories;
  final int maxCalories;
  final int minIngredients;

  RecipesLoaded copyWith({
    List<Map<String, dynamic>>? recipes,
    Set<String>? activeFilters,
    String? selectedCategory,
    int? minCookTime,
    int? maxCookTime,
    int? minCalories,
    int? maxCalories,
    int? minIngredients,
  }) => RecipesLoaded(
    recipes: recipes ?? this.recipes,
    activeFilters: activeFilters ?? this.activeFilters,
    selectedCategory: selectedCategory ?? this.selectedCategory,
    minCookTime: minCookTime ?? this.minCookTime,
    maxCookTime: maxCookTime ?? this.maxCookTime,
    minCalories: minCalories ?? this.minCalories,
    maxCalories: maxCalories ?? this.maxCalories,
    minIngredients: minIngredients ?? this.minIngredients,
  );

  @override
  List<Object?> get props => [
    recipes, activeFilters, selectedCategory,
    minCookTime, maxCookTime, minCalories, maxCalories, minIngredients
  ];
}

class RecipesError extends RecipesState {
  final String message;

  const RecipesError(this.message);

  @override
  List<Object?> get props => [message];
}

class RecipesCooking extends RecipesState {
  const RecipesCooking();
}

class RecipesCookingSuccess extends RecipesState {
  const RecipesCookingSuccess();
}

class MyRecipesLoaded extends RecipesState {
  final List<RecipeModel> recipes;

  const MyRecipesLoaded(this.recipes);

  @override
  List<Object?> get props => [recipes];
}

class RecipeCreating extends RecipesState {
  const RecipeCreating();
}

class RecipeCreated extends RecipesState {
  final RecipeModel recipe;

  const RecipeCreated(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class FavoritesLoaded extends RecipesState {
  const FavoritesLoaded(this.recipes);
  final List<Map<String, dynamic>> recipes;
}

class FavoriteToggled extends RecipesState {
  const FavoriteToggled({required this.recipeId, required this.isFavorite});
  final String recipeId;
  final bool isFavorite;
}

class FavoriteChecked extends RecipesState {
  const FavoriteChecked({required this.recipeId, required this.isFavorite});
  final String recipeId;
  final bool isFavorite;
}
