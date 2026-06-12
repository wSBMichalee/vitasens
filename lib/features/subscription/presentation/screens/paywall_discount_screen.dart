import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class PaywallDiscountScreen extends StatefulWidget {
  const PaywallDiscountScreen({super.key});

  @override
  State<PaywallDiscountScreen> createState() => _PaywallDiscountScreenState();
}

class _PaywallDiscountScreenState extends State<PaywallDiscountScreen> {
  int _selectedPlanIndex = 0; // 0 for Yearly, 1 for Monthly

  static const List<String> _features = [
    'Meals from your pantry',
    'Tailored to your health',
    'AI-powered suggestions',
    'No more food waste',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 40.h, 24.w, 40.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ─── Heading ───────────────────────────────────────────────
                  Text(
                    'Unlock VitaSense',
                    style: TextStyle(
                      fontSize: 34.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                  SizedBox(height: 32.h),

                  // ─── Features ────────────────────────────────────────────
                  ...List.generate(_features.length, (i) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Row(
                      children: [
                        Icon(Icons.check, color: AppColors.primary, size: 24.r),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            _features[i],
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(delay: Duration(milliseconds: 80 + i * 60))
                    .fadeIn(duration: 400.ms)
                    .slideX(begin: -0.04, end: 0)),

                  SizedBox(height: 32.h),

                  // ─── Plans ────────────────────────────────────────────────
                  _PlanCard(
                    title: 'Yearly Plan',
                    price: '\$4.91',
                    priceSuffix: '/mo',
                    billingNote: '\$59.00 billed annually',
                    badgeText: '3 DAYS FREE',
                    isSelected: _selectedPlanIndex == 0,
                    onTap: () => setState(() => _selectedPlanIndex = 0),
                  ).animate(delay: 280.ms).fadeIn(duration: 400.ms),

                  SizedBox(height: 16.h),

                  _PlanCard(
                    title: 'Monthly Plan',
                    price: '\$9.99',
                    priceSuffix: '/mo',
                    billingNote: 'Billed monthly',
                    badgeText: '3 DAYS FREE',
                    isSelected: _selectedPlanIndex == 1,
                    onTap: () => setState(() => _selectedPlanIndex = 1),
                  ).animate(delay: 320.ms).fadeIn(duration: 400.ms),

                  SizedBox(height: 40.h),

                  // ─── CTA ──────────────────────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    height: 56.h,
                    child: FilledButton(
                      onPressed: () {
                        // TODO: RevenueCat purchase
                        context.go(AppRoutes.home);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2ECC71),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.r),
                        ),
                      ),
                      child: Text(
                        _selectedPlanIndex == 0 ? 'Start My 3-Day Free Trial' : 'Start Monthly Plan',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ).animate(delay: 360.ms).fadeIn(duration: 400.ms),

                  SizedBox(height: 16.h),

                  Center(
                    child: Text(
                      'Cancel anytime',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey[400],
                      ),
                    ),
                  ).animate(delay: 360.ms).fadeIn(duration: 400.ms),
                ],
              ),
            ),

            // ─── X Close Button (No Restore Button) ────────────────────────
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.all(16.r),
                child: IconButton(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: Icon(Icons.close, color: Colors.black, size: 24.r),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  final String title;
  final String price;
  final String priceSuffix;
  final String billingNote;
  final String? badgeText;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanCard({
    required this.title,
    required this.price,
    required this.priceSuffix,
    required this.billingNote,
    this.badgeText,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFF2ECC71) : Colors.white,
              border: Border.all(
                color: isSelected ? const Color(0xFF2ECC71) : Colors.grey[300]!,
                width: 1.5,
              ),
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (isSelected) ...[
                            Icon(Icons.check_circle, color: Colors.white, size: 20.r),
                            SizedBox(width: 8.w),
                          ],
                          Text(
                            title,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        billingNote,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: isSelected ? Colors.white70 : Colors.grey[500],
                        ),
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
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                    Text(
                      priceSuffix,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: isSelected ? Colors.white70 : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (badgeText != null)
          Positioned(
            top: -12.h,
            right: 16.w,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.black : const Color(0xFF2ECC71),
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                badgeText!,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
