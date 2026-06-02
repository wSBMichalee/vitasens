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

class LoadMyRecipes extends RecipesEvent {
  const LoadMyRecipes();
}

class CreateRecipe extends RecipesEvent {
  final String title;
  final String description;
  final List<Map<String, dynamic>> ingredients;
  final List<String> steps;
  final int cookTimeMinutes;
  final int servings;
  final String? cuisineType;
  final List<String> dietTags;

  const CreateRecipe({
    required this.title,
    required this.description,
    required this.ingredients,
    required this.steps,
    required this.cookTimeMinutes,
    required this.servings,
    this.cuisineType,
    this.dietTags = const [],
  });

  @override
  List<Object?> get props => [
        title,
        description,
        ingredients,
        steps,
        cookTimeMinutes,
        servings,
        cuisineType,
        dietTags,
      ];
}

class PublishRecipe extends RecipesEvent {
  final String recipeId;

  const PublishRecipe(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class DeleteRecipe extends RecipesEvent {
  final String recipeId;

  const DeleteRecipe(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}

class LikeRecipe extends RecipesEvent {
  final String recipeId;

  const LikeRecipe(this.recipeId);

  @override
  List<Object?> get props => [recipeId];
}
