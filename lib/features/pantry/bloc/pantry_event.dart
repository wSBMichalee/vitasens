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

class MoveIngredient extends PantryEvent {
  final String id;
  final String storageLocation;
  
  const MoveIngredient(this.id, this.storageLocation);
  
  @override 
  List<Object> get props => [id, storageLocation];
}

class FilterPantry extends PantryEvent {
  final String filter; // 'all' | 'expiring' | 'low_stock'

  const FilterPantry(this.filter);

  @override
  List<Object?> get props => [filter];
}

class AddIngredient extends PantryEvent {
  final String name;
  final double quantity;
  final String unit;
  final String? category;
  final DateTime? expiryDate;
  final String? imageUrl;
  final String storageLocation;

  const AddIngredient({
    required this.name,
    required this.quantity,
    required this.unit,
    this.category,
    this.expiryDate,
    this.imageUrl,
    this.storageLocation = 'fridge',
  });

  @override
  List<Object?> get props => [name, quantity, unit, category, expiryDate, imageUrl, storageLocation];
}
