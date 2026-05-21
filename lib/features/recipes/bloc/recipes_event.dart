import 'package:equatable/equatable.dart';

abstract class RecipesEvent extends Equatable {
  const RecipesEvent();

  @override
  List<Object?> get props => [];
}

class LoadRecipes extends RecipesEvent {
  final List<String> pantryIngredients;

  const LoadRecipes(this.pantryIngredients);

  @override
  List<Object?> get props => [pantryIngredients];
}

class FilterRecipes extends RecipesEvent {
  final String filter; // quick/high_protein/low_sugar

  const FilterRecipes(this.filter);

  @override
  List<Object?> get props => [filter];
}

class SelectRecipe extends RecipesEvent {
  final String recipeId;

  const SelectRecipe(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class CookRecipe extends RecipesEvent {
  final String recipeId;
  final int servings;

  const CookRecipe(this.recipeId, this.servings);

  @override
  List<Object?> get props => [recipeId, servings];
}
