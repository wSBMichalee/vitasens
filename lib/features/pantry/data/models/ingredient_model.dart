import 'package:equatable/equatable.dart';

class IngredientModel extends Equatable {
  final String id;
  final String? pantryId;
  final String name;
  final double quantity;
  final String unit;
  final String category;
  final double minimumQuantity;
  final DateTime? expiryDate;
  final String? addedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? barcode;
  final String? brand;

  const IngredientModel({
    required this.id,
    this.pantryId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.category,
    required this.minimumQuantity,
    this.expiryDate,
    this.addedBy,
    this.createdAt,
    this.updatedAt,
    this.barcode,
    this.brand,
  });

  factory IngredientModel.fromJson(Map<String, dynamic> json) {
    return IngredientModel(
      id: json['id'] as String? ?? '',
      pantryId: (json['pantry_id'] ?? json['pantryId']) as String?,
      name: json['name'] as String? ?? '',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0.0,
      unit: json['unit'] as String? ?? '',
      category: json['category'] as String? ?? 'other',
      minimumQuantity: (json['minimum_quantity'] ?? json['minimumQuantity'] as num?)?.toDouble() ?? 0.0,
      expiryDate: (json['expiry_date'] ?? json['expiryDate']) != null 
          ? DateTime.tryParse((json['expiry_date'] ?? json['expiryDate']) as String) 
          : null,
      addedBy: (json['added_by'] ?? json['addedBy']) as String?,
      createdAt: (json['created_at'] ?? json['createdAt']) != null 
          ? DateTime.tryParse((json['created_at'] ?? json['createdAt']) as String) 
          : null,
      updatedAt: (json['updated_at'] ?? json['updatedAt']) != null 
          ? DateTime.tryParse((json['updated_at'] ?? json['updatedAt']) as String) 
          : null,
      barcode: json['barcode'] as String?,
      brand: json['brand'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pantry_id': pantryId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'minimum_quantity': minimumQuantity,
      'expiry_date': expiryDate?.toIso8601String(),
      'added_by': addedBy,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'barcode': barcode,
      'brand': brand,
    };
  }

  @override
  List<Object?> get props => [
        id,
        pantryId,
        name,
        quantity,
        unit,
        category,
        minimumQuantity,
        expiryDate,
        addedBy,
        createdAt,
        updatedAt,
        barcode,
        brand,
      ];
}
