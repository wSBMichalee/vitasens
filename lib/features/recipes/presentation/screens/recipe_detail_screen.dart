import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';
import 'package:vitasense/features/shopping/bloc/shopping_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_event.dart';

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
    if (recipeId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Cannot cook this recipe — try re-loading it.', style: TextStyle(color: AppColors.textWhite, fontSize: 13.sp)),
        backgroundColor: AppColors.error,
      ));
      return;
    }
    context.read<RecipesBloc>().add(CookRecipe(recipeId, 1));
  }

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] ?? 'Unknown Recipe';
    final calories = recipe['calories'] ?? 0;
    final imageUrl = recipe['imageUrl']?.toString() ?? recipe['image']?.toString();
    final proteinG = (recipe['proteinG'] as num?)?.toDouble() ?? 0;
    final carbsG = (recipe['carbsG'] as num?)?.toDouble() ?? 0;
    final fatG = (recipe['fatG'] as num?)?.toDouble() ?? 0;
    final description = recipe['description']?.toString() ?? '';
    final steps = <Map<String, dynamic>>[];
    if (recipe['steps'] is List) {
      for (final s in recipe['steps'] as List) {
        if (s is Map<String, dynamic>) steps.add(s);
      }
    }
    final dietTags = (recipe['dietTags'] ?? recipe['diet_tags'] ?? []) as List;
    final cookTimeMinutes = recipe['cookTimeMinutes'] ?? recipe['cook_time_minutes'] ?? 0;

    final usedIngredients = <Map<String, dynamic>>[];
    final missedIngredients = <Map<String, dynamic>>[];

    if (recipe['usedIngredients'] is List) {
      for (var item in recipe['usedIngredients'] as List) {
        if (item is Map<String, dynamic>) {
          usedIngredients.add(item);
        } else if (item is String) {
          usedIngredients.add({'name': item});
        }
      }
    }
    if (recipe['missedIngredients'] is List) {
      for (var item in recipe['missedIngredients'] as List) {
        if (item is Map<String, dynamic>) {
          missedIngredients.add(item);
        } else if (item is String) {
          missedIngredients.add({'name': item});
        }
      }
    }
    if (usedIngredients.isEmpty && missedIngredients.isEmpty &&
        recipe['ingredients'] is List) {
      for (var item in recipe['ingredients'] as List) {
        if (item is Map<String, dynamic>) {
          usedIngredients.add(item);
        } else if (item is String) {
          usedIngredients.add({'name': item});
        }
      }
    }

    final allIngredients = [
      ...usedIngredients.map((i) => (i, true)),
      ...missedIngredients.map((i) => (i, false)),
    ];

    final missingNames = missedIngredients
        .map((i) => (i['name']?.toString() ?? '').toLowerCase())
        .toList();

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
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: AppColors.borderLight,
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: AppColors.borderLight,
                                  child: Icon(
                                    Icons.image_not_supported_outlined,
                                    color: AppColors.textMuted,
                                    size: 32.r,
                                  ),
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
                          missedIngredients.isEmpty
                              ? 'You already have everything you need'
                              : '${missedIngredients.length} ingredient${missedIngredients.length == 1 ? '' : 's'} missing',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: missedIngredients.isEmpty
                                ? AppColors.primary
                                : AppColors.error,
                          ),
                        ),

                        SizedBox(height: 14.h),

                        // Info chips row
                        Wrap(
                          spacing: 8.w,
                          runSpacing: 8.h,
                          children: [
                            _InfoChip(icon: Icons.timer_outlined, label: '$cookTimeMinutes MIN'),
                            _InfoChip(icon: Icons.local_fire_department_outlined, label: '$calories KCAL'),
                            if (cookTimeMinutes <= 30)
                              _DietTag(label: 'QUICK', color: AppColors.primary),
                            if (proteinG >= 25)
                              _DietTag(label: 'HIGH PROTEIN', color: AppColors.proteinColor),
                            if (carbsG <= 20)
                              _DietTag(label: 'LOW CARB', color: AppColors.carbsColor),
                            ...dietTags.take(2).map((tag) => _DietTag(
                              label: tag.toString().toUpperCase(),
                              color: AppColors.secondary,
                            )),
                          ],
                        ),

                        SizedBox(height: 28.h),

                        // Section header
                        Text('Ingredients', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        SizedBox(height: 4.h),
                        Text(
                          missedIngredients.isEmpty ? 'You have everything you need ✓' : '${usedIngredients.length} in pantry · ${missedIngredients.length} missing',
                          style: TextStyle(fontSize: 13.sp, color: missedIngredients.isEmpty ? AppColors.primary : AppColors.textSecondary),
                        ),
                        SizedBox(height: 12.h),

                        // Ingredients list
                        allIngredients.isEmpty
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
                                itemCount: allIngredients.length,
                                itemBuilder: (context, index) {
                                  final (ingredient, inPantry) =
                                      allIngredients[index];
                                  return _IngredientRow(
                                    ingredient: ingredient,
                                    inPantry: inPantry,
                                  );
                                },
                              ),

                        // Substitutes section
                        if (missingNames.isNotEmpty)
                          _SubstitutesSection(missingNames: missingNames),

                        // ── NUTRITION ──────────────────────────────────────
                        SizedBox(height: 28.h),
                        Row(children: [
                          Icon(Icons.monitor_heart_outlined, color: AppColors.primary, size: 18.r),
                          SizedBox(width: 8.w),
                          Text('Nutrition per serving', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ]),
                        SizedBox(height: 12.h),
                        Row(children: [
                          _NutritionTile(label: 'Calories', value: '$calories', unit: 'kcal', color: AppColors.primary),
                          SizedBox(width: 8.w),
                          _NutritionTile(label: 'Protein', value: proteinG.toStringAsFixed(1), unit: 'g', color: AppColors.proteinColor),
                          SizedBox(width: 8.w),
                          _NutritionTile(label: 'Carbs', value: carbsG.toStringAsFixed(1), unit: 'g', color: AppColors.carbsColor),
                          SizedBox(width: 8.w),
                          _NutritionTile(label: 'Fat', value: fatG.toStringAsFixed(1), unit: 'g', color: AppColors.fatColor),
                        ]),

                        // ── DIFFICULTY ─────────────────────────────────────
                        SizedBox(height: 28.h),
                        Row(children: [
                          Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 18.r),
                          SizedBox(width: 8.w),
                          Text('Difficulty', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ]),
                        SizedBox(height: 12.h),
                        Builder(
                          builder: (context) {
                            final difficultyLevel = cookTimeMinutes <= 20 ? 0 : cookTimeMinutes <= 45 ? 1 : 2;
                            final difficultyLabels = ['Easy', 'Medium', 'Hard'];
                            final difficultyColors = [AppColors.primary, AppColors.warning, AppColors.error];
                            return Row(children: difficultyLabels.asMap().entries.map((e) {
                              final active = e.key == difficultyLevel;
                              return Expanded(child: Padding(
                                padding: EdgeInsets.only(right: e.key < 2 ? 8.w : 0),
                                child: Container(
                                  padding: EdgeInsets.symmetric(vertical: 10.h),
                                  decoration: BoxDecoration(
                                    color: active ? difficultyColors[e.key] : AppColors.borderLight,
                                    borderRadius: BorderRadius.circular(8.r),
                                  ),
                                  child: Center(child: Text(e.value,
                                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700,
                                      color: active ? AppColors.textWhite : AppColors.textMuted))),
                                ),
                              ));
                            }).toList());
                          }
                        ),

                        // ── DESCRIPTION ────────────────────────────────────
                        if (description.isNotEmpty) ...[
                          SizedBox(height: 28.h),
                          Row(children: [
                            Icon(Icons.info_outline, color: AppColors.primary, size: 18.r),
                            SizedBox(width: 8.w),
                            Text('About', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                          ]),
                          SizedBox(height: 8.h),
                          Text(description, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, height: 1.6)),
                        ],

                        // ── INSTRUCTIONS ───────────────────────────────────
                        SizedBox(height: 28.h),
                        Row(children: [
                          Icon(Icons.menu_book_outlined, color: AppColors.primary, size: 18.r),
                          SizedBox(width: 8.w),
                          Text('How to prepare', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        ]),
                        SizedBox(height: 16.h),
                        if (steps.isEmpty)
                          Container(
                            padding: EdgeInsets.all(16.r),
                            decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(12.r)),
                            child: Row(children: [
                              Icon(Icons.info_outline, color: AppColors.textMuted, size: 20.r),
                              SizedBox(width: 12.w),
                              Expanded(child: Text('Step-by-step instructions not available yet. Try cooking this recipe after re-syncing.',
                                style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.5))),
                            ]),
                          )
                        else
                          ...steps.asMap().entries.map((entry) {
                            final stepText = entry.value['step']?.toString() ?? '';
                            final stepNum = entry.value['number'] ?? (entry.key + 1);
                            return Padding(
                              padding: EdgeInsets.only(bottom: 16.h),
                              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                Container(
                                  width: 32.r, height: 32.r,
                                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                                  child: Center(child: Text('$stepNum',
                                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textWhite))),
                                ),
                                SizedBox(width: 12.w),
                                Expanded(child: Padding(
                                  padding: EdgeInsets.only(top: 6.h),
                                  child: Text(stepText, style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary, height: 1.6)),
                                )),
                              ]),
                            );
                          }),
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
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(6.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
  final bool inPantry;

  const _IngredientRow({required this.ingredient, required this.inPantry});

  @override
  Widget build(BuildContext context) {
    final name = ingredient['name']?.toString() ?? 'Unknown';
    final imageUrl = ingredient['image']?.toString();

    if (!inPantry) {
      return Container(
        margin: EdgeInsets.only(bottom: 10.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.cancel_outlined, color: AppColors.error, size: 18.r),
            SizedBox(width: 8.w),
            Text(
              name,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            SizedBox(
              height: 44.h,
              child: Center(
                child: GestureDetector(
                  onTap: () {
                context.read<ShoppingBloc>().add(
                      AddShoppingItem(
                        name,
                        (ingredient['amount'] as num?)?.toDouble() ?? 1.0,
                        ingredient['unit']?.toString() ?? 'piece',
                      ),
                    );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Added to shopping list ✓',
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
                padding:
                    EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: Text(
                  '+ List',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.borderLight,
                        child: const Center(
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.borderLight,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textMuted,
                          size: 32.r,
                        ),
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
          Icon(Icons.check_circle_rounded,
              color: AppColors.primary, size: 22.r),
        ],
      ),
    );
  }
}

class _SubstitutesSection extends StatelessWidget {
  final List<String> missingNames;

  const _SubstitutesSection({required this.missingNames});

  static const _substitutes = <String, List<String>>{
    'butter': ['margarine', 'coconut oil', 'applesauce'],
    'milk': ['almond milk', 'oat milk', 'soy milk'],
    'eggs': ['flax eggs', 'chia eggs', 'applesauce'],
    'flour': ['almond flour', 'oat flour', 'rice flour'],
    'sugar': ['honey', 'maple syrup', 'stevia'],
  };

  @override
  Widget build(BuildContext context) {
    final matchedSubstitutes = <String, List<String>>{};
    for (final missing in missingNames) {
      for (final entry in _substitutes.entries) {
        if (missing.contains(entry.key)) {
          matchedSubstitutes[entry.key] = entry.value;
        }
      }
    }

    if (matchedSubstitutes.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MISSING INGREDIENTS',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Common substitutes:',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10.h),
          ...matchedSubstitutes.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entry.value.map((sub) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          sub,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _NutritionTile extends StatelessWidget {
  const _NutritionTile({required this.label, required this.value, required this.unit, required this.color});
  final String label, value, unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: color)),
          Text(unit, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: color)),
          SizedBox(height: 2.h),
          Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
        ]),
      ),
    );
  }
}

class _DietTag extends StatelessWidget {
  const _DietTag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(label, style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700, color: color, letterSpacing: 0.3)),
    );
  }
}
