import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class RecipeCookButton extends StatelessWidget {
  final VoidCallback onCook;
  final bool isCooking;

  const RecipeCookButton({
    super.key,
    required this.onCook,
    required this.isCooking,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 28.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.06),
            blurRadius: 20.r,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              onPressed: isCooking ? null : onCook,
              child: isCooking
                  ? SizedBox(
                      width: 24.w,
                      height: 24.h,
                      child: CircularProgressIndicator(
                        color: AppColors.textWhite,
                        strokeWidth: 2.w,
                      ),
                    )
                  : Text(
                      'Start cooking now',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textWhite,
                      ),
                    ),
            ),
          ),

          SizedBox(height: 10.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.people, color: AppColors.textMuted, size: 14.r),
              SizedBox(width: 4.w),
              Text(
                'USED BY 12,000+ USERS THIS WEEK',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: AppColors.textMuted,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),

          SizedBox(height: 4.h),

          Text(
            'UPDATES YOUR PANTRY AUTOMATICALLY',
            style: TextStyle(
              fontSize: 10.sp,
              color: AppColors.textMuted,
              letterSpacing: 0.3,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
