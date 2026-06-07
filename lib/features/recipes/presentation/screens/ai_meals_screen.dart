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
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppHeader: wariant main, spinner jako action podczas ładowania ────
            BlocBuilder<RecipesBloc, RecipesState>(
              builder: (context, state) {
                final isLoading = state is RecipesLoading;
                return AppHeader(
                  title: 'AI Posiłki',
                  subtitle: 'Na podstawie twojej spiżarni',
                  variant: AppHeaderVariant.main,
                  actions: [
                    if (isLoading)
                      SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                  ],
                );
              },
            ),

            SizedBox(
              height: 48.h,
              child: BlocBuilder<RecipesBloc, RecipesState>(
                builder: (context, state) {
                  final selectedFilter =
                      state is RecipesLoaded ? state.selectedFilter : 'ALL';
                  return ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 20.w),
                    children: ['ALL', 'QUICK ✓', 'HIGH PROTEIN 🏃', 'LOW SUGAR 🅰']
                        .map((f) {
                      final selected = selectedFilter == f;
                      return Padding(
                        padding: EdgeInsets.only(right: 8.w),
                        child: GestureDetector(
                          onTap: () =>
                              context.read<RecipesBloc>().add(FilterRecipes(f)),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: EdgeInsets.symmetric(
                                horizontal: 16.w, vertical: 12.h),
                            decoration: BoxDecoration(
                              color: selected
                                  ? AppColors.primary
                                  : AppColors.backgroundWhite,
                              border: Border.all(
                                color: selected
                                    ? AppColors.primary
                                    : AppColors.border,
                              ),
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              f,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: selected
                                    ? AppColors.textWhite
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            SizedBox(height: 12.h),

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
                                      .add(const FilterRecipes('ALL')),
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
                      padding:
                          EdgeInsets.fromLTRB(20.w, 0, 20.w, 24.h),
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
        margin: EdgeInsets.only(bottom: 16.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty)
              ClipRRect(
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(16.r)),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  height: 160.h,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    height: 160.h,
                    color: AppColors.borderLight,
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 160.h,
                    color: AppColors.borderLight,
                    child: Icon(Icons.image_not_supported_outlined,
                        color: AppColors.textMuted, size: 32.r),
                  ),
                ),
              ),

            Padding(
              padding: EdgeInsets.all(14.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined,
                          color: AppColors.textSecondary, size: 14.r),
                      SizedBox(width: 4.w),
                      Text(
                        '$cookTime min',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 14.r),
                      SizedBox(width: 4.w),
                      Text(
                        '${usedIngredients.length} have',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.primary,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.cancel_outlined,
                          color: AppColors.error, size: 14.r),
                      SizedBox(width: 4.w),
                      Text(
                        '${missedIngredients.length} missing',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.error,
                        ),
                      ),
                    ],
                  ),

                  if (missedIngredients.isNotEmpty) ...[
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: missedIngredients.map((ing) {
                        final name = ing['name']?.toString() ?? '';
                        return GestureDetector(
                          onTap: () {
                            context.read<ShoppingBloc>().add(
                                  AddShoppingItem(
                                    name,
                                    (ing['amount'] as num?)?.toDouble() ?? 1.0,
                                    ing['unit']?.toString() ?? 'piece',
                                  ),
                                );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Added "$name" to shopping list ✓',
                                  style: TextStyle(
                                    color: AppColors.textWhite,
                                    fontSize: 13.sp,
                                  ),
                                ),
                                backgroundColor: AppColors.primary,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 8.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.08),
                              border: Border.all(
                                  color:
                                      AppColors.error.withValues(alpha: 0.3)),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.cancel_outlined,
                                    color: AppColors.error, size: 12.r),
                                SizedBox(width: 4.w),
                                Text(
                                  name,
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: AppColors.error,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  '+ List',
                                  style: TextStyle(
                                    fontSize: 10.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
