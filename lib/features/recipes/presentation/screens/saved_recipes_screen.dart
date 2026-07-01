import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/ai_meals/recipe_card.dart';

class SavedRecipesScreen extends StatelessWidget {
  const SavedRecipesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecipesBloc(repository: RecipesRepository())..add(const LoadFavorites()),
      child: const _SavedRecipesView(),
    );
  }
}

class _SavedRecipesView extends StatelessWidget {
  const _SavedRecipesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Saved Recipes',
              subtitle: 'Your collection',
              variant: AppHeaderVariant.nested,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: BlocConsumer<RecipesBloc, RecipesState>(
                listener: (context, state) {
                  if (state is FavoriteToggled) {
                    context.read<RecipesBloc>().add(const LoadFavorites());
                  }
                },
                buildWhen: (previous, current) => current is RecipesLoading || current is FavoritesLoaded || current is RecipesError,
                builder: (context, state) {
                  if (state is RecipesLoading) {
                    return GridView.builder(
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: 6,
                      itemBuilder: (context, index) {
                        return Shimmer.fromColors(
                          baseColor: AppColors.borderLight,
                          highlightColor: AppColors.border,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.backgroundWhite,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        );
                      },
                    );
                  }
                  
                  if (state is FavoritesLoaded) {
                    if (state.recipes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.favorite_border, color: AppColors.textMuted, size: 64.r),
                            SizedBox(height: 16.h),
                            Text(
                              'Nie masz jeszcze zapisanych przepisów.',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8.h),
                            Text(
                              'Dodaj ulubione przepisy klikając ❤️ w AI Meals.',
                              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, height: 1.5),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 24.h),
                            FilledButton(
                              onPressed: () => context.go(AppRoutes.aiMeals),
                              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
                              child: Text('Przeglądaj AI Meals', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textWhite)),
                            ),
                          ],
                        ),
                      );
                    }
                    
                    return GridView.builder(
                      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 16.w,
                        mainAxisSpacing: 16.h,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: state.recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = state.recipes[index];
                        return RecipeCard(recipe: recipe, isFavorite: true);
                      },
                    );
                  }
                  
                  if (state is RecipesError) {
                    return Center(child: Text(state.message, style: TextStyle(color: AppColors.error, fontSize: 14.sp)));
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
