import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _yearlySelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // 1. Hero image (góra, fullWidth, height 280)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280.h,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFFE8F5E9)), // Placeholder
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        AppColors.background,
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),

          // 3. Scrollowalny content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 240, // Zawartość zaczyna się pod końcem Hero Image
                bottom: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Unlock Your Kitchen's Full Potential",
                    style: TextStyle(
                      fontSize: 26.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: AppTextStyles.headingXL.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    "Get personalized meal ideas for every\nhealth goal and every ingredient in your pantry.",
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontFamily: AppTextStyles.bodyMedium.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  
                  _buildFeatureRow("Unlimited Meal Matching"),
                  _buildFeatureRow("Advanced Health Goal Analytics"),
                  _buildFeatureRow("Priority Support & New Recipes Daily"),
                  
                  SizedBox(height: 28.h),

                  // PLAN SELECTOR - Yearly plan
                  GestureDetector(
                    onTap: () => setState(() => _yearlySelected = true),
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: _yearlySelected ? AppColors.primary : AppColors.border,
                          width: _yearlySelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Yearly",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontFamily: AppTextStyles.labelLarge.fontFamily,
                                ),
                              ),
                              Text(
                                "BEST VALUE",
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primary,
                                  letterSpacing: 1.0,
                                  fontFamily: AppTextStyles.captionBold.fontFamily,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$4.99/mo",
                                style: TextStyle(
                                  fontSize: 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                  fontFamily: AppTextStyles.numberMedium.fontFamily,
                                ),
                              ),
                              Text(
                                "Billed annually",
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: AppColors.textSecondary,
                                  fontFamily: AppTextStyles.bodySmall.fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

                  SizedBox(height: 12.h),

                  // PLAN SELECTOR - Monthly plan
                  GestureDetector(
                    onTap: () => setState(() => _yearlySelected = false),
                    child: Container(
                      padding: EdgeInsets.all(16.r),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: !_yearlySelected ? AppColors.primary : AppColors.border,
                          width: !_yearlySelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Monthly",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: !_yearlySelected ? AppColors.textPrimary : AppColors.textSecondary,
                              fontFamily: AppTextStyles.labelLarge.fontFamily,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "\$9.99/mo",
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: !_yearlySelected ? AppColors.textPrimary : AppColors.textSecondary,
                              fontFamily: AppTextStyles.labelLarge.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

                  SizedBox(height: 28.h),

                  // CTA Button
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
                      onPressed: () => context.go(AppRoutes.successPurchase),
                      child: Text(
                        _yearlySelected ? "Try Free for 3 Days" : "Try Free for 7 Days",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: AppTextStyles.labelLarge.fontFamily,
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: 12.h),

                  Text(
                    _yearlySelected
                        ? "3 DAYS FREE, THEN \$59/YEAR. CANCEL ANYTIME."
                        : "7 DAYS FREE, THEN \$9.99/MONTH. CANCEL ANYTIME.",
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                      letterSpacing: 0.5,
                      fontFamily: AppTextStyles.caption.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),
            ),
          ),

          // 2. X button (top-right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16.0.r),
                child: GestureDetector(
                  onTap: () => context.go(AppRoutes.home),
                  child: Container(
                    width: 36.w,
                    height: 36.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.close,
                      color: AppColors.textPrimary,
                      size: 18.r,
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

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 15.sp,
                color: AppColors.textPrimary,
                fontFamily: AppTextStyles.bodyLarge.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
