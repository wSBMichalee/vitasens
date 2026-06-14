import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/recipes/data/models/recipe_model.dart';

class MyRecipeCard extends StatelessWidget {
  final RecipeModel recipe;
  final VoidCallback onPublish;
  final VoidCallback onDelete;

  const MyRecipeCard({super.key, 
    required this.recipe,
    required this.onPublish,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (recipe.isPublished)
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(color: AppColors.primaryLight, borderRadius: BorderRadius.circular(6.r)),
                        child: Text('PUBLIC', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
                      )
                    else
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(6.r)),
                        child: Text('DRAFT', style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: AppColors.textSecondary)),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(Icons.timer_outlined, color: AppColors.textMuted, size: 12.r),
                    SizedBox(width: 4.w),
                    Text('${recipe.cookTimeMinutes} min', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                    SizedBox(width: 8.w),
                    Icon(Icons.favorite, color: AppColors.error, size: 12.r),
                    SizedBox(width: 4.w),
                    Text('${recipe.likesCount}', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(Icons.more_vert, color: AppColors.textSecondary, size: 20.r),
            padding: EdgeInsets.zero,
            onSelected: (value) {
              if (value == 'publish') onPublish();
              if (value == 'delete') onDelete();
            },
            itemBuilder: (context) => [
              if (!recipe.isPublished)
                const PopupMenuItem(
                  value: 'publish',
                  child: Text('Publish'),
                ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: AppColors.error)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}