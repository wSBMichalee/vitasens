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
      emit(ExtractError(_parseError(e)));
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
      emit(ExtractError(_parseError(e)));
      emit(ExtractSuccess(event.recipe)); // Re-emit success to restore the view
    }
  }

  void _onResetExtract(
    ResetExtract event,
    Emitter<ExtractState> emit,
  ) {
    emit(const ExtractInitial());
  }

  // ─── Error Parser ──────────────────────────────────────────────────────────────
  String _parseError(dynamic e) {
    final raw = e.toString().toLowerCase();

    if (raw.contains('invalid url')) {
      return 'Invalid URL. Please paste a TikTok, YouTube or Instagram link.';
    }
    if (raw.contains('not supported')) return 'This platform is not supported yet.';
    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('connection')) {
      return 'No internet connection.';
    }
    return 'Could not extract recipe. Try again.';
  }
}
