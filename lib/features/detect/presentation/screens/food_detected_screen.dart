import 'package:vitasense/core/utils/snackbar_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/macros/presentation/widgets/streak_celebration_modal.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';
import 'package:vitasense/features/voice/data/voice_repository.dart';
import 'package:vitasense/core/utils/bottom_sheet_utils.dart';

part '../widgets/food_detected/header_section.dart';
part '../widgets/food_detected/macro_section.dart';
part '../widgets/food_detected/nutrition_section.dart';
part '../widgets/food_detected/ingredients_section.dart';
part '../widgets/food_detected/action_buttons.dart';

class FoodDetectedScreen extends StatelessWidget {
  final Map<String, dynamic> result;

  const FoodDetectedScreen({super.key, required this.result});

  void _showMealTimeSelector(BuildContext context) {
    showAppBottomSheet(
      context: context,
      builder: (bottomSheetContext) {
        return Padding(
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
        SnackbarUtils.showError(context, 'Failed to log meal: $e');
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
        SnackbarUtils.showError(context, 'Failed to add to pantry: $e');
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
    final fiber = result['fiber'] ?? 0;
    final sugar = result['sugar'] ?? 0;
    final sodium = result['sodium'] ?? 0;
    final confidence = (result['confidence'] ?? 'medium').toString().toLowerCase();
    final cuisineType = result['cuisineType'] ?? '';
    final mealType = result['mealType'] ?? '';
    final healthScore = (result['healthScore'] ?? 5) as num;
    final tags = List<String>.from(result['tags'] ?? []);
    final ingredients = List<Map<String, dynamic>>.from(
      (result['ingredients'] ?? []).map((e) => Map<String, dynamic>.from(e as Map)),
    );
    final notes = result['notes'] ?? '';

    // Confidence badge data
    final (confidenceIcon, confidenceColor, confidenceLabel) = switch (confidence) {
      'high' => ('🟢', const Color(0xFF22C55E), 'High confidence'),
      'low' => ('🔴', const Color(0xFFEF4444), 'Low confidence'),
      _ => ('🟡', const Color(0xFFF59E0B), 'Medium confidence'),
    };

    // Health score color
    final healthColor = healthScore >= 7
        ? AppColors.primary
        : healthScore >= 4
            ? const Color(0xFFF59E0B)
            : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ── SCROLLABLE CONTENT ─────────────────────────────────────────────
          SingleChildScrollView(
            padding: EdgeInsets.only(bottom: 160.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── HEADER WITH FOOD IMAGE / GRADIENT ────────────────────────
                _HeaderSection(
                  foodName: foodName,
                  confidenceIcon: confidenceIcon,
                  confidenceColor: confidenceColor,
                  confidenceLabel: confidenceLabel,
                  cuisineType: cuisineType,
                  mealType: mealType,
                ),

                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 20.h),

                      // ── MAIN MACRO CARD ──────────────────────────────────────
                      _MacroCard(
                        calories: calories,
                        protein: protein,
                        carbs: carbs,
                        fat: fat,
                      ),

                      SizedBox(height: 16.h),

                      // ── NUTRITION DETAILS ────────────────────────────────────
                      _SectionCard(
                        title: 'Nutrition Details',
                        child: Column(
                          children: [
                            _DetailRow(label: 'Fiber', value: '${fiber}g'),
                            Divider(color: AppColors.borderLight, height: 1.h),
                            _DetailRow(label: 'Sugar', value: '${sugar}g'),
                            Divider(color: AppColors.borderLight, height: 1.h),
                            _DetailRow(label: 'Sodium', value: '${sodium}mg'),
                            Divider(color: AppColors.borderLight, height: 1.h),
                            _HealthScoreRow(score: healthScore, color: healthColor),
                          ],
                        ),
                      ),

                      SizedBox(height: 16.h),

                      // ── DETECTED INGREDIENTS ────────────────────────────────
                      if (ingredients.isNotEmpty) ...[
                        _SectionCard(
                          title: 'Detected Ingredients',
                          child: Column(
                            children: ingredients.asMap().entries.map((entry) {
                              final i = entry.key;
                              final ing = entry.value;
                              final name = ing['name']?.toString() ?? '';
                              final grams = (ing['estimatedGrams'] ?? 0) as num;
                              final ingCal = (ing['calories'] ?? 0) as num;
                              return Column(
                                children: [
                                  if (i > 0) Divider(color: AppColors.borderLight, height: 1.h),
                                  _IngredientRow(
                                    name: name,
                                    grams: grams.toInt(),
                                    calories: ingCal.toInt(),
                                  ),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // ── TAGS ─────────────────────────────────────────────────
                      if (tags.isNotEmpty) ...[
                        Text(
                          'Tags',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: tags.map((tag) => _TagChip(label: tag)).toList(),
                        ),
                        SizedBox(height: 16.h),
                      ],

                      // ── NOTES ────────────────────────────────────────────────
                      if (notes.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(14.r),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.info_outline_rounded, color: AppColors.primary, size: 18.r),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  notes,
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 16.h),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── STICKY BOTTOM BAR ───────────────────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 36.h),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.06),
                    blurRadius: 20,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: FilledButton(
                      onPressed: () => _showMealTimeSelector(context),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Log as ${_capitalize(mealType.isNotEmpty ? mealType : 'Meal')}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Row(
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 48.h,
                          child: OutlinedButton(
                            onPressed: () => _addToPantry(context),
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.border),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                            child: Text(
                              'Add to Pantry',
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10.w),
                      SizedBox(
                        height: 48.h,
                        child: OutlinedButton(
                          onPressed: () => context.pop(),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.border),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            padding: EdgeInsets.symmetric(horizontal: 20.w),
                          ),
                          child: Text(
                            'Discard',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}
