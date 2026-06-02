class ExtractedRecipeModel {
  final String title;
  final String? description;
  final String? imageUrl;
  final String? sourceUrl;
  final String? prepTime;
  final String? cookTime;
  final String? servings;
  final List<String> ingredients;
  final List<String> instructions;

  const ExtractedRecipeModel({
    required this.title,
    this.description,
    this.imageUrl,
    this.sourceUrl,
    this.prepTime,
    this.cookTime,
    this.servings,
    this.ingredients = const [],
    this.instructions = const [],
  });

  factory ExtractedRecipeModel.fromJson(Map<String, dynamic> json) {
    return ExtractedRecipeModel(
      title: json['title'] as String? ?? 'Imported Recipe',
      description: json['description'] as String?,
      imageUrl: json['image_url'] as String?,
      sourceUrl: json['source_url'] as String?,
      prepTime: json['prep_time'] as String?,
      cookTime: json['cook_time'] as String?,
      servings: json['servings'] as String?,
      ingredients: (json['ingredients'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      instructions: (json['instructions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'source_url': sourceUrl,
      'prep_time': prepTime,
      'cook_time': cookTime,
      'servings': servings,
      'ingredients': ingredients,
      'instructions': instructions,
    };
  }
}
