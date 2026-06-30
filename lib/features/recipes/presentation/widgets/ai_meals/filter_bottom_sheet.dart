import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class FilterBottomSheet extends StatefulWidget {
  const FilterBottomSheet({super.key});

  @override
  State<FilterBottomSheet> createState() => FilterBottomSheetState();
}

class FilterBottomSheetState extends State<FilterBottomSheet> {
  RangeValues _cookTimeRange = const RangeValues(0, 120);
  RangeValues _caloriesRange = const RangeValues(0, 1200);
  int _minIngredients = 0; // 0 = any, 1 = 1+, 3 = 3+, 5 = 5+

  static const _categories = ['ALL', 'BREAKFAST', 'LUNCH', 'DINNER', 'SNACK', 'DESSERT'];
  static const _quickFilters = [
    ('QUICK', 'Under 30 min'),
    ('HIGH PROTEIN', '25g+ protein'),
    ('LOW CARB', 'Under 20g carbs'),
    ('LOW CALORIE', 'Under 400 kcal'),
    ('VEGETARIAN', 'No meat'),
    ('VEGAN', 'Plant-based'),
    ('KETO', 'Very low carb'),
    ('GLUTEN FREE', 'No gluten'),
  ];
  static const _cuisines = [
    ('ITALIAN', '🇮🇹'),
    ('ASIAN', '🥢'),
    ('MEXICAN', '🌮'),
    ('MEDITERRANEAN', '🫒'),
    ('INDIAN', '🍛'),
    ('AMERICAN', '🍔'),
    ('FRENCH', '🥐'),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RecipesBloc, RecipesState>(
      builder: (context, state) {
        final selectedCategory = state is RecipesLoaded ? state.selectedCategory : 'ALL';
        final activeFilters = state is RecipesLoaded ? state.activeFilters : <String>{};
        final hasAny = activeFilters.isNotEmpty || selectedCategory != 'ALL';

        return DraggableScrollableSheet(
          initialChildSize: 0.92,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return Container(
              padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle
                Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    child: Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: AppColors.borderMedium, borderRadius: BorderRadius.circular(2.r))),
                  ),
                ),
                // Header
                Row(
                  children: [
                    Expanded(child: Text('Filters', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black))),
                    if (hasAny)
                      GestureDetector(
                        onTap: () => context.read<RecipesBloc>().add(const ClearRecipeFilters()),
                        child: Text('Clear all', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      ),
                    SizedBox(width: 12.w),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32.r, height: 32.r,
                        decoration: const BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle),
                        child: Icon(Icons.close, color: AppColors.textPrimary, size: 18.r),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24.h),

                // ── Meal Type ──
                Row(children: [
                  Icon(Icons.restaurant_menu_outlined, color: AppColors.primary, size: 16.r),
                  SizedBox(width: 6.w),
                  Text('Meal Type', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                ]),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _categories.map((cat) {
                    final selected = selectedCategory == cat;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.read<RecipesBloc>().add(SetRecipeCategory(cat));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.backgroundWhite,
                          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(cat, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: selected ? AppColors.textWhite : AppColors.textSecondary)),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),

                // ── Diet & Nutrition ──
                Row(children: [
                  Icon(Icons.monitor_heart_outlined, color: AppColors.primary, size: 16.r),
                  SizedBox(width: 6.w),
                  Text('Diet & Nutrition', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                ]),
                SizedBox(height: 12.h),
                _FilterChipsSection(
                  activeFilters: activeFilters,
                  onToggle: (filter) {
                    HapticFeedback.selectionClick();
                    context.read<RecipesBloc>().add(ToggleRecipeFilter(filter));
                  },
                ),
                SizedBox(height: 24.h),

                // ── Cook Time ──
                Row(children: [
                  Icon(Icons.timer_outlined, color: AppColors.primary, size: 16.r),
                  SizedBox(width: 6.w),
                  Text('Cook Time', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                ]),
                SizedBox(height: 4.h),
                _CookTimeSlider(
                  minCookTime: _cookTimeRange.start.round(),
                  maxCookTime: _cookTimeRange.end.round(),
                  onChanged: (min, max) => setState(() => _cookTimeRange = RangeValues(min.toDouble(), max.toDouble())),
                ),
                SizedBox(height: 20.h),

                // ── Calories ──
                Row(children: [
                  Icon(Icons.local_fire_department_outlined, color: AppColors.primary, size: 16.r),
                  SizedBox(width: 6.w),
                  Text('Calories', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                ]),
                SizedBox(height: 4.h),
                _CaloriesSlider(
                  minCalories: _caloriesRange.start.round(),
                  maxCalories: _caloriesRange.end.round(),
                  onChanged: (min, max) => setState(() => _caloriesRange = RangeValues(min.toDouble(), max.toDouble())),
                ),
                SizedBox(height: 20.h),

                // ── Cuisine ──
                Row(children: [
                  Icon(Icons.public_outlined, color: AppColors.primary, size: 16.r),
                  SizedBox(width: 6.w),
                  Text('Cuisine', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                ]),
                SizedBox(height: 12.h),
                _CuisineChipsSection(
                  activeFilters: activeFilters,
                  onToggle: (filter) {
                    HapticFeedback.selectionClick();
                    context.read<RecipesBloc>().add(ToggleRecipeFilter(filter));
                  },
                ),
                SizedBox(height: 20.h),

                // ── Spice Level ──
                Row(children: [
                  Icon(Icons.whatshot_outlined, color: AppColors.warning, size: 16.r),
                  SizedBox(width: 6.w),
                  Text('Spice Level', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                ]),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    ('MILD', 'mild', '🟢'),
                    ('MEDIUM', 'medium', '🟡'),
                    ('HOT', 'hot', '🔴'),
                    ('VERY HOT', 'very-hot', '🌶'),
                  ].map((s) {
                    final active = activeFilters.contains(s.$2);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        context.read<RecipesBloc>().add(ToggleRecipeFilter(s.$2));
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: active ? AppColors.warningLight : AppColors.backgroundWhite,
                          border: Border.all(color: active ? AppColors.warning : AppColors.border),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(s.$3, style: TextStyle(fontSize: 14.sp)),
                            SizedBox(width: 6.w),
                            Text(s.$1, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: active ? AppColors.warning : AppColors.textSecondary)),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 20.h),

                // ── Ingredients Available ──
                Row(children: [
                  Icon(Icons.kitchen_outlined, color: AppColors.primary, size: 16.r),
                  SizedBox(width: 6.w),
                  Text('Ingredients Available', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                ]),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: [
                    ('Any', 0),
                    ('1+ have', 1),
                    ('3+ have', 3),
                    ('5+ have', 5),
                  ].map((opt) {
                    final selected = _minIngredients == opt.$2;
                    return GestureDetector(
                      onTap: () => setState(() => _minIngredients = opt.$2),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primaryLight : AppColors.backgroundWhite,
                          border: Border.all(color: selected ? AppColors.primary : AppColors.border),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(opt.$1, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: selected ? AppColors.primary : AppColors.textSecondary)),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 32.h),

                // ── Apply button ──
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton(
                    onPressed: () {
                      context.read<RecipesBloc>().add(ApplyRangeFilters(
                        minCookTime: _cookTimeRange.start.round(),
                        maxCookTime: _cookTimeRange.end.round(),
                        minCalories: _caloriesRange.start.round(),
                        maxCalories: _caloriesRange.end.round(),
                        minIngredients: _minIngredients,
                      ));
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
                    ),
                    child: Text(
                      hasAny || _cookTimeRange.start > 0 || _cookTimeRange.end < 120 || _caloriesRange.start > 0 || _caloriesRange.end < 1200 || _minIngredients > 0 ? 'Apply filters' : 'Close',
                      style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textWhite),
                    ),
                  ),
                ),
              ],
            ),
            ),
          );
        },
      );
    });
  }
}

