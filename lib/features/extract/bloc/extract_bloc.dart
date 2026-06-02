import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/extract/bloc/extract_event.dart';
import 'package:vitasense/features/extract/bloc/extract_state.dart';
import 'package:vitasense/features/extract/data/extract_repository.dart';

class ExtractBloc extends Bloc<ExtractEvent, ExtractState> {
  final ExtractRepository _repository;

  ExtractBloc({ExtractRepository? repository})
      : _repository = repository ?? ExtractRepository(),
        super(const ExtractInitial()) {
    on<ExtractUrl>(_onExtractUrl);
    on<SaveExtractedRecipe>(_onSaveExtractedRecipe);
    on<ResetExtract>(_onResetExtract);
  }

  Future<void> _onExtractUrl(
    ExtractUrl event,
    Emitter<ExtractState> emit,
  ) async {
    emit(const ExtractLoading());
    try {
      final recipe = await _repository.extractRecipeFromUrl(event.url);
      emit(ExtractSuccess(recipe));
    } catch (e) {
      emit(ExtractError(e.toString()));
    }
  }

  Future<void> _onSaveExtractedRecipe(
    SaveExtractedRecipe event,
    Emitter<ExtractState> emit,
  ) async {
    emit(const ExtractLoading());
    try {
      await _repository.saveExtractedRecipe(event.recipe);
      emit(const ExtractSaveSuccess());
    } catch (e) {
      emit(ExtractError(e.toString()));
      emit(ExtractSuccess(event.recipe)); // Re-emit success to restore the view
    }
  }

  void _onResetExtract(
    ResetExtract event,
    Emitter<ExtractState> emit,
  ) {
    emit(const ExtractInitial());
  }
}
