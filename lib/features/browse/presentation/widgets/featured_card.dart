import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';

class FeaturedCard extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const FeaturedCard({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final title = recipe['title'] as String? ?? 'Recipe';
    final image = recipe['image_url'] as String? ?? 'https://picsum.photos/400/300';
    final cookTime = recipe['cook_time']?.toString() ?? '15m';
    final calories = recipe['calories']?.toString() ?? '400 kcal';

    return GestureDetector(
      onTap: () => context.push(AppRoutes.recipeDetails.replaceFirst(':id', recipe['id'] ?? 'none'), extra: recipe),
      child: Container(
        width: 280.w,
        margin: EdgeInsets.only(right: 12.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned.fill(
              child: CachedNetworkImage(
                imageUrl: image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(color: AppColors.borderLight),
                errorWidget: (context, url, error) => Container(
                  color: AppColors.borderLight,
                  child: const Icon(Icons.image_not_supported, color: AppColors.textMuted),
                ),
              ),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.transparent, Colors.black.withValues(alpha: 0.8)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: const [0.5, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 12.h,
              left: 12.w,
              right: 12.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textWhite,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.timer_outlined, color: AppColors.textWhite, size: 12.r),
                      SizedBox(width: 4.w),
                      Text(
                        cookTime,
                        style: TextStyle(fontSize: 11.sp, color: AppColors.textWhite),
                      ),
                      SizedBox(width: 8.w),
                      Icon(Icons.local_fire_department_outlined, color: AppColors.textWhite, size: 12.r),
                      SizedBox(width: 4.w),
                      Text(
                        calories,
                        style: TextStyle(fontSize: 11.sp, color: AppColors.textWhite),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}