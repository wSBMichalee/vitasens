import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/macros/presentation/widgets/streak_celebration_modal.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';
import 'package:vitasense/features/voice/data/voice_repository.dart';

class FoodDetectedScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const FoodDetectedScreen({super.key, required this.result});

  void _showMealTimeSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Select Meal Time',
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 24.h),
                _MealTypeButton(
                  title: 'Breakfast',
                  onTap: () => _logMeal(context, bottomSheetContext, 'breakfast'),
                ),
                SizedBox(height: 12.h),
                _MealTypeButton(
                  title: 'Lunch',
                  onTap: () => _logMeal(context, bottomSheetContext, 'lunch'),
                ),
                SizedBox(height: 12.h),
                _MealTypeButton(
                  title: 'Dinner',
                  onTap: () => _logMeal(context, bottomSheetContext, 'dinner'),
                ),
                SizedBox(height: 12.h),
                _MealTypeButton(
                  title: 'Snack',
                  onTap: () => _logMeal(context, bottomSheetContext, 'snack'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _logMeal(BuildContext context, BuildContext bottomSheetContext, String mealTime) async {
    Navigator.pop(bottomSheetContext); // close bottom sheet
    
    // Show loading or just do it
    final repo = VoiceRepository();
    final mealData = {
      'mealName': result['foodName'] ?? result['name'] ?? result['title'] ?? 'Scanned Food',
      'calories': result['calories'] ?? 0,
      'protein': result['protein'] ?? 0,
      'carbs': result['carbs'] ?? 0,
      'fat': result['fat'] ?? 0,
      'mealTime': mealTime,
    };
    
    try {
      await repo.logMeal(mealData);
      if (context.mounted) {
        await maybeShowStreakCelebration(context);
      }
      if (context.mounted) {
        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to log meal: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _addToPantry(BuildContext context) async {
    final repo = PantryRepository();
    try {
      await repo.addIngredient(
        pantryId: 'default',
        name: result['foodName'] ?? result['name'] ?? result['title'] ?? 'Scanned Food',
        quantity: 1.0,
        unit: 'pcs',
        category: 'grocery',
      );
      if (context.mounted) {
        context.go(AppRoutes.pantry);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to add to pantry: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final foodName = result['foodName'] ?? result['name'] ?? result['title'] ?? 'Unknown Product';
    final calories = result['calories'] ?? 0;
    final protein = result['protein'] ?? 0;
    final carbs = result['carbs'] ?? 0;
    final fat = result['fat'] ?? 0;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 64.h),
              Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 64.r,
              ),
              SizedBox(height: 24.h),
              Text(
                'Food detected!',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                foodName,
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 48.h),
              Container(
                padding: EdgeInsets.all(20.r),
                decoration: BoxDecoration(
                  color: const Color(0xFFF2F2F7),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Column(
                  children: [
                    _NutritionRow(label: 'Calories', value: '$calories kcal'),
                    const Divider(color: Color(0xFFE5E5EA), height: 24),
                    _NutritionRow(label: 'Protein', value: '${protein}g'),
                    const Divider(color: Color(0xFFE5E5EA), height: 24),
                    _NutritionRow(label: 'Carbs', value: '${carbs}g'),
                    const Divider(color: Color(0xFFE5E5EA), height: 24),
                    _NutritionRow(label: 'Fat', value: '${fat}g'),
                  ],
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: FilledButton(
                  onPressed: () => _showMealTimeSelector(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: Text(
                    "Add to Today's Meals",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: FilledButton(
                  onPressed: () => _addToPantry(context),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFF2F2F7),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28.r),
                    ),
                  ),
                  child: Text(
                    "Add to Pantry",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () => context.pop(),
                child: Text(
                  'Discard',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _NutritionRow extends StatelessWidget {
  final String label;
  final String value;

  const _NutritionRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}

class _MealTypeButton extends StatelessWidget {
  final String title;
  final VoidCallback onTap;

  const _MealTypeButton({required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 16.h),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(16.r),
        ),
        alignment: Alignment.center,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
