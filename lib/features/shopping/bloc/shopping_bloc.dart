import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_event.dart';
import 'package:vitasense/features/shopping/bloc/shopping_state.dart';
import 'package:vitasense/features/shopping/data/shopping_repository.dart';

class ShoppingBloc extends Bloc<ShoppingEvent, ShoppingState> {
  final ShoppingRepository _repository;

  ShoppingBloc({ShoppingRepository? repository})
      : _repository = repository ?? ShoppingRepository(),
        super(const ShoppingInitial()) {
    on<LoadShoppingList>(_onLoadShoppingList);
    on<AddShoppingItem>(_onAddShoppingItem);
    on<MarkItemPurchased>(_onMarkItemPurchased);
    on<DeleteShoppingItem>(_onDeleteShoppingItem);
    on<ClearPurchasedItems>(_onClearPurchasedItems);
    on<MoveAllToPantry>(_onMoveAllToPantry);
  }

  Future<void> _onLoadShoppingList(
    LoadShoppingList event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(const ShoppingLoading());
    try {
      final allItems = await _repository.getItems();
      
      final itemsToBuy = allItems.where((item) => !item.isPurchased).toList();
      final purchasedItems = allItems.where((item) => item.isPurchased).toList();
      
      emit(ShoppingLoaded(itemsToBuy, purchasedItems));
    } catch (e) {
      emit(ShoppingError(_parseError(e)));
    }
  }

  Future<void> _onAddShoppingItem(
    AddShoppingItem event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(const ShoppingLoading());
    try {
      await _repository.addItem(event.name, event.quantity, event.unit);
      add(const LoadShoppingList()); // reload
    } catch (e) {
      emit(ShoppingError(_parseError(e)));
      add(const LoadShoppingList()); // reload on error to restore view
    }
  }

  Future<void> _onMarkItemPurchased(
    MarkItemPurchased event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(const ShoppingLoading());
    try {
      await _repository.markPurchased(event.itemId);
      add(const LoadShoppingList()); // reload
    } catch (e) {
      emit(ShoppingError(_parseError(e)));
      add(const LoadShoppingList());
    }
  }

  Future<void> _onDeleteShoppingItem(
    DeleteShoppingItem event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(const ShoppingLoading());
    try {
      await _repository.deleteItem(event.itemId);
      add(const LoadShoppingList()); // reload
    } catch (e) {
      emit(ShoppingError(_parseError(e)));
      add(const LoadShoppingList());
    }
  }

  Future<void> _onClearPurchasedItems(
    ClearPurchasedItems event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(const ShoppingLoading());
    try {
      await _repository.clearPurchased();
      add(const LoadShoppingList()); // reload
    } catch (e) {
      emit(ShoppingError(_parseError(e)));
      add(const LoadShoppingList());
    }
  }

  Future<void> _onMoveAllToPantry(
    MoveAllToPantry event,
    Emitter<ShoppingState> emit,
  ) async {
    emit(const ShoppingLoading());
    try {
      await _repository.moveToPantry();
      add(const LoadShoppingList()); // reload
    } catch (e) {
      emit(ShoppingError(_parseError(e)));
      add(const LoadShoppingList());
    }
  }

  // ─── Error Parser ──────────────────────────────────────────────────────────────
  String _parseError(dynamic e) {
    print('ShoppingBloc error: $e');
    final raw = e.toString().toLowerCase();

    if (raw.contains('network') ||
        raw.contains('socket') ||
        raw.contains('connection')) {
      return 'No internet connection.';
    }
    return e.toString();
  }
}
