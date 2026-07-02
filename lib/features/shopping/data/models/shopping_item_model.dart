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
  final DateTime? purchasedAt;

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
    this.purchasedAt,
  });

  factory ShoppingItemModel.fromJson(Map<String, dynamic> json) {
    return ShoppingItemModel(
      id: (json['id'] ?? '').toString(),
      name: (json['ingredientName'] ?? json['ingredient_name'] ?? json['name'] ?? '').toString(),
      quantity: (json['quantityNeeded'] as num?)?.toDouble() ?? (json['quantity_needed'] as num?)?.toDouble() ?? (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unit: (json['unit'] ?? 'szt').toString(),
      category: json['category']?.toString(),
      isPurchased: json['isPurchased'] as bool? ?? json['is_purchased'] as bool? ?? false,
      addedBy: json['added_by']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      pantryItemId: json['pantry_item_id']?.toString(),
      purchasedAt: json['purchased_at'] != null
          ? DateTime.tryParse(json['purchased_at'].toString())
          : null,
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
      'purchased_at': purchasedAt?.toIso8601String(),
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
    DateTime? purchasedAt,
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
      purchasedAt: purchasedAt ?? this.purchasedAt,
    );
  }
}
