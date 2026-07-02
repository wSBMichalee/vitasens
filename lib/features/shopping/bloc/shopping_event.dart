import 'package:equatable/equatable.dart';

abstract class ShoppingEvent extends Equatable {
  const ShoppingEvent();

  @override
  List<Object?> get props => [];
}

class LoadShoppingList extends ShoppingEvent {
  const LoadShoppingList();
}

class AddShoppingItem extends ShoppingEvent {
  final String name;
  final double quantity;
  final String unit;

  const AddShoppingItem(this.name, this.quantity, this.unit);

  @override
  List<Object?> get props => [name, quantity, unit];
}

class MarkItemPurchased extends ShoppingEvent {
  final String itemId;

  const MarkItemPurchased(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class DeleteShoppingItem extends ShoppingEvent {
  final String itemId;

  const DeleteShoppingItem(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class ClearPurchasedItems extends ShoppingEvent {
  const ClearPurchasedItems();
}

class MoveAllToPantry extends ShoppingEvent {
  const MoveAllToPantry();
}

class LoadShoppingHistory extends ShoppingEvent {
  const LoadShoppingHistory();
}
