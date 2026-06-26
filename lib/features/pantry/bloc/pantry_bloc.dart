import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/pantry/bloc/pantry_event.dart';
import 'package:vitasense/features/pantry/bloc/pantry_state.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';

class PantryBloc extends Bloc<PantryEvent, PantryState> {
  final PantryRepository repository;

  PantryBloc({required this.repository}) : super(const PantryInitial()) {
    on<LoadPantry>(_onLoadPantry);
    on<RefreshPantry>(_onRefreshPantry);
    on<FilterPantry>(_onFilterPantry);
    on<DeleteIngredient>(_onDeleteIngredient);
    on<AddIngredient>(_onAddIngredient);
    on<MoveIngredient>(_onMoveIngredient);
  }

  Future<void> _onLoadPantry(
    LoadPantry event,
    Emitter<PantryState> emit,
  ) async {
    emit(const PantryLoading());
    try {
      final ingredients = await repository.getIngredients();
      final expiring = await repository.getExpiring(days: 3);
      emit(PantryLoaded(
        ingredients: ingredients,
        expiringSoon: expiring,
      ));
    } catch (e) {
      emit(PantryError(_parseError(e)));
    }
  }

  void _onFilterPantry(FilterPantry event, Emitter<PantryState> emit) {
    if (state is PantryLoaded) {
      emit((state as PantryLoaded).copyWith(selectedFilter: event.filter));
    }
  }

  Future<void> _onRefreshPantry(
    RefreshPantry event,
    Emitter<PantryState> emit,
  ) async {
    if (state is! PantryLoaded) {
      emit(const PantryLoading());
    }
    try {
      final ingredients = await repository.getIngredients();
      final expiring = await repository.getExpiring(days: 3);
      
      String filter = 'all';
      if (state is PantryLoaded) {
        filter = (state as PantryLoaded).selectedFilter;
      }
      
      emit(PantryLoaded(
        ingredients: ingredients,
        expiringSoon: expiring,
        selectedFilter: filter,
      ));
    } catch (e) {
      emit(PantryError(_parseError(e)));
    }
  }

  Future<void> _onDeleteIngredient(
    DeleteIngredient event,
    Emitter<PantryState> emit,
  ) async {
    try {
      await repository.deleteIngredient(event.id);
      add(const RefreshPantry());
    } catch (e) {
      // In case of error we can just refresh to ensure state is synced
      add(const RefreshPantry());
    }
  }

  Future<void> _onAddIngredient(
    AddIngredient event,
    Emitter<PantryState> emit,
  ) async {
    emit(const PantryAddingIngredient());
    try {
      await repository.addIngredient(
        pantryId: 'default', // Temporary default
        name: event.name,
        quantity: event.quantity,
        unit: event.unit,
        category: event.category,
        expiryDate: event.expiryDate,
        imageUrl: event.imageUrl,
        storageLocation: event.storageLocation,
      );
      emit(const PantryIngredientAdded());
      add(const RefreshPantry());
    } catch (e) {
      emit(PantryError(_parseError(e)));
    }
  }

  Future<void> _onMoveIngredient(
    MoveIngredient event,
    Emitter<PantryState> emit,
  ) async {
    try {
      await repository.moveIngredient(event.id, event.storageLocation);
      add(const RefreshPantry());
    } catch (e) {
      emit(PantryError(_parseError(e)));
    }
  }

  // ─── Error Parser ──────────────────────────────────────────────────────────────
  String _parseError(dynamic e) {
    final raw = e.toString().toLowerCase();

    if (raw.contains('not found')) return 'Ingredient not found.';
    if (raw.contains('permission')) return "You don't have permission.";
    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('connection')) {
      return 'No internet connection.';
    }
    return 'Could not update pantry. Try again.';
  }
}