class _FilterChipsSection extends StatelessWidget {
  final Set<String> activeFilters;
  final Function(String) onToggle;

  const _FilterChipsSection({required this.activeFilters, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: FilterBottomSheetState._quickFilters.map((f) {
        final active = activeFilters.contains(f.$1);
        return GestureDetector(
          onTap: () => onToggle(f.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: active ? AppColors.primaryLight : AppColors.backgroundWhite,
              border: Border.all(color: active ? AppColors.primary : AppColors.border),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(f.$1, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: active ? AppColors.primary : AppColors.textPrimary)),
                Text(f.$2, style: TextStyle(fontSize: 10.sp, color: active ? AppColors.primary : AppColors.textMuted)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _CookTimeSlider extends StatelessWidget {
  final int minCookTime;
  final int maxCookTime;
  final Function(int, int) onChanged;

  const _CookTimeSlider({required this.minCookTime, required this.maxCookTime, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$minCookTime min', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
            Text('${maxCookTime == 120 ? '120+' : maxCookTime.toString()} min', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.borderLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            trackHeight: 4,
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: RangeSlider(
            values: RangeValues(minCookTime.toDouble(), maxCookTime.toDouble()),
            min: 0,
            max: 120,
            divisions: 12,
            onChanged: (v) => onChanged(v.start.round(), v.end.round()),
          ),
        ),
      ],
    );
  }
}

class _CaloriesSlider extends StatelessWidget {
  final int minCalories;
  final int maxCalories;
  final Function(int, int) onChanged;

  const _CaloriesSlider({required this.minCalories, required this.maxCalories, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$minCalories kcal', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
            Text('${maxCalories == 1200 ? '1200+' : maxCalories.toString()} kcal', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.borderLight,
            thumbColor: AppColors.primary,
            overlayColor: AppColors.primary.withValues(alpha: 0.1),
            trackHeight: 4,
            rangeThumbShape: const RoundRangeSliderThumbShape(enabledThumbRadius: 10),
          ),
          child: RangeSlider(
            values: RangeValues(minCalories.toDouble(), maxCalories.toDouble()),
            min: 0,
            max: 1200,
            divisions: 12,
            onChanged: (v) => onChanged(v.start.round(), v.end.round()),
          ),
        ),
      ],
    );
  }
}

class _CuisineChipsSection extends StatelessWidget {
  final Set<String> activeFilters;
  final Function(String) onToggle;

  const _CuisineChipsSection({required this.activeFilters, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.w,
      runSpacing: 8.h,
      children: FilterBottomSheetState._cuisines.map((c) {
        final active = activeFilters.contains(c.$1);
        return GestureDetector(
          onTap: () => onToggle(c.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: active ? AppColors.secondaryLight : AppColors.backgroundWhite,
              border: Border.all(color: active ? AppColors.secondary : AppColors.border),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(c.$2, style: TextStyle(fontSize: 16.sp)),
                SizedBox(width: 6.w),
                Text(c.$1, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: active ? AppColors.secondary : AppColors.textSecondary)),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}