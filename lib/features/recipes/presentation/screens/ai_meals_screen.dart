import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/features/shopping/bloc/shopping_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_event.dart';

const _defaultIngredients = [
  'chicken',
  'pasta',
  'rice',
  'eggs',
  'onion',
  'garlic',
  'tomatoes',
  'olive oil',
  'bread',
  'cheese',
];

class AiMealsScreen extends StatefulWidget {
  const AiMealsScreen({super.key, this.ingredients});

  final List<String>? ingredients;

  @override
  State<AiMealsScreen> createState() => _AiMealsScreenState();
}

class _AiMealsScreenState extends State<AiMealsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pantry = (widget.ingredients?.isNotEmpty == true)
          ? widget.ingredients!
          : _defaultIngredients;
      context.read<RecipesBloc>().add(LoadRecipes(pantry));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppHeader: wariant main, spinner jako action podczas ładowania ────
            BlocBuilder<RecipesBloc, RecipesState>(
              builder: (context, state) {
                final isLoading = state is RecipesLoading;
                return AppHeader(
                  title: 'AI Meals',
                  subtitle: 'Based on your pantry',
                  variant: AppHeaderVariant.main,
                  backgroundColor: AppColors.primary,
                  textColor: AppColors.textWhite,
                  actions: [
                    if (isLoading)
                      SizedBox(width: 20.r, height: 20.r, child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.savedRecipes),
                      child: Container(
                        width: 40.r, height: 40.r,
                        decoration: BoxDecoration(
                          color: AppColors.textWhite.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.bookmark_border, color: AppColors.textWhite, size: 20.r),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    BlocBuilder<RecipesBloc, RecipesState>(
                      builder: (context, state) {
                        final activeFilters = state is RecipesLoaded ? state.activeFilters : <String>{};
                        final selectedCategory = state is RecipesLoaded ? state.selectedCategory : 'ALL';
                        final hasActive = activeFilters.isNotEmpty || selectedCategory != 'ALL';
                        return GestureDetector(
                          onTap: () => showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => BlocProvider.value(
                              value: context.read<RecipesBloc>(),
                              child: const _FilterBottomSheet(),
                            ),
                          ),
                          child: Container(
                            width: 40.r, height: 40.r,
                            decoration: BoxDecoration(
                              color: hasActive ? AppColors.primary : AppColors.borderLight,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.tune_rounded, color: hasActive ? AppColors.textWhite : AppColors.textPrimary, size: 20.r),
                          ),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            Expanded(
              child: BlocBuilder<RecipesBloc, RecipesState>(
                builder: (context, state) {
                  if (state is RecipesLoading) {
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
                      itemCount: 4,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: Shimmer.fromColors(
                            baseColor: AppColors.borderLight,
                            highlightColor: AppColors.border,
                            child: Container(
                              height: 250.h,
                              decoration: BoxDecoration(
                                color: AppColors.backgroundWhite,
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  if (state is RecipesError) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.error_outline,
                              color: AppColors.error, size: 40.r),
                          SizedBox(height: 12.h),
                          Text(state.message, style: AppTextStyles.bodyMedium),
                          SizedBox(height: 16.h),
                          SizedBox(
                            height: 50.h,
                            child: FilledButton(
                              onPressed: () {
                                final pantry =
                                    (widget.ingredients?.isNotEmpty == true)
                                        ? widget.ingredients!
                                        : _defaultIngredients;
                                context
                                    .read<RecipesBloc>()
                                    .add(LoadRecipes(pantry));
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16.r),
                                ),
                              ),
                              child: Text(
                                'Retry',
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textWhite,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  if (state is RecipesLoaded) {
                    if (state.recipes.isEmpty) {
                      return Center(
                        child: Padding(
                          padding: EdgeInsets.all(32.r),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 72.r,
                                height: 72.r,
                                decoration: const BoxDecoration(
                                  color: AppColors.borderLight,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.restaurant_menu,
                                    size: 36.r, color: AppColors.textMuted),
                              ),
                              SizedBox(height: 24.h),
                              Text(
                                'No recipes found',
                                style: TextStyle(
                                  fontSize: 18.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'Try changing your filters or add more ingredients.',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: AppColors.textSecondary,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 24.h),
                              SizedBox(
                                height: 50.h,
                                width: double.infinity,
                                child: FilledButton(
                                  onPressed: () => context
                                      .read<RecipesBloc>()
                                      .add(const ClearRecipeFilters()),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16.r),
                                    ),
                                  ),
                                  child: Text(
                                    'Clear filters',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 100.h),
                      itemCount: state.recipes.length,
                      itemBuilder: (context, index) {
                        return _RecipeCard(recipe: state.recipes[index]);
                      },
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const _RecipeCard({required this.recipe});

  @override
  Widget build(BuildContext context) {
    final title = recipe['title']?.toString() ?? '';
    final cookTime =
        recipe['cookTimeMinutes'] ?? recipe['readyInMinutes'] ?? 0;
    final imageUrl = recipe['image']?.toString();

    final calories = recipe['calories'] ?? recipe['nutrition']?['calories'] ?? 0;
    final protein = recipe['protein'] ?? recipe['nutrition']?['protein'] ?? '0g';
    final carbs = recipe['carbs'] ?? recipe['nutrition']?['carbs'] ?? '0g';
    final fat = recipe['fat'] ?? recipe['nutrition']?['fat'] ?? '0g';

    final usedIngredients = <Map<String, dynamic>>[];
    final missedIngredients = <Map<String, dynamic>>[];

    if (recipe['usedIngredients'] is List) {
      for (final item in recipe['usedIngredients'] as List) {
        if (item is Map<String, dynamic>) usedIngredients.add(item);
      }
    }
    if (recipe['missedIngredients'] is List) {
      for (final item in recipe['missedIngredients'] as List) {
        if (item is Map<String, dynamic>) missedIngredients.add(item);
      }
    }

    return GestureDetector(
      onTap: () => context.push(AppRoutes.recipeDetails, extra: recipe),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Zdjęcie po lewej ──
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 110.r,
                      height: 110.r,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(width: 110.r, height: 110.r, color: AppColors.borderLight),
                      errorWidget: (_, __, ___) => Container(width: 110.r, height: 110.r, color: AppColors.borderLight, child: Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted, size: 24.r)),
                    )
                  : Container(width: 110.r, height: 110.r, color: AppColors.borderLight),
            ),
            // ── Info po prawej ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 12.r),
                        SizedBox(width: 3.w),
                        Text('$cookTime min', style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
                        SizedBox(width: 8.w),
                        Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 12.r),
                        SizedBox(width: 3.w),
                        Text('${usedIngredients.length} have', style: TextStyle(fontSize: 11.sp, color: AppColors.primary)),
                        if (missedIngredients.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Icon(Icons.cancel_outlined, color: AppColors.error, size: 12.r),
                          SizedBox(width: 3.w),
                          Text('${missedIngredients.length} miss', style: TextStyle(fontSize: 11.sp, color: AppColors.error)),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children: [
                        _NutriBadge(label: '$calories kcal', color: AppColors.primary),
                        _NutriBadge(label: 'P: $protein', color: AppColors.proteinColor),
                        _NutriBadge(label: 'C: $carbs', color: AppColors.carbsColor),
                        _NutriBadge(label: 'F: $fat', color: AppColors.fatColor),
                      ],
                    ),
                    if (missedIngredients.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: missedIngredients.take(2).map((ing) {
                          final name = ing['name']?.toString() ?? '';
                          return GestureDetector(
                            onTap: () {
                              context.read<ShoppingBloc>().add(AddShoppingItem(name, (ing['amount'] as num?)?.toDouble() ?? 1.0, ing['unit']?.toString() ?? 'piece'));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"$name" added to list ✓', style: TextStyle(color: AppColors.textWhite, fontSize: 13.sp)), backgroundColor: AppColors.primary, duration: const Duration(seconds: 2)));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), border: Border.all(color: AppColors.error.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(4.r)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.cancel_outlined, color: AppColors.error, size: 10.r),
                                SizedBox(width: 3.w),
                                Text(name, style: TextStyle(fontSize: 10.sp, color: AppColors.error)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet();

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
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

        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.backgroundWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
            child: SingleChildScrollView(
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
                    Expanded(child: Text('Filters', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary))),
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
                        decoration: BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle),
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
                      onTap: () => context.read<RecipesBloc>().add(SetRecipeCategory(cat)),
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
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _quickFilters.map((f) {
                    final active = activeFilters.contains(f.$1);
                    return GestureDetector(
                      onTap: () => context.read<RecipesBloc>().add(ToggleRecipeFilter(f.$1)),
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
                ),
                SizedBox(height: 24.h),

                // ── Cook Time ──
                Row(children: [
                  Icon(Icons.timer_outlined, color: AppColors.primary, size: 16.r),
                  SizedBox(width: 6.w),
                  Text('Cook Time', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                ]),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_cookTimeRange.start.round()} min', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                    Text('${_cookTimeRange.end.round() == 120 ? '120+' : _cookTimeRange.end.round().toString()} min', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
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
                    values: _cookTimeRange,
                    min: 0,
                    max: 120,
                    divisions: 12,
                    onChanged: (v) => setState(() => _cookTimeRange = v),
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Calories ──
                Row(children: [
                  Icon(Icons.local_fire_department_outlined, color: AppColors.primary, size: 16.r),
                  SizedBox(width: 6.w),
                  Text('Calories', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                ]),
                SizedBox(height: 4.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('${_caloriesRange.start.round()} kcal', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                    Text('${_caloriesRange.end.round() == 1200 ? '1200+' : _caloriesRange.end.round().toString()} kcal', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
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
                    values: _caloriesRange,
                    min: 0,
                    max: 1200,
                    divisions: 12,
                    onChanged: (v) => setState(() => _caloriesRange = v),
                  ),
                ),
                SizedBox(height: 20.h),

                // ── Cuisine ──
                Row(children: [
                  Icon(Icons.public_outlined, color: AppColors.primary, size: 16.r),
                  SizedBox(width: 6.w),
                  Text('Cuisine', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textMuted, letterSpacing: 0.8)),
                ]),
                SizedBox(height: 12.h),
                Wrap(
                  spacing: 8.w,
                  runSpacing: 8.h,
                  children: _cuisines.map((c) {
                    final active = activeFilters.contains(c.$1);
                    return GestureDetector(
                      onTap: () => context.read<RecipesBloc>().add(ToggleRecipeFilter(c.$1)),
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
                      onTap: () => context.read<RecipesBloc>().add(ToggleRecipeFilter(s.$2)),
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
        ),
        );
      },
    );
  }
}

class _NutriBadge extends StatelessWidget {
  const _NutriBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
