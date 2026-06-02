class RecipeModel {
  final String id;
  final String title;
  final String description;
  final List<Map<String, dynamic>> ingredients;
  final List<String> steps;
  final int cookTimeMinutes;
  final int servings;
  final int calories;
  final double protein;
  final double carbs;
  final double fat;
  final String? imageUrl;
  final bool isPublished;
  final int likesCount;
  final String authorId;
  final String authorName;
  final String? cuisineType;
  final List<String> dietTags;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RecipeModel({
    required this.id,
    required this.title,
    required this.description,
    this.ingredients = const [],
    this.steps = const [],
    required this.cookTimeMinutes,
    required this.servings,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.imageUrl,
    this.isPublished = false,
    this.likesCount = 0,
    required this.authorId,
    required this.authorName,
    this.cuisineType,
    this.dietTags = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory RecipeModel.fromJson(Map<String, dynamic> json) {
    return RecipeModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e as Map<String, dynamic>)
              .toList() ??
          [],
      steps: (json['steps'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      cookTimeMinutes: json['cook_time_minutes'] as int? ?? 0,
      servings: json['servings'] as int? ?? 1,
      calories: json['calories'] as int? ?? 0,
      protein: (json['protein'] as num?)?.toDouble() ?? 0.0,
      carbs: (json['carbs'] as num?)?.toDouble() ?? 0.0,
      fat: (json['fat'] as num?)?.toDouble() ?? 0.0,
      imageUrl: json['image_url'] as String?,
      isPublished: json['is_published'] as bool? ?? false,
      likesCount: json['likes_count'] as int? ?? 0,
      authorId: json['author_id'] as String? ?? '',
      authorName: json['author_name'] as String? ?? '',
      cuisineType: json['cuisine_type'] as String?,
      dietTags: (json['diet_tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'ingredients': ingredients,
      'steps': steps,
      'cook_time_minutes': cookTimeMinutes,
      'servings': servings,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'image_url': imageUrl,
      'is_published': isPublished,
      'likes_count': likesCount,
      'author_id': authorId,
      'author_name': authorName,
      'cuisine_type': cuisineType,
      'diet_tags': dietTags,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
