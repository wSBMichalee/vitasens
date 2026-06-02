class ShoppingItemModel {
  final String id;
  final String name;
  final double quantity;
  final String unit;
  final String? category;
  final bool isPurchased;
  final String? addedBy;
  final DateTime? createdAt;
  final String? pantryItemId;

  const ShoppingItemModel({
    required this.id,
    required this.name,
    required this.quantity,
    required this.unit,
    this.category,
    this.isPurchased = false,
    this.addedBy,
    this.createdAt,
    this.pantryItemId,
  });

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: json['id'] as String,
      name: json['name'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      category: json['category'] as String?,
      isPurchased: json['is_purchased'] as bool? ?? false,
      addedBy: json['added_by'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      pantryItemId: json['pantry_item_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'category': category,
      'is_purchased': isPurchased,
      'added_by': addedBy,
      'created_at': createdAt?.toIso8601String(),
      'pantry_item_id': pantryItemId,
    };
  }

  ShoppingItemModel copyWith({
    String? id,
    String? name,
    double? quantity,
    String? unit,
    String? category,
    bool? isPurchased,
    String? addedBy,
    DateTime? createdAt,
    String? pantryItemId,
  }) {
    return ShoppingItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      unit: unit ?? this.unit,
      category: category ?? this.category,
      isPurchased: isPurchased ?? this.isPurchased,
      addedBy: addedBy ?? this.addedBy,
      createdAt: createdAt ?? this.createdAt,
      pantryItemId: pantryItemId ?? this.pantryItemId,
    );
  }
}
