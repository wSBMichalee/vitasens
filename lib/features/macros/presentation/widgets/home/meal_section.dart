import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/meals/data/meal_model.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/features/meals/presentation/widgets/meal_suggestion_card.dart';

class MealSection extends StatefulWidget {
  const MealSection({
    super.key,
    required this.title,
    required this.mealTime,
    required this.meals,
    required this.onDelete,
    this.isEditable = true,
    this.onMealLogged,
    this.pantryIsEmpty = false,
  });

  final String title;
  final String mealTime;
  final List<MealModel> meals;
  final void Function(String mealId) onDelete;
  final bool isEditable;
  final VoidCallback? onMealLogged;
  final bool pantryIsEmpty;

  @override
  State<MealSection> createState() => MealSectionState();
}

class MealSectionState extends State<MealSection> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    final totalKcal = widget.meals.fold(0, (sum, m) => sum + m.calories);
    final totalP = widget.meals.fold(0.0, (sum, m) => sum + m.proteinG);
    final totalC = widget.meals.fold(0.0, (sum, m) => sum + m.carbsG);
    final totalF = widget.meals.fold(0.0, (sum, m) => sum + m.fatG);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        children: [
          // Header sekcji
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 14.h, 12.w, 14.h),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Icon(
                    _expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                    size: 20.r,
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                      Text(
                        '$totalKcal kcal  •  P: ${totalP.round()}g  C: ${totalC.round()}g  F: ${totalF.round()}g',
                        style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),
                if (widget.isEditable)
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.aiMeals),
                    child: Container(
                      width: 32.r, height: 32.r,
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(Icons.add, color: AppColors.primary, size: 20.r),
                    ),
                  ),
              ],
            ),
          ),
          // Empty state gdy brak posiłków
          if (_expanded && widget.meals.isEmpty && widget.isEditable)
            Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: MealSuggestionCard(
                mealType: widget.mealTime,
                onLogged: widget.onMealLogged,
                pantryIsEmpty: widget.pantryIsEmpty,
              ),
            ),
          if (_expanded && widget.meals.isEmpty && !widget.isEditable)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 14.h),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(
                  child: Text('No meals added', style: TextStyle(fontSize: 13.sp, color: AppColors.textMuted)),
                ),
              ),
            ),
          // Lista posiłków
          if (_expanded && widget.meals.isNotEmpty)
            ...widget.meals.map((meal) => Padding(
              padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(meal.foodName, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                        Text('${meal.calories} kcal  •  P: ${meal.proteinG.round()}g  C: ${meal.carbsG.round()}g  F: ${meal.fatG.round()}g',
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onDelete(meal.id),
                    child: Icon(Icons.delete_outline, color: AppColors.textMuted, size: 18.r),
                  ),
                ],
              ),
            )),
        ],
      ),
    );
  }
}