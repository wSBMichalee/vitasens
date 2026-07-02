import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/meals/bloc/meal_suggestions_bloc.dart';
import 'package:vitasense/features/meals/data/meal_suggestion_model.dart';
import 'package:vitasense/features/meals/data/meal_suggestions_repository.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_routes.dart';
import 'package:vitasense/features/macros/presentation/widgets/streak_celebration_modal.dart';
import 'package:vitasense/l10n/app_localizations.dart';

class MealSuggestionCard extends StatelessWidget {
  final String mealType;
  final VoidCallback? onLogged;
  final bool pantryIsEmpty;

  const MealSuggestionCard({
    super.key,
    required this.mealType,
    this.onLogged,
    this.pantryIsEmpty = false,
  });

  @override
  Widget build(BuildContext context) {
    if (pantryIsEmpty) {
      return Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(Icons.kitchen_outlined, color: AppColors.textMuted, size: 24.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your pantry is empty',
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                  ),
                  Text(
                    'Add ingredients to get personalized meal suggestions',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return BlocProvider(
      create: (_) => MealSuggestionsBloc(
        repository: MealSuggestionsRepository(),
      )..add(LoadSuggestion(mealType)),
      child: BlocBuilder<MealSuggestionsBloc, MealSuggestionsState>(
        builder: (context, state) {
          if (state is MealSuggestionsLoading || state is MealSuggestionsInitial) {
            return _LoadingCard();
          }
          if (state is MealSuggestionsError) {
            return _ErrorCard(mealType: mealType);
          }
          if (state is MealSuggestionsLoaded) {
            return _SuggestionCard(
              suggestion: state.suggestion,
              mealType: mealType,
              onRefresh: () => context.read<MealSuggestionsBloc>().add(LoadSuggestion(mealType)),
              onLogged: onLogged,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Center(
        child: SizedBox(
          width: 20.r, height: 20.r,
          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  final String mealType;
  const _ErrorCard({required this.mealType});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(Icons.add_shopping_cart_outlined, color: AppColors.textMuted, size: 20.r),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Add ingredients to your pantry to get personalized meal suggestions',
              style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestionCard extends StatelessWidget {
  final MealSuggestionModel suggestion;
  final String mealType;
  final VoidCallback onRefresh;
  final VoidCallback? onLogged;

  const _SuggestionCard({
    required this.suggestion,
    required this.mealType,
    required this.onRefresh,
    this.onLogged,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(AppRoutes.recipeDetails, extra: {
        'id': suggestion.id,
        'title': suggestion.title,
        'imageUrl': suggestion.imageUrl,
        'calories': suggestion.calories,
        'proteinG': suggestion.proteinG,
        'carbsG': suggestion.carbsG,
        'fatG': suggestion.fatG,
        'cookTimeMinutes': suggestion.cookTimeMinutes,
        'servings': suggestion.servings,
        'cuisineType': suggestion.cuisineType,
        'mealType': suggestion.mealType,
        'ingredients': suggestion.ingredients,
        'missedIngredients': suggestion.missedIngredients,
        'usedIngredients': suggestion.usedIngredients,
      }),
      child: Container(
        margin: EdgeInsets.fromLTRB(16.w, 0, 16.w, 8.h),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          // Zdjęcie z badgem
          Stack(
            children: [
              if (suggestion.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(12.r),
                    bottomLeft: Radius.circular(12.r),
                  ),
                  child: CachedNetworkImage(
                    imageUrl: suggestion.imageUrl!,
                    width: 80.r,
                    height: 80.r,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 80.r, height: 80.r,
                      color: AppColors.primaryLight,
                      child: Icon(Icons.restaurant, color: AppColors.primary, size: 30.r),
                    ),
                  ),
                )
              else
                Container(
                  width: 80.r, height: 80.r,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.r),
                      bottomLeft: Radius.circular(12.r),
                    ),
                  ),
                  child: Icon(Icons.restaurant, color: AppColors.primary, size: 30.r),
                ),
              Positioned(
                top: 4.h,
                left: 4.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E44AD).withValues(alpha: 0.9), // Purple color for AI
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    AppLocalizations.of(context)!.suggestion.toUpperCase(),
                    style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5),
                  ),
                ),
              ),
            ],
          ),
          // Info
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(10.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    suggestion.title,
                    style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    '${suggestion.calories} kcal  •  P: ${suggestion.proteinG.round()}g  C: ${suggestion.carbsG.round()}g  F: ${suggestion.fatG.round()}g',
                    style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted),
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      // Zmień
                      GestureDetector(
                        onTap: onRefresh,
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(AppLocalizations.of(context)!.change, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      // Zjedzone
                      GestureDetector(
                        onTap: () {
                          HapticFeedback.lightImpact();
                          _showLogDialog(context);
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          child: Text(AppLocalizations.of(context)!.eaten, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: Colors.white)),
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
    );
  }

  void _showLogDialog(BuildContext context) {
    double servings = 1.0;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: Text('Ile porcji?', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(suggestion.title, style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary)),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () => setState(() => servings = (servings - 0.5).clamp(0.5, 5.0)),
                    icon: const Icon(Icons.remove_circle_outline),
                  ),
                  Text('${servings}x', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700)),
                  IconButton(
                    onPressed: () => setState(() => servings = (servings + 0.5).clamp(0.5, 5.0)),
                    icon: const Icon(Icons.add_circle_outline),
                  ),
                ],
              ),
              Text(
                '${(suggestion.calories * servings).round()} kcal',
                style: TextStyle(fontSize: 14.sp, color: AppColors.primary, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(AppLocalizations.of(context)!.cancel),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              onPressed: () async {
                Navigator.pop(ctx);
                final userId = Supabase.instance.client.auth.currentUser?.id;
                if (userId == null) return;
                await MealSuggestionsRepository().logMeal(
                  foodName: suggestion.title,
                  mealTime: mealType,
                  calories: suggestion.calories,
                  proteinG: suggestion.proteinG,
                  carbsG: suggestion.carbsG,
                  fatG: suggestion.fatG,
                  userId: userId,
                  servings: servings,
                );
                onLogged?.call();
                if (context.mounted) {
                  await maybeShowStreakCelebration(context);
                }
              },
              child: Text(AppLocalizations.of(context)!.save, style: TextStyle(color: Colors.white, fontSize: 13.sp)),
            ),
          ],
        ),
      ),
    );
  }
}
