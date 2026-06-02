import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class SuccessPurchaseScreen extends StatelessWidget {
  const SuccessPurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 260.h,
            color: AppColors.successLight,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(24.r),
              child: Column(
                children: [
                  SizedBox(
                    height: 100.h,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 100.w,
                          height: 100.h,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 20,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 80.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(16.r),
                            ),
                            child: Icon(
                              Icons.check_rounded,
                              color: Colors.white,
                              size: 44.r,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 36.w,
                            height: 36.h,
                            decoration: BoxDecoration(
                              color: AppColors.secondary,
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Icon(
                              Icons.auto_awesome,
                              color: Colors.white,
                              size: 18.r,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.5, 0.5),
                        duration: 600.ms,
                        curve: Curves.elasticOut,
                      )
                      .fadeIn(duration: 300.ms),
                  SizedBox(height: 24.h),
                  Text(
                    "You're all set",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 300.ms)
                      .fadeIn()
                      .slideY(begin: 0.1),
                  SizedBox(height: 12.h),
                  Text(
                    "Your personalized meals are ready\nbased on your kitchen and health.",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 400.ms)
                      .fadeIn(),
                  SizedBox(height: 32.h),
                  const _StatusBadge(
                    label: "ALL INGREDIENTS MAPPED",
                    dotColor: AppColors.primary,
                  )
                      .animate(delay: 500.ms)
                      .fadeIn()
                      .slideX(begin: 0.1),
                  SizedBox(height: 8.h),
                  const _StatusBadge(
                    label: "HEALTH SYNC ACTIVE",
                    dotColor: AppColors.secondary,
                  )
                      .animate(delay: 650.ms)
                      .fadeIn()
                      .slideX(begin: 0.1),
                  SizedBox(height: 40.h),
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.backgroundDark,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      onPressed: () => context.go(AppRoutes.home),
                      child: Text(
                        "View My Meals",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  )
                      .animate(delay: 800.ms)
                      .fadeIn()
                      .slideY(begin: 0.1),
                  SizedBox(height: 12.h),
                  Text(
                    "SUBSCRIPTION ACTIVATED",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                      letterSpacing: 1.0,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 900.ms)
                      .fadeIn(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final String label;
  final Color dotColor;

  const _StatusBadge({
    required this.label,
    required this.dotColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}
