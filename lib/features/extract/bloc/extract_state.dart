import 'package:equatable/equatable.dart';
import 'package:vitasense/features/extract/data/models/extracted_recipe_model.dart';

abstract class ExtractState extends Equatable {
  const ExtractState();

  @override
  List<Object?> get props => [];
}

class ExtractInitial extends ExtractState {
  const ExtractInitial();
}

class ExtractLoading extends ExtractState {
  const ExtractLoading();
}

class ExtractSuccess extends ExtractState {
  final ExtractedRecipeModel recipe;

  const ExtractSuccess(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class ExtractSaveSuccess extends ExtractState {
  const ExtractSaveSuccess();
}

class ExtractError extends ExtractState {
  final String message;

  const ExtractError(this.message);

  @override
  List<Object?> get props => [message];
}
