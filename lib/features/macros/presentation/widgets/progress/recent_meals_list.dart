import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';

class RecentMealsList extends StatelessWidget {
  const RecentMealsList({super.key, required this.meals});
  final List<Map<String, dynamic>> meals;

  static const String _fallbackImageUrl =
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80';

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.r),
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
        child: Center(
          child: Column(
            children: [
              Icon(Icons.restaurant_outlined,
                  color: AppColors.textMuted, size: 36.r),
              SizedBox(height: 8.h),
              Text(
                'No meals logged today',
                style:
                    TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 44.h,
                child: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.aiMeals),
                  icon: Icon(Icons.auto_awesome, size: 18.r),
                  label: Text(
                    'Get AI Meals',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
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
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: meals.length,
        separatorBuilder: (_, __) =>
            const Divider(color: AppColors.border, height: 1, thickness: 1),
        itemBuilder: (_, i) {
          final meal = meals[i];
          final name =
              (meal['name'] ?? meal['title'] ?? 'Meal').toString();
          final calories = meal['calories'] is int
              ? meal['calories'] as int
              : meal['calories'] is double
                  ? (meal['calories'] as double).toInt()
                  : 0;
          final imageUrl =
              (meal['imageUrl'] ?? meal['image_url'] ?? _fallbackImageUrl)
                  .toString();
          final streak = meal['streak'] as int? ?? 1;

          return Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: SizedBox(
                    width: 60.r,
                    height: 60.r,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.border,
                        highlightColor: AppColors.borderLight,
                        child: Container(color: AppColors.border),
                      ),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.borderLight),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$calories KCAL  •  +$streak DAY STREAK',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: AppColors.textMuted, size: 20.r),
              ],
            ),
          );
        },
      ),
    );
  }
}