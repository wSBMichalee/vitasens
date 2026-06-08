class MealModel {
  const MealModel({
    required this.id,
    required this.foodName,
    required this.mealTime,
    required this.mealDate,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
    this.photoUrl,
  });

  final String id;
  final String foodName;
  final String mealTime;
  final DateTime mealDate;
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;
  final String? photoUrl;

  factory MealModel.fromJson(Map<String, dynamic> json) => MealModel(
    id: json['id'] as String,
    foodName: json['food_name'] as String,
    mealTime: json['meal_time'] as String,
    mealDate: DateTime.parse(json['meal_date'] as String),
    calories: (json['calories'] as num?)?.toInt() ?? 0,
    proteinG: (json['protein_g'] as num?)?.toDouble() ?? 0,
    carbsG: (json['carbs_g'] as num?)?.toDouble() ?? 0,
    fatG: (json['fat_g'] as num?)?.toDouble() ?? 0,
    photoUrl: json['photo_url'] as String?,
  );
}
