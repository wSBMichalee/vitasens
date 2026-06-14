import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/core/widgets/gradient_scaffold.dart';
import '../widgets/ai_meals/recipe_card.dart';
import '../widgets/ai_meals/filter_bottom_sheet.dart';

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
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── AppHeader: wariant main, spinner jako action podczas ładowania ────
            BlocBuilder<RecipesBloc, RecipesState>(
              builder: (context, state) {
                final isLoading = state is RecipesLoading;
                return AppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  scrolledUnderElevation: 0,
                  title: Text("AI Meals", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 22.sp)),
                  actions: [
                    if (isLoading)
                      SizedBox(width: 20.r, height: 20.r, child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary)),
                    GestureDetector(
                      onTap: () => context.push(AppRoutes.savedRecipes),
                      child: Container(
                        width: 40.r, height: 40.r,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.bookmark_border, color: Colors.black, size: 20.r),
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
                              child: const FilterBottomSheet(),
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
                        return RecipeCard(recipe: state.recipes[index]);
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








