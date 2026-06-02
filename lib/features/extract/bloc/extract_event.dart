import 'package:equatable/equatable.dart';
import 'package:vitasense/features/extract/data/models/extracted_recipe_model.dart';

abstract class ExtractEvent extends Equatable {
  const ExtractEvent();

  @override
  List<Object?> get props => [];
}

class ExtractUrl extends ExtractEvent {
  final String url;

  const ExtractUrl(this.url);

  @override
  List<Object?> get props => [url];
}

class SaveExtractedRecipe extends ExtractEvent {
  final ExtractedRecipeModel recipe;

  const SaveExtractedRecipe(this.recipe);

  @override
  List<Object?> get props => [recipe];
}

class ResetExtract extends ExtractEvent {
  const ResetExtract();
}
