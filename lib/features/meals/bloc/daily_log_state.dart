import '../data/meal_model.dart';

abstract class DailyLogState {
  const DailyLogState();
}

class DailyLogInitial extends DailyLogState {
  const DailyLogInitial();
}

class DailyLogLoading extends DailyLogState {
  const DailyLogLoading();
}

class DailyLogLoaded extends DailyLogState {
  const DailyLogLoaded(this.meals);
  final List<MealModel> meals;

  List<MealModel> get breakfast => meals.where((m) => m.mealTime == 'breakfast').toList();
  List<MealModel> get lunch => meals.where((m) => m.mealTime == 'lunch').toList();
  List<MealModel> get dinner => meals.where((m) => m.mealTime == 'dinner').toList();
  List<MealModel> get snack => meals.where((m) => m.mealTime == 'snack').toList();

  int get totalCalories => meals.fold(0, (sum, m) => sum + m.calories);
  double get totalProtein => meals.fold(0, (sum, m) => sum + m.proteinG);
  double get totalCarbs => meals.fold(0, (sum, m) => sum + m.carbsG);
  double get totalFat => meals.fold(0, (sum, m) => sum + m.fatG);
}

class DailyLogError extends DailyLogState {
  const DailyLogError(this.message);
  final String message;
}
