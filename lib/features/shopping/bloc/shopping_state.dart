import 'package:equatable/equatable.dart';
import 'package:vitasense/features/shopping/data/models/shopping_item_model.dart';

abstract class ShoppingState extends Equatable {
  const ShoppingState();

  @override
  List<Object?> get props => [];
}

class ShoppingInitial extends ShoppingState {
  const ShoppingInitial();
}

class ShoppingLoading extends ShoppingState {
  const ShoppingLoading();
}

class ShoppingLoaded extends ShoppingState {
  final List<ShoppingItemModel> items;
  final List<ShoppingItemModel> purchasedItems;

  const ShoppingLoaded(this.items, this.purchasedItems);

  @override
  List<Object?> get props => [items, purchasedItems];
}

class ShoppingError extends ShoppingState {
  final String message;

  const ShoppingError(this.message);

  @override
  List<Object?> get props => [message];
}

class ShoppingMovedToPantry extends ShoppingState {
  const ShoppingMovedToPantry();
}

