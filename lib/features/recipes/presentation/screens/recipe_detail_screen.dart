import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';

class RecipeDetailScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RecipesBloc(
        repository: RecipesRepository(),
      ),
      child: _RecipeDetailView(recipe: recipe),
    );
  }
}

class _RecipeDetailView extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const _RecipeDetailView({required this.recipe});

  void _cookRecipe(BuildContext context) {
    final recipeId = recipe['id']?.toString() ?? '';
    context.read<RecipesBloc>().add(CookRecipe(recipeId, 1));
  }

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] ?? 'Unknown Recipe';
    final cookTime = recipe['cookTimeMinutes'] ?? 0;
    final calories = recipe['calories'] ?? 0;
    final imageUrl = recipe['image']?.toString();

    List<Map<String, dynamic>> ingredients = [];
    if (recipe['ingredients'] is List) {
      for (var item in recipe['ingredients']) {
        if (item is Map<String, dynamic>) {
          ingredients.add(item);
        } else if (item is String) {
          ingredients.add({'name': item});
        }
      }
    } else if (recipe['usedIngredients'] is List) {
      for (var item in recipe['usedIngredients']) {
        if (item is Map<String, dynamic>) {
          ingredients.add(item);
        } else if (item is String) {
          ingredients.add({'name': item});
        }
      }
    }

    return BlocListener<RecipesBloc, RecipesState>(
      listener: (context, state) {
        if (state is RecipesCookingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Smacznego! 🍽️ Spiżarnia zaktualizowana.',
                style: TextStyle(color: AppColors.textWhite, fontSize: 14.sp),
              ),
              backgroundColor: AppColors.primary,
            ),
          );
          context.go(AppRoutes.home);
        } else if (state is RecipesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.backgroundWhite,
        body: Stack(
          children: [
            CustomScrollView(
              slivers: [
                // ─── SLIVER APP BAR (Hero image) ────────────────────────
                SliverAppBar(
                  expandedHeight: 280.h,
                  floating: false,
                  pinned: true,
                  backgroundColor: AppColors.backgroundWhite,
                  elevation: 0,
                  leading: Padding(
                    padding: EdgeInsets.only(left: 16.w),
                    child: GestureDetector(
                      onTap: () => context.pop(),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withValues(alpha: 0.1),
                              blurRadius: 8.r,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary,
                          size: 18.r,
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: Container(
                        width: 36.w,
                        height: 36.h,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withValues(alpha: 0.1),
                              blurRadius: 8.r,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.bookmark_border,
                          color: AppColors.textPrimary,
                          size: 20.r,
                        ),
                      ),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      fit: StackFit.expand,
                      children: [
                        imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => Container(
                                  color: AppColors.borderLight,
                                ),
                              )
                            : Container(color: AppColors.borderLight),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 100.h,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  AppColors.backgroundWhite,
                                  AppColors.backgroundWhite.withValues(alpha: 0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── CONTENT ────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 120.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          title,
                          style: AppTextStyles.displayMedium,
                        ),

                        SizedBox(height: 6.h),

                        // Subtitle
                        Text(
                          'You already have everything you need',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),

                        SizedBox(height: 14.h),

                        // Info chips row
                        Row(
                          children: [
                            _InfoChip(
                              icon: Icons.timer_outlined,
                              label: '$cookTime MIN',
                            ),
                            SizedBox(width: 8.w),
                            _InfoChip(
                              icon: Icons.local_fire_department_outlined,
                              label: '$calories KCAL',
                            ),
                            SizedBox(width: 8.w),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 10.w,
                                vertical: 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryLight,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'HIGH PROTEIN',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.primary,
                                  letterSpacing: 0.3,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 28.h),

                        // Section header
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'USES FROM YOUR',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                                Text(
                                  'PANTRY',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Text(
                              'INGREDIENTS WILL BE\nUPDATED AUTOMATICALLY',
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: AppColors.secondary,
                                letterSpacing: 0.3,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ],
                        ),

                        SizedBox(height: 14.h),

                        // Ingredients list
                        ingredients.isEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(vertical: 16.h),
                                child: Text(
                                  'No ingredients listed.',
                                  style: AppTextStyles.bodyMedium,
                                ),
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: ingredients.length,
                                itemBuilder: (context, index) {
                                  return _IngredientRow(ingredient: ingredients[index]);
                                },
                              ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // ─── STICKY BOTTOM BUTTON ────────────────────────────────
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
                decoration: BoxDecoration(
                  color: AppColors.backgroundWhite,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.textPrimary.withValues(alpha: 0.06),
                      blurRadius: 20.r,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: BlocBuilder<RecipesBloc, RecipesState>(
                  builder: (context, state) {
                    final isCooking = state is RecipesCooking;

                    return Column(
                      mainAxisSize: MainAxisSize.min,
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
                            onPressed: isCooking ? null : () => _cookRecipe(context),
                            child: isCooking
                                ? SizedBox(
                                    width: 24.w,
                                    height: 24.h,
                                    child: CircularProgressIndicator(
                                      color: AppColors.textWhite,
                                      strokeWidth: 2.w,
                                    ),
                                  )
                                : Text(
                                    'Start cooking now',
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.textWhite,
                                    ),
                                  ),
                          ),
                        ),

                        SizedBox(height: 10.h),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.people, color: AppColors.textMuted, size: 14.r),
                            SizedBox(width: 4.w),
                            Text(
                              'USED BY 12,000+ USERS THIS WEEK',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: AppColors.textMuted,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 4.h),

                        Text(
                          'UPDATES YOUR PANTRY AUTOMATICALLY',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: AppColors.textMuted,
                            letterSpacing: 0.3,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.textSecondary, size: 14.r),
          SizedBox(width: 4.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  final Map<String, dynamic> ingredient;

  const _IngredientRow({required this.ingredient});

  @override
  Widget build(BuildContext context) {
    final name = ingredient['name']?.toString() ?? 'Unknown';
    final imageUrl = ingredient['image']?.toString();

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.restaurant,
                        color: AppColors.textMuted,
                        size: 24.r,
                      ),
                    ),
                  )
                : Icon(
                    Icons.restaurant,
                    color: AppColors.textMuted,
                    size: 24.r,
                  ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              name,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 22.r),
        ],
      ),
    );
  }
}
