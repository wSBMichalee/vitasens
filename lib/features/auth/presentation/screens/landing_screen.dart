import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  static const String _heroImageUrl =
      'https://images.unsplash.com/photo-1504674900247-0877df9cc836?w=1200&q=80';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ─── Hero image ──────────────────────────────────────────────
          SizedBox(
            height: 280.h,
            width: double.infinity,
            child: CachedNetworkImage(
              imageUrl: _heroImageUrl,
              fit: BoxFit.cover,
              placeholder: (_, __) => Shimmer.fromColors(
                baseColor: AppColors.border,
                highlightColor: AppColors.borderLight,
                child: Container(color: AppColors.border),
              ),
              errorWidget: (_, __, ___) =>
                  Container(color: AppColors.successLight),
            ),
          ).animate().fadeIn(duration: 500.ms),

          // ─── Content ─────────────────────────────────────────────────
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 24.h),

                  // Logo box
                  Container(
                    width: 72.r,
                    height: 72.r,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundDark,
                      borderRadius: BorderRadius.circular(18.r),
                    ),
                    child: Icon(Icons.eco, color: Colors.white, size: 36.r),
                  )
                      .animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        duration: 500.ms,
                        curve: Curves.easeOutBack,
                      )
                      .fadeIn(duration: 300.ms),

                  SizedBox(height: 16.h),

                  Text(
                    'VitaSense',
                    style: TextStyle(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                      fontFamily: AppTextStyles.headingXL.fontFamily,
                    ),
                  ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.08, end: 0),

                  SizedBox(height: 12.h),

                  Text(
                    'What to cook based on what you have\nand how you feel.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ).animate(delay: 150.ms).fadeIn(),

                  SizedBox(height: 28.h),

                  // Feature pills
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeaturePill(
                        label: 'Personalized meals',
                        dotColor: AppColors.secondary,
                      ),
                    ],
                  ).animate(delay: 200.ms).fadeIn().slideX(begin: -0.05, end: 0),

                  SizedBox(height: 10.h),

                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _FeaturePill(
                        label: 'Zero food waste',
                        dotColor: AppColors.primary,
                      ),
                    ],
                  ).animate(delay: 260.ms).fadeIn().slideX(begin: -0.05, end: 0),

                  const Spacer(),

                  // CTA button
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: FilledButton(
                      onPressed: () => context.go(AppRoutes.onboarding),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Start My Plan',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFamily: AppTextStyles.labelLarge.fontFamily,
                        ),
                      ),
                    ),
                  ).animate(delay: 320.ms).fadeIn().slideY(begin: 0.1, end: 0),

                  SizedBox(height: 16.h),

                  // Sign in link
                  GestureDetector(
                    onTap: () => context.go(AppRoutes.login),
                    child: RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: 'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          TextSpan(
                            text: 'Sign in',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 360.ms).fadeIn(),

                  SizedBox(height: 36.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label, required this.dotColor});

  final String label;
  final Color dotColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dotColor,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 15.sp,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
