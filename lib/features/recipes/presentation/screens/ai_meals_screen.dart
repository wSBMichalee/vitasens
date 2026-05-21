import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class AiMealsScreen extends StatelessWidget {
  final List<String>? ingredients;

  const AiMealsScreen({super.key, this.ingredients});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipesBloc(
        repository: RecipesRepository(),
      )..add(LoadRecipes(ingredients ?? ['Chicken', 'Spinach', 'Eggs'])),
      child: const _AiMealsView(),
    );
  }
}

class _AiMealsView extends StatelessWidget {
  const _AiMealsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<RecipesBloc, RecipesState>(
        listener: (context, state) {
          if (state is RecipesError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        child: SafeArea(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── HEADER ──────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Text(
                      "< Back to Pantry",
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                        color: AppColors.secondary,
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Meals you can cook",
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              "Based on your ingredients and health goals",
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 44.w,
                        height: 44.h,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Icon(Icons.tune, color: AppColors.textPrimary, size: 22.r),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── RECIPE COUNT BADGE ──────────────────────────────────────
            BlocBuilder<RecipesBloc, RecipesState>(
              builder: (context, state) {
                int count = 0;
                if (state is RecipesLoaded) {
                  count = state.recipes.length;
                }
                return Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      Icon(Icons.auto_awesome, color: AppColors.primary, size: 14.r),
                      SizedBox(width: 6.w),
                      Text(
                        "YOU CAN COOK $count MEALS WITH WHAT YOU HAVE",
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),

            // ─── FILTER CHIPS ────────────────────────────────────────────
            BlocBuilder<RecipesBloc, RecipesState>(
              builder: (context, state) {
                String selectedFilter = 'ALL';
                if (state is RecipesLoaded) {
                  selectedFilter = state.selectedFilter;
                }

                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    children: [
                      _FilterChip(
                        label: "QUICK ✓",
                        isSelected: selectedFilter == 'QUICK ✓',
                        onTap: () => context.read<RecipesBloc>().add(const FilterRecipes("QUICK ✓")),
                      ),
                      SizedBox(width: 12.w),
                      _FilterChip(
                        label: "HIGH PROTEIN 🏃",
                        isSelected: selectedFilter == 'HIGH PROTEIN 🏃',
                        onTap: () => context.read<RecipesBloc>().add(const FilterRecipes("HIGH PROTEIN 🏃")),
                      ),
                      SizedBox(width: 12.w),
                      _FilterChip(
                        label: "LOW SUGAR 🅰",
                        isSelected: selectedFilter == 'LOW SUGAR 🅰',
                        onTap: () => context.read<RecipesBloc>().add(const FilterRecipes("LOW SUGAR 🅰")),
                      ),
                    ],
                  ),
                );
              },
            ),
            SizedBox(height: 16.h),

            // ─── RECIPE CARDS ────────────────────────────────────────────
            Expanded(
              child: BlocBuilder<RecipesBloc, RecipesState>(
                builder: (context, state) {
                  if (state is RecipesInitial || state is RecipesLoading) {
                    return _buildShimmerCards();
                  }

                  if (state is RecipesError) {
                    return Center(child: Text(state.message, style: const TextStyle(color: Colors.red)));
                  }

                  if (state is RecipesLoaded) {
                    if (state.recipes.isEmpty) {
                      return const Center(
                        child: Text(
                          "No meals found with current filters.",
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: state.recipes.length,
                      itemBuilder: (context, index) {
                        return _RecipeCard(recipe: state.recipes[index]);
                      },
                    );
                  }

                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
      ),
    ),
    );
  }

  Widget _buildShimmerCards() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.border,
      child: const _ShimmerRecipeCard(),
    );
  }
}

class _ShimmerRecipeCard extends StatelessWidget {
  const _ShimmerRecipeCard();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 3,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
          height: 380.h,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
        );
      },
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimary : Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: isSelected ? null : Border.all(color: AppColors.border),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppColors.textPrimary,
          ),
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
    final title = recipe['title'] ?? 'Unknown Recipe';
    final cookTime = recipe['cookTimeMinutes'] ?? 0;
    final calories = recipe['calories'] ?? 0;
    final imageUrl = recipe['image'];
    
    List<String> ingredients = [];
    if (recipe['usedIngredients'] is List) {
      for (var item in recipe['usedIngredients']) {
        if (item is String) {
          ingredients.add(item);
        } else if (item is Map && item['name'] != null) {
          ingredients.add(item['name'].toString());
        }
      }
    }

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── IMAGE HEADER ──────────────────────────────────────────────
          SizedBox(
            height: 240.h,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                  child: imageUrl != null && imageUrl.toString().isNotEmpty
                      ? Image.network(
                          imageUrl,
                          width: double.infinity,
                          height: 240.h,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => Container(color: Colors.grey),
                        )
                      : Container(color: Colors.grey),
                ),
                
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withValues(alpha: 0.8),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),

                Positioned(
                  top: 16,
                  left: 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      "BEST MATCH",
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),

                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Padding(
                    padding: EdgeInsets.all(20.0.r),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6.h),
                        Text(
                          "Best for your goals & ingredients",
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: Colors.white.withValues(alpha: 0.8),
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Icon(Icons.timer_outlined, color: Colors.white, size: 16.r),
                            SizedBox(width: 6.w),
                            Text(
                              "$cookTime MIN",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
                              ),
                            ),
                            SizedBox(width: 20.w),
                            Icon(Icons.local_fire_department_outlined, color: Colors.white, size: 16.r),
                            SizedBox(width: 6.w),
                            Text(
                              "$calories KCAL",
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                                letterSpacing: 0.5,
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
          ),

          // ─── INGREDIENTS YOU HAVE ────────────────────────────────────
          Padding(
            padding: EdgeInsets.all(20.0.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "USES WHAT YOU HAVE:",
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    letterSpacing: 1.0,
                  ),
                ),
                SizedBox(height: 16.h),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: ingredients.map((name) => _IngredientChip(name: name)).toList(),
                ),
              ],
            ),
          ),

          // ─── COOK BUTTON ─────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    onPressed: () => context.go('/recipe-details/${recipe['id']}', extra: recipe),
                    child: Text(
                      "COOK THIS",
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 1.0,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Ready in $cookTime min with what you already have",
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 6.h),
                Text(
                  "INGREDIENTS WILL BE UPDATED AFTER COOKING",
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientChip extends StatelessWidget {
  final String name;

  const _IngredientChip({required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.check_circle_outline, color: AppColors.primary, size: 16.r),
          SizedBox(width: 8.w),
          Text(
            name,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
