import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';

class RecipeGridCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeGridCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] as String? ?? 'Recipe';
    final image = recipe['image_url'] as String? ?? 'https://picsum.photos/400/300';
    final cookTime = recipe['cook_time']?.toString() ?? '15m';
    final calories = recipe['calories']?.toString() ?? '400 kcal';
    final tags = (recipe['diet_tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return GestureDetector(
      onTap: () => context.push(AppRoutes.recipeDetails.replaceFirst(':id', recipe['id'] ?? 'none'), extra: recipe),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border.all(color: AppColors.border),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
              child: CachedNetworkImage(
                imageUrl: image,
                height: 120.h,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.borderLight),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.borderLight,
                  height: 120.h,
                  child: const Icon(Icons.image_not_supported, color: AppColors.textMuted),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(12.r),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 12.r),
                        SizedBox(width: 4.w),
                        Text(
                          cookTime,
                          style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                        ),
                        const Spacer(),
                        Icon(Icons.local_fire_department, color: AppColors.primary, size: 12.r),
                        SizedBox(width: 2.w),
                        Text(
                          calories,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    if (tags.isNotEmpty)
                      Wrap(
                        spacing: 4.w,
                        runSpacing: 4.h,
                        children: tags.take(2).map((tag) {
                          return Container(
                            padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(4.r),
                            ),
                            child: Text(
                              tag,
                              style: TextStyle(
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primary,
                              ),
                            ),
                          );
                        }).toList(),
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
}