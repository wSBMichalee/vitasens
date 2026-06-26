import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/macros/presentation/widgets/streak_celebration_modal.dart';
import 'package:vitasense/features/pantry/data/pantry_repository.dart';
import 'package:vitasense/features/voice/data/voice_repository.dart';
import 'package:vitasense/core/utils/bottom_sheet_utils.dart';

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
                              side: BorderSide(color: AppColors.border),
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
                            side: BorderSide(color: AppColors.border),
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

// ─── HEADER SECTION ───────────────────────────────────────────────────────────

class _HeaderSection extends StatelessWidget {
  final String foodName;
  final String confidenceIcon;
  final Color confidenceColor;
  final String confidenceLabel;
  final String cuisineType;
  final String mealType;

  const _HeaderSection({
    required this.foodName,
    required this.confidenceIcon,
    required this.confidenceColor,
    required this.confidenceLabel,
    required this.cuisineType,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 24.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Check icon
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 26.r),
          ),
          SizedBox(height: 14.h),

          // Food name
          Text(
            foodName,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 10.h),

          // Confidence badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$confidenceIcon $confidenceLabel',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Tags row: cuisine + meal type
          Row(
            children: [
              if (cuisineType.isNotEmpty) _HeaderTag(label: cuisineType),
              if (cuisineType.isNotEmpty && mealType.isNotEmpty) SizedBox(width: 8.w),
              if (mealType.isNotEmpty) _HeaderTag(label: mealType),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  final String label;
  const _HeaderTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}

// ─── MACRO CARD ───────────────────────────────────────────────────────────────

class _MacroCard extends StatelessWidget {
  final num calories;
  final num protein;
  final num carbs;
  final num fat;

  const _MacroCard({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calories
          Text(
            '${calories.toInt()}',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              height: 1,
            ),
          ),
          Text(
            'kcal',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),
          // Macros row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroItem(label: 'Protein', value: '${protein.toInt()}g', color: const Color(0xFF3B82F6)),
              _MacroDivider(),
              _MacroItem(label: 'Carbs', value: '${carbs.toInt()}g', color: const Color(0xFFF59E0B)),
              _MacroDivider(),
              _MacroItem(label: 'Fat', value: '${fat.toInt()}g', color: const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MacroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      width: 1,
      color: AppColors.borderLight,
    );
  }
}

// ─── SECTION CARD ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ],
    );
  }
}

// ─── DETAIL ROW ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── HEALTH SCORE ROW ─────────────────────────────────────────────────────────

class _HealthScoreRow extends StatelessWidget {
  final num score;
  final Color color;

  const _HealthScoreRow({required this.score, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Text(
            'Health Score',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4.r),
              child: LinearProgressIndicator(
                value: score / 10,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 8.h,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            '${score.toInt()}/10',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── INGREDIENT ROW ───────────────────────────────────────────────────────────

class _IngredientRow extends StatelessWidget {
  final String name;
  final int grams;
  final int calories;

  const _IngredientRow({
    required this.name,
    required this.grams,
    required this.calories,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        children: [
          Container(
            width: 32.r,
            height: 32.r,
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(Icons.restaurant_rounded, color: AppColors.primary, size: 16.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '${grams}g',
            style: TextStyle(
              fontSize: 13.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(width: 12.w),
          Text(
            '$calories kcal',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── TAG CHIP ─────────────────────────────────────────────────────────────────

class _TagChip extends StatelessWidget {
  final String label;

  const _TagChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ─── MEAL TYPE BUTTON ─────────────────────────────────────────────────────────

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
