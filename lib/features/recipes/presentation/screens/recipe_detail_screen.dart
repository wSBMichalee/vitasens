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
import 'package:vitasense/features/shopping/data/shopping_repository.dart';
import 'package:vitasense/features/shopping/bloc/shopping_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_event.dart';
import 'package:vitasense/features/macros/presentation/widgets/streak_celebration_modal.dart';
import 'package:vitasense/features/pantry/bloc/pantry_bloc.dart';
import 'package:vitasense/features/pantry/bloc/pantry_event.dart';

import '../widgets/recipe_detail/recipe_info_chip.dart';
import '../widgets/recipe_detail/recipe_ingredient_row.dart';
import '../widgets/recipe_detail/recipe_substitutes_section.dart';
import '../widgets/recipe_detail/recipe_nutrition_tile.dart';
import '../widgets/recipe_detail/recipe_diet_tag.dart';
import '../widgets/recipe_detail/recipe_steps_section.dart';
import '../widgets/recipe_detail/recipe_nutrition_section.dart';
import '../widgets/recipe_detail/recipe_difficulty_section.dart';
import '../widgets/recipe_detail/recipe_cook_button.dart';


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

class _RecipeDetailView extends StatefulWidget {
  final Map<String, dynamic> recipe;

  const _RecipeDetailView({required this.recipe});

  @override
  State<_RecipeDetailView> createState() => _RecipeDetailViewState();
}

class _RecipeDetailViewState extends State<_RecipeDetailView> {
  bool _isFavorite = false;
  bool _checkingFavorite = true;
  bool _ingredientsAddedToList = false;

  @override
  void initState() {
    super.initState();
    final recipeId = widget.recipe['id']?.toString() ?? '';
    if (recipeId.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.read<RecipesBloc>().add(CheckFavorite(recipeId));
      });
    }
  }

  void _cookRecipe(BuildContext context) {
    final recipeId = widget.recipe['id']?.toString() ?? '';
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
    final recipe = widget.recipe;
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
      listener: (context, state) async {
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
          if (context.mounted) {
            context.read<PantryBloc>().add(const LoadPantry());
            await maybeShowStreakCelebration(context);
          }
          if (context.mounted) context.go(AppRoutes.home);
        } else if (state is RecipesError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        } else if (state is FavoriteChecked) {
          if (state.recipeId == (widget.recipe['id']?.toString() ?? '')) {
            setState(() {
              _isFavorite = state.isFavorite;
              _checkingFavorite = false;
            });
          }
        } else if (state is FavoriteToggled) {
          if (state.recipeId == (widget.recipe['id']?.toString() ?? '')) {
            setState(() => _isFavorite = state.isFavorite);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                state.isFavorite ? 'Recipe saved! ✓' : 'Removed from saved',
                style: TextStyle(color: AppColors.textWhite, fontSize: 13.sp),
              ),
              backgroundColor: state.isFavorite ? AppColors.primary : AppColors.textSecondary,
              duration: const Duration(seconds: 2),
            ));
          }
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
                      child: GestureDetector(
                        onTap: () {
                          final recipeId = widget.recipe['id']?.toString() ?? '';
                          if (recipeId.isEmpty) return;
                          context.read<RecipesBloc>().add(
                            ToggleFavorite(recipeId, currentlyFavorited: _isFavorite),
                          );
                        },
                        child: Container(
                          width: 36.w, height: 36.h,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite.withValues(alpha: 0.9),
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.1), blurRadius: 8.r)],
                          ),
                          child: _checkingFavorite
                              ? SizedBox(width: 16.r, height: 16.r, child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary))
                              : Icon(
                                  _isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border,
                                  color: _isFavorite ? AppColors.primary : AppColors.textPrimary,
                                  size: 20.r,
                                ),
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
                            InfoChip(icon: Icons.timer_outlined, label: '$cookTimeMinutes MIN'),
                            InfoChip(icon: Icons.local_fire_department_outlined, label: '$calories KCAL'),
                            if (cookTimeMinutes <= 30)
                              const DietTag(label: 'QUICK', color: AppColors.primary),
                            if (proteinG >= 25)
                              const DietTag(label: 'HIGH PROTEIN', color: AppColors.proteinColor),
                            if (carbsG <= 20)
                              const DietTag(label: 'LOW CARB', color: AppColors.carbsColor),
                            ...dietTags.take(2).map((tag) => DietTag(
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
                                  return IngredientRow(
                                    ingredient: ingredient,
                                    inPantry: inPantry,
                                  );
                                },
                              ),


                        // ── DODAJ BRAKUJĄCE → LISTA ZAKUPÓW ────────────────────────
                        if (missedIngredients.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 0),
                            child: SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                ),
                                icon: Icon(Icons.add_shopping_cart, color: Colors.white, size: 18.r),
                                label: Text(
                                  _ingredientsAddedToList
                                    ? 'Dodano do listy zakupów ✓'
                                    : 'Dodaj ${missedIngredients.length} brakujących składników',
                                  style: TextStyle(color: Colors.white, fontSize: 14.sp, fontWeight: FontWeight.w600),
                                ),
                                onPressed: _ingredientsAddedToList ? null : () async {
                                  final repo = ShoppingRepository();
                                  final items = missedIngredients.map((ing) => {
                                    'name': ing['name']?.toString() ?? '',
                                    'quantity': double.tryParse(ing['amount']?.toString() ?? '') ?? 1.0,
                                    'unit': ing['unit']?.toString() ?? 'szt',
                                  }).where((item) => (item['name'] as String).isNotEmpty).toList();
                                  try {
                                    await repo.addItemsBatch(items);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text('Dodano ${items.length} składników do listy zakupów ✓'),
                                          backgroundColor: AppColors.primary,
                                          duration: const Duration(seconds: 2),
                                        ),
                                      );
                                      setState(() => _ingredientsAddedToList = true);
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Błąd: $e'), backgroundColor: AppColors.error),
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          ),

                        // Substitutes section
                        if (missingNames.isNotEmpty)
                          SubstitutesSection(missingNames: missingNames),

                        // ── NUTRITION ──────────────────────────────────────
                        SizedBox(height: 28.h),
                        RecipeNutritionSection(
                          calories: calories,
                          proteinG: proteinG,
                          carbsG: carbsG,
                          fatG: fatG,
                        ),

                        // ── DIFFICULTY ─────────────────────────────────────
                        SizedBox(height: 28.h),
                        RecipeDifficultySection(cookTimeMinutes: cookTimeMinutes),

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
                        RecipeStepsSection(steps: steps),
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
              child: BlocBuilder<RecipesBloc, RecipesState>(
                builder: (context, state) {
                  return RecipeCookButton(
                    onCook: () => _cookRecipe(context),
                    isCooking: state is RecipesCooking,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}










