import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/recipes/bloc/recipes_bloc.dart';
import 'package:vitasense/features/recipes/bloc/recipes_event.dart';
import 'package:vitasense/features/recipes/bloc/recipes_state.dart';
import 'package:vitasense/features/recipes/data/recipes_repository.dart';
import 'package:shimmer/shimmer.dart';
import '../widgets/ai_meals/recipe_card.dart';
import 'package:vitasense/l10n/app_localizations.dart';

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

class _SavedRecipesView extends StatefulWidget {
  const _SavedRecipesView();

  @override
  State<_SavedRecipesView> createState() => _SavedRecipesViewState();
}

class _SavedRecipesViewState extends State<_SavedRecipesView> {
  List<Map<String, dynamic>> _recipes = [];
  late StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    final bloc = context.read<RecipesBloc>();
    if (bloc.state is FavoritesLoaded) {
      _recipes = List<Map<String, dynamic>>.from((bloc.state as FavoritesLoaded).recipes);
    }
    _subscription = bloc.stream.listen((state) {
      if (state is FavoritesLoaded && mounted) {
        setState(() {
          _recipes = List<Map<String, dynamic>>.from(state.recipes);
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, color: AppColors.textMuted, size: 64.r),
          SizedBox(height: 16.h),
          Text(
            AppLocalizations.of(context)!.noSavedRecipes,
            style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Text(
            AppLocalizations.of(context)!.addFavoriteRecipes,
            style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, height: 1.5),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 24.h),
          FilledButton(
            onPressed: () => context.pop(),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
            child: Text(AppLocalizations.of(context)!.browseAiMeals, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textWhite)),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: AppLocalizations.of(context)!.savedRecipes,
              subtitle: AppLocalizations.of(context)!.yourCollection,
              variant: AppHeaderVariant.nested,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: BlocConsumer<RecipesBloc, RecipesState>(
                listener: (context, state) {
                  // FavoritesLoaded jest teraz obsługiwane w initState
                  if (state is FavoriteToggled && !state.isFavorite) {
                    // Usuń lokalnie bez przeładowania
                    setState(() {
                      _recipes.removeWhere((r) => r['id']?.toString() == state.recipeId);
                    });
                  }
                },
                buildWhen: (previous, current) =>
                    current is RecipesLoading ||
                    current is FavoritesLoaded ||
                    current is RecipesError,
                builder: (context, state) {
                  if (state is RecipesLoading && _recipes.isEmpty) {
                    return _buildShimmer();
                  }
                  if (state is RecipesError && _recipes.isEmpty) {
                    return Center(child: Text(state.message, style: TextStyle(color: AppColors.error, fontSize: 14.sp)));
                  }
                  
                  if (_recipes.isEmpty) {
                    return _buildEmptyState(context);
                  }
                  
                  return GridView.builder(
                    padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 100.h),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16.w,
                      mainAxisSpacing: 16.h,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _recipes.length,
                    itemBuilder: (context, index) {
                      final recipe = _recipes[index];
                      return RecipeCard(recipe: recipe, isFavorite: true);
                    },
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
