import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_event.dart';
import 'nutri_badge.dart';

class RecipeCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final title = recipe['title']?.toString() ?? '';
    final cookTime =
        recipe['cookTimeMinutes'] ?? recipe['readyInMinutes'] ?? 0;
    final imageUrl = recipe['image']?.toString();

    final calories = recipe['calories'] ?? recipe['nutrition']?['calories'] ?? 0;
    final protein = recipe['protein'] ?? recipe['nutrition']?['protein'] ?? '0g';
    final carbs = recipe['carbs'] ?? recipe['nutrition']?['carbs'] ?? '0g';
    final fat = recipe['fat'] ?? recipe['nutrition']?['fat'] ?? '0g';

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
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Zdjęcie po lewej ──
            ClipRRect(
              borderRadius: BorderRadius.horizontal(left: Radius.circular(16.r)),
              child: imageUrl != null && imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 110.r,
                      height: 110.r,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(width: 110.r, height: 110.r, color: AppColors.borderLight),
                      errorWidget: (_, __, ___) => Container(width: 110.r, height: 110.r, color: AppColors.borderLight, child: Icon(Icons.image_not_supported_outlined, color: AppColors.textMuted, size: 24.r)),
                    )
                  : Container(width: 110.r, height: 110.r, color: AppColors.borderLight),
            ),
            // ── Info po prawej ──
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary), maxLines: 2, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 12.r),
                        SizedBox(width: 3.w),
                        Text('$cookTime min', style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted)),
                        SizedBox(width: 8.w),
                        Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 12.r),
                        SizedBox(width: 3.w),
                        Text('${usedIngredients.length} have', style: TextStyle(fontSize: 11.sp, color: AppColors.primary)),
                        if (missedIngredients.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Icon(Icons.cancel_outlined, color: AppColors.error, size: 12.r),
                          SizedBox(width: 3.w),
                          Text('${missedIngredients.length} miss', style: TextStyle(fontSize: 11.sp, color: AppColors.error)),
                        ],
                      ],
                    ),
                    SizedBox(height: 6.h),
                    Wrap(
                      spacing: 4.w,
                      runSpacing: 4.h,
                      children: [
                        NutriBadge(label: '$calories kcal', color: AppColors.primary),
                        NutriBadge(label: 'P: $protein', color: AppColors.proteinColor),
                        NutriBadge(label: 'C: $carbs', color: AppColors.carbsColor),
                        NutriBadge(label: 'F: $fat', color: AppColors.fatColor),
                      ],
                    ),
                    if (missedIngredients.isNotEmpty) ...[
                      SizedBox(height: 6.h),
                      Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: missedIngredients.take(2).map((ing) {
                          final name = ing['name']?.toString() ?? '';
                          return GestureDetector(
                            onTap: () {
                              context.read<ShoppingBloc>().add(AddShoppingItem(name, (ing['amount'] as num?)?.toDouble() ?? 1.0, ing['unit']?.toString() ?? 'piece'));
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('"$name" added to list ✓', style: TextStyle(color: AppColors.textWhite, fontSize: 13.sp)), backgroundColor: AppColors.primary, duration: const Duration(seconds: 2)));
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                              decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.08), border: Border.all(color: AppColors.error.withValues(alpha: 0.3)), borderRadius: BorderRadius.circular(4.r)),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.cancel_outlined, color: AppColors.error, size: 10.r),
                                SizedBox(width: 3.w),
                                Text(name, style: TextStyle(fontSize: 10.sp, color: AppColors.error)),
                              ]),
                            ),
                          );
                        }).toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}