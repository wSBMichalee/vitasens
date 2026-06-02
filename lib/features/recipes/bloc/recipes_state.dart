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
  final List<Map<String, dynamic>> recipes;
  final String selectedFilter;

  const RecipesLoaded({
    required this.recipes,
    required this.selectedFilter,
  });

  @override
  List<Object?> get props => [recipes, selectedFilter];
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
