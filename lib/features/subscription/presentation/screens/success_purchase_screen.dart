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
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              
              Icon(
                Icons.check,
                color: AppColors.primary,
                size: 80.r,
              ).animate()
               .scale(begin: const Offset(0.5, 0.5), duration: 600.ms, curve: Curves.elasticOut)
               .fadeIn(duration: 300.ms),
              
              SizedBox(height: 32.h),
              
              Text(
                "You're all set.",
                style: TextStyle(
                  fontSize: 34.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1),
              
              SizedBox(height: 12.h),
              
              Text(
                "Your personalized meals are ready.",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 400.ms).fadeIn(),
              
              SizedBox(height: 40.h),
              
              const _SimpleStatus(label: "ALL INGREDIENTS MAPPED")
                  .animate(delay: 500.ms).fadeIn().slideX(begin: 0.1),
              SizedBox(height: 12.h),
              const _SimpleStatus(label: "HEALTH SYNC ACTIVE")
                  .animate(delay: 650.ms).fadeIn().slideX(begin: 0.1),
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: FilledButton(
                  onPressed: () => context.go(AppRoutes.home),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    "View My Meals",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ).animate(delay: 800.ms).fadeIn().slideY(begin: 0.1),
              
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }
}

class _SimpleStatus extends StatelessWidget {
  final String label;

  const _SimpleStatus({required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6.w,
          height: 6.h,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: Colors.black,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }
}
