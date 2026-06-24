import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:vitasense/features/shopping/bloc/shopping_bloc.dart';
import 'package:vitasense/features/shopping/bloc/shopping_event.dart';

class IngredientRow extends StatelessWidget {
  final Map<String, dynamic> ingredient;
  final bool inPantry;

  const IngredientRow({super.key, required this.ingredient, required this.inPantry});

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
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
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

