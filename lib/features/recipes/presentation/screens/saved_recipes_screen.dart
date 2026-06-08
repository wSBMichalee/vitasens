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
import 'package:cached_network_image/cached_network_image.dart';

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
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            AppHeader(
              title: 'Saved Recipes',
              subtitle: 'Your collection',
              variant: AppHeaderVariant.nested,
              backgroundColor: AppColors.primary,
              textColor: AppColors.textWhite,
              onBack: () => context.pop(),
            ),
            Expanded(
              child: BlocBuilder<RecipesBloc, RecipesState>(
                builder: (context, state) {
                  if (state is RecipesLoading) {
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                      itemCount: 4,
                      itemBuilder: (_, __) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Shimmer.fromColors(
                          baseColor: AppColors.borderLight,
                          highlightColor: AppColors.border,
                          child: Container(
                            height: 90.h,
                            decoration: BoxDecoration(
                              color: AppColors.backgroundWhite,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (state is FavoritesLoaded) {
                    if (state.recipes.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.bookmark_border, color: AppColors.textMuted, size: 64.r),
                            SizedBox(height: 16.h),
                            Text('No saved recipes yet', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            SizedBox(height: 8.h),
                            Text('Tap the bookmark icon on any recipe\nto save it here.', style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary, height: 1.5), textAlign: TextAlign.center),
                            SizedBox(height: 24.h),
                            FilledButton(
                              onPressed: () => context.go(AppRoutes.aiMeals),
                              style: FilledButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r))),
                              child: Text('Browse Recipes', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textWhite)),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
                      itemCount: state.recipes.length,
                      itemBuilder: (context, index) {
                        final recipe = state.recipes[index];
                        final imageUrl = recipe['imageUrl']?.toString() ?? recipe['image_url']?.toString();
                        final title = recipe['title']?.toString() ?? '';
                        final cookTime = recipe['cookTimeMinutes'] ?? 0;
                        final calories = recipe['calories'] ?? 0;
                        return GestureDetector(
                          onTap: () => context.push(AppRoutes.recipeDetails, extra: recipe),
                          child: Container(
                            margin: EdgeInsets.only(bottom: 12.h),
                            decoration: BoxDecoration(
                              color: AppColors.backgroundWhite,
                              borderRadius: BorderRadius.circular(16.r),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
                                  child: imageUrl != null
                                      ? CachedNetworkImage(imageUrl: imageUrl, width: 90.r, height: 90.r, fit: BoxFit.cover,
                                          placeholder: (_, __) => Container(width: 90.r, height: 90.r, color: AppColors.borderLight),
                                          errorWidget: (_, __, ___) => Container(width: 90.r, height: 90.r, color: AppColors.borderLight, child: Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted, size: 24.r)))
                                      : Container(width: 90.r, height: 90.r, color: AppColors.borderLight),
                                ),
                                Expanded(
                                  child: Padding(
                                    padding: EdgeInsets.all(12.r),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                                        SizedBox(height: 4.h),
                                        Row(children: [
                                          Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 12.r),
                                          SizedBox(width: 3.w),
                                          Text('$cookTime min', style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
                                          SizedBox(width: 8.w),
                                          Icon(Icons.local_fire_department_outlined, color: AppColors.primary, size: 12.r),
                                          SizedBox(width: 3.w),
                                          Text('$calories kcal', style: TextStyle(fontSize: 11.sp, color: AppColors.primary)),
                                        ]),
                                      ],
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: EdgeInsets.only(right: 12.w),
                                  child: Icon(Icons.bookmark_rounded, color: AppColors.primary, size: 20.r),
                                ),
                              ],
                            ),
                          ),
                        );
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
