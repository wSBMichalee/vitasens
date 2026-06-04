import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class PaywallScreen extends StatelessWidget {
  const PaywallScreen({super.key});

  static const String _heroImageUrl =
      'https://images.unsplash.com/photo-1490645935967-10de6ba17061?w=1200&q=80';

  static const List<String> _features = [
    'Meals from your own ingredients',
    'Tailored to your health',
    'No more guessing what to eat',
    'Save time and reduce food waste',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: Stack(
        children: [
          // ─── Scrollable content ────────────────────────────────────────────
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Hero image ──────────────────────────────────────────────
                SizedBox(
                  height: 240.h,
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

                // ─── Body ────────────────────────────────────────────────────
                Padding(
                  padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Unlock your\npersonalized meal plan',
                        style: TextStyle(
                          fontSize: 26.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                          fontFamily: AppTextStyles.headingXL.fontFamily,
                          height: 1.2,
                        ),
                      ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                      SizedBox(height: 24.h),

                      // Feature bullets
                      ...List.generate(_features.length, (i) => Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Row(
                          children: [
                            Container(
                              width: 28.r,
                              height: 28.r,
                              decoration: const BoxDecoration(
                                color: AppColors.primaryLight,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(Icons.check,
                                  color: AppColors.primary, size: 14.r),
                            ),
                            SizedBox(width: 12.w),
                            Expanded(
                              child: Text(
                                _features[i],
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ).animate(delay: Duration(milliseconds: 80 + i * 60))
                        .fadeIn(duration: 400.ms)
                        .slideX(begin: -0.04, end: 0)),

                      SizedBox(height: 8.h),

                      // ─── Yearly plan card (selected) ──────────────────────
                      const _PlanCard(
                        title: 'Yearly Plan',
                        price: '\$4.91',
                        priceSuffix: '/mo',
                        billingNote: '\$59.00 billed annually',
                        badgeText: 'BEST VALUE',
                        isSelected: true,
                        delay: 280,
                      ),

                      SizedBox(height: 12.h),

                      // ─── Monthly plan card ────────────────────────────────
                      const _PlanCard(
                        title: 'Monthly Plan',
                        price: '\$9.99',
                        priceSuffix: '/mo',
                        billingNote: 'Billed monthly',
                        badgeText: null,
                        isSelected: false,
                        delay: 320,
                      ),

                      SizedBox(height: 24.h),

                      // ─── CTA ──────────────────────────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 56.h,
                        child: FilledButton(
                          onPressed: () =>
                              context.go(AppRoutes.successPurchase),
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.backgroundDark,
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
                      ).animate(delay: 360.ms).fadeIn(duration: 400.ms),

                      SizedBox(height: 12.h),

                      Center(
                        child: Text(
                          'CANCEL ANYTIME',
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textMuted,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ).animate(delay: 360.ms).fadeIn(duration: 400.ms),

                      SizedBox(height: 40.h),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ─── X close button ────────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.home),
                  child: Container(
                    width: 36.r,
                    height: 36.r,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(Icons.close,
                        color: AppColors.textPrimary, size: 18.r),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Plan card ─────────────────────────────────────────────────────────────────
class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.price,
    required this.priceSuffix,
    required this.billingNote,
    required this.badgeText,
    required this.isSelected,
    required this.delay,
  });

  final String title;
  final String price;
  final String priceSuffix;
  final String billingNote;
  final String? badgeText;
  final bool isSelected;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.border,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      billingNote,
                      style: TextStyle(
                          fontSize: 13.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    price,
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: AppTextStyles.numberMedium.fontFamily,
                    ),
                  ),
                  Text(
                    priceSuffix,
                    style: TextStyle(
                        fontSize: 13.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (badgeText != null)
          Positioned(
            top: -12.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                badgeText!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
      ],
    )
        .animate(delay: Duration(milliseconds: delay))
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.05, end: 0);
  }
}
