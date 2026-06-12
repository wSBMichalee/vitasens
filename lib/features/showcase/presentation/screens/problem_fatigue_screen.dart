import 'package:cached_network_image/cached_network_image.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class ProblemFatigueScreen extends StatelessWidget {
  const ProblemFatigueScreen({super.key});

  static const _image =
      'https://images.unsplash.com/photo-1556911220-bff31c812dba?w=900&q=90';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 132.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleIconButton(
                        icon: Icons.chevron_left,
                        onTap: () => context.canPop()
                            ? context.pop()
                            : context.go(AppRoutes.landing),
                      ),
                      const Expanded(child: StepDots(active: 0)),
                      SizedBox(width: 48.w),
                    ],
                  ),
                  SizedBox(height: 72.h),
                  Text(
                    'Decision fatigue\nat the fridge?',
                    style: TextStyle(
                      fontSize: 40.sp,
                      height: 1.3,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 30.h),
                  Text(
                    'Most of us spend 15 minutes a day just deciding what to eat. VitaSense solves this by turning your ingredients into healthy decisions.',
                    style: TextStyle(
                      fontSize: 24.sp,
                      height: 1.55,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  SizedBox(height: 72.h),
                  SizedBox(
                    height: 258.h,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(24.r),
                          child: CachedNetworkImage(
                            imageUrl: _image,
                            width: double.infinity,
                            height: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          right: 16.w,
                          bottom: -32.h,
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 17.w,
                              vertical: 15.h,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(color: AppColors.border),
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 22,
                                  offset: const Offset(0, 12),
                                  color: Colors.black.withValues(alpha: 0.13),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.schedule,
                                  color: AppColors.secondary,
                                  size: 24.r,
                                ),
                                SizedBox(width: 12.w),
                                Text(
                                  'Saves 105 mins / week',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 78.h),
                  Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22.r),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 56.r,
                          height: 56.r,
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(14.r),
                          ),
                          child: Icon(
                            Icons.auto_awesome_outlined,
                            color: AppColors.primary,
                            size: 29.r,
                          ),
                        ),
                        SizedBox(width: 18.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart Pairing',
                                style: TextStyle(
                                  fontSize: 22.sp,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                "We don't just find recipes. We find the right meals for your goals.",
                                style: TextStyle(
                                  fontSize: 17.sp,
                                  height: 1.45,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 32.w,
              right: 32.w,
              bottom: 32.h,
              child: NavyButton(
                label: 'Continue',
                onPressed: () => context.go(AppRoutes.featureMatcher),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StepDots extends StatelessWidget {
  const StepDots({super.key, required this.active});

  final int active;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (index) {
        return Container(
          width: 32.w,
          height: 6.h,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          decoration: BoxDecoration(
            color: active == index ? AppColors.textPrimary : AppColors.border,
            borderRadius: BorderRadius.circular(4.r),
          ),
        );
      }),
    );
  }
}

class NavyButton extends StatelessWidget {
  const NavyButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 60.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF06192A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18.r),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22.sp,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class CircleIconButton extends StatelessWidget {
  const CircleIconButton({super.key, required this.icon, this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: const Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.04),
            ),
          ],
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 24.r),
      ),
    );
  }
}