import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'recipe_nutrition_tile.dart';

class RecipeNutritionSection extends StatelessWidget {
  final int calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const RecipeNutritionSection({
    super.key,
    required this.calories,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.monitor_heart_outlined, color: AppColors.primary, size: 18.r),
          SizedBox(width: 8.w),
          Text('Nutrition per serving', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        SizedBox(height: 12.h),
        Row(children: [
          NutritionTile(label: 'Calories', value: '$calories', unit: 'kcal', color: AppColors.primary),
          SizedBox(width: 8.w),
          NutritionTile(label: 'Protein', value: proteinG.toStringAsFixed(1), unit: 'g', color: AppColors.proteinColor),
          SizedBox(width: 8.w),
          NutritionTile(label: 'Carbs', value: carbsG.toStringAsFixed(1), unit: 'g', color: AppColors.carbsColor),
          SizedBox(width: 8.w),
          NutritionTile(label: 'Fat', value: fatG.toStringAsFixed(1), unit: 'g', color: AppColors.fatColor),
        ]),
      ],
    );
  }
}
