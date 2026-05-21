import 'package:equatable/equatable.dart';

abstract class PantryEvent extends Equatable {
  const PantryEvent();

  @override
  List<Object?> get props => [];
}

class LoadPantry extends PantryEvent {
  const LoadPantry();
}

class RefreshPantry extends PantryEvent {
  const RefreshPantry();
}

class DeleteIngredient extends PantryEvent {
  final String id;

  const DeleteIngredient(this.id);

  @override
  List<Object?> get props => [id];
}

class AddIngredient extends PantryEvent {
  final String name;
  final double quantity;
  final String unit;
  final String? category;
  final DateTime? expiryDate;

  const AddIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.category,
    this.expiryDate,
  });

  @override
  List<Object?> get props => [name, quantity, unit, category, expiryDate];
}
