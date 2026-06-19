import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.recipe});

  final Map<String, dynamic> recipe;

  @override
  Widget build(BuildContext context) {
    final imageUrl = recipe['imageUrl'] as String?;
    final title = recipe['title'] as String? ?? 'Brak tytułu';
    final cookTime = recipe['cookTimeMinutes'] as int? ?? 0;
    final calories = (recipe['calories'] as num?)?.toInt() ?? 0;
    final proteinG = (recipe['proteinG'] as num?)?.toInt() ?? 0;
    final carbsG = (recipe['carbsG'] as num?)?.toInt() ?? 0;
    final fatG = (recipe['fatG'] as num?)?.toInt() ?? 0;
    final geminiReason = recipe['geminiReason'] as String?;
    final missedIngredientsRaw = recipe['missedIngredients'] as List<dynamic>? ?? [];
    
    final isEnriching = calories == 0;
    
    final missedIngredients = missedIngredientsRaw
        .map((e) => (e as Map<String, dynamic>)['name'] as String?)
        .where((e) => e != null)
        .cast<String>()
        .take(2)
        .toList();

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Image
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    height: 180.h,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
                  )
                : _buildPlaceholder(),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(14.r),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                
                // Clock & Flame row
                Row(
                  children: [
                    Icon(Icons.schedule, size: 14.r, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      '$cookTime min',
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.w),
                      child: Text('|', style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted)),
                    ),
                    Icon(Icons.local_fire_department_outlined, size: 14.r, color: AppColors.textSecondary),
                    SizedBox(width: 4.w),
                    Text(
                      '$calories kcal',
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                
                // Macros row
                if (isEnriching)
                  _buildMacroSkeleton()
                else
                  Row(
                    children: [
                      _buildMacroPill('P: ${proteinG}g'),
                      SizedBox(width: 8.w),
                      _buildMacroPill('C: ${carbsG}g'),
                      SizedBox(width: 8.w),
                      _buildMacroPill('F: ${fatG}g'),
                    ],
                  ),
                
                if (geminiReason != null && geminiReason.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 12.r, color: AppColors.primaryDark),
                        SizedBox(width: 4.w),
                        Expanded(
                          child: Text(
                            geminiReason,
                            style: TextStyle(
                              fontSize: 11.sp,
                              fontStyle: FontStyle.italic,
                              color: AppColors.primaryDark,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                
                if (missedIngredients.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  Text(
                    'Brakuje: ${missedIngredients.join(', ')}',
                    style: TextStyle(fontSize: 11.sp, color: AppColors.textMuted),
                  ),
                ],
                
                SizedBox(height: 16.h),
                // Button
                SizedBox(
                  height: 44.h,
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => context.push(AppRoutes.recipeDetails, extra: recipe),
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Zacznij gotować',
                      style: AppTextStyles.labelMedium.copyWith(color: AppColors.textWhite),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 180.h,
      decoration: BoxDecoration(
        color: Colors.grey[200],
      ),
      child: Center(
        child: Icon(Icons.restaurant, size: 40.r, color: AppColors.textMuted),
      ),
    );
  }

  Widget _buildMacroPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }

  Widget _buildMacroSkeleton() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.border,
      child: Row(
        children: [
          Container(width: 60.w, height: 24.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r))),
          SizedBox(width: 8.w),
          Container(width: 60.w, height: 24.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r))),
          SizedBox(width: 8.w),
          Container(width: 60.w, height: 24.h, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8.r))),
        ],
      ),
    );
  }
}