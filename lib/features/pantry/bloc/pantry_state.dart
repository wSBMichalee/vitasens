import 'package:equatable/equatable.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';

abstract class PantryState extends Equatable {
  const PantryState();

  @override
  List<Object?> get props => [];
}

class PantryInitial extends PantryState {
  const PantryInitial();
}

class PantryLoading extends PantryState {
  const PantryLoading();
}

class PantryLoaded extends PantryState {
  final List<IngredientModel> ingredients;
  final List<IngredientModel> expiringSoon;
  final String selectedFilter;

  const PantryLoaded({
    required this.ingredients,
    required this.expiringSoon,
    this.selectedFilter = 'all',
  });

  PantryLoaded copyWith({
    List<IngredientModel>? ingredients,
    List<IngredientModel>? expiringSoon,
    String? selectedFilter,
  }) {
    return PantryLoaded(
      ingredients: ingredients ?? this.ingredients,
      expiringSoon: expiringSoon ?? this.expiringSoon,
      selectedFilter: selectedFilter ?? this.selectedFilter,
    );
  }

  @override
  List<Object?> get props => [ingredients, expiringSoon, selectedFilter];
}

class PantryError extends PantryState {
  final String message;

  const PantryError(this.message);

  @override
  List<Object?> get props => [message];
}

class PantryAddingIngredient extends PantryState {
  const PantryAddingIngredient();
}

class PantryIngredientAdded extends PantryState {
  const PantryIngredientAdded();
}
