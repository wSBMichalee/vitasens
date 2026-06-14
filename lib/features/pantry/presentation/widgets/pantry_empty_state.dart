import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class PantryEmptyState extends StatelessWidget {
  const PantryEmptyState({super.key, required this.isFiltered, required this.onActionPressed});
  final bool isFiltered;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(32.r),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72.r,
              height: 72.r,
              decoration: const BoxDecoration(
                color: AppColors.borderLight,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.kitchen_outlined,
                  size: 36.r, color: AppColors.textMuted),
            ),
            SizedBox(height: 20.h),
            Text(
              isFiltered ? 'No ingredients found' : 'Your pantry is empty',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              isFiltered
                  ? 'Try a different search or filter'
                  : 'Add your first ingredient to get started',
              style:
                  TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            SizedBox(
              height: 56.h,
              width: double.infinity,
              child: FilledButton(
                onPressed: onActionPressed,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r)),
                ),
                child: Text(
                  isFiltered ? 'Clear filters' : 'Add ingredient',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textWhite,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
