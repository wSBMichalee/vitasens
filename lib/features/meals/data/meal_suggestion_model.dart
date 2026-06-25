class MealSuggestionModel {
  final String id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? mealType;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final int cookTimeMinutes;
  final String? cuisineType;
  final int servings;
  final List<Map<String, dynamic>> ingredients;
  final List<Map<String, dynamic>> missedIngredients;
  final List<Map<String, dynamic>> usedIngredients;

  const MealSuggestionModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.mealType,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    required this.cookTimeMinutes,
    this.cuisineType,
    required this.servings,
    this.ingredients = const [],
    this.missedIngredients = const [],
    this.usedIngredients = const [],
  });

  factory MealSuggestionModel.fromJson(Map<String, dynamic> json) {
    return MealSuggestionModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      imageUrl: json['imageUrl'] as String?,
      mealType: json['mealType'] as String?,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      proteinG: (json['proteinG'] as num?)?.toDouble() ?? 0.0,
      carbsG: (json['carbsG'] as num?)?.toDouble() ?? 0.0,
      fatG: (json['fatG'] as num?)?.toDouble() ?? 0.0,
      cookTimeMinutes: (json['cookTimeMinutes'] as num?)?.toInt() ?? 30,
      cuisineType: json['cuisineType'] as String?,
      servings: (json['servings'] as num?)?.toInt() ?? 4,
      ingredients: (json['ingredients'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      missedIngredients: (json['missedIngredients'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
      usedIngredients: (json['usedIngredients'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e as Map))
          .toList(),
    );
  }
}
