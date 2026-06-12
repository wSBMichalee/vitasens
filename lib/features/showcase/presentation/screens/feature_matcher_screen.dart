import 'package:cached_network_image/cached_network_image.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/showcase/presentation/screens/problem_fatigue_screen.dart';

class FeatureMatcherScreen extends StatelessWidget {
  const FeatureMatcherScreen({super.key});

  static const _image =
      'https://images.unsplash.com/photo-1618164436241-4473940d1f5c?w=900&q=90';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24.w, 66.h, 24.w, 32.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 13.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 10.r,
                      height: 10.r,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Text(
                      'CLINICAL AI MATCHER',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textSecondary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 38.h),
              Text(
                'Meals from what\nyou already have.',
                style: TextStyle(
                  fontSize: 40.sp,
                  height: 1.22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 56.h),
              Expanded(
                child: ListView(
                  children: [
                    AspectRatio(
                      aspectRatio: 1,
                      child: Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(32.r),
                            child: CachedNetworkImage(
                              imageUrl: _image,
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: double.infinity,
                            ),
                          ),
                          Positioned(
                            top: 24.h,
                            left: 24.w,
                            child: const WhiteLabel('RECOGNIZED: BASIL'),
                          ),
                          Positioned(
                            top: 24.h,
                            right: 24.w,
                            child: const WhiteLabel('MATCH: 98%'),
                          ),
                          Positioned(
                            left: 24.w,
                            right: 24.w,
                            bottom: 24.h,
                            child: Container(
                              padding: EdgeInsets.all(18.r),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.95),
                                borderRadius: BorderRadius.circular(16.r),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'HEALTH SUGGESTION',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  SizedBox(height: 12.h),
                                  Text(
                                    'Pesto Grains Bowl',
                                    style: TextStyle(
                                      fontSize: 20.sp,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  SizedBox(height: 4.h),
                                  Text(
                                    'Optimized for your Heart Health goal',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                    const FeatureLine(
                      icon: Icons.center_focus_strong,
                      color: AppColors.secondary,
                      text: 'Scans your fridge for matches',
                    ),
                    SizedBox(height: 16.h),
                    const FeatureLine(
                      icon: Icons.room_service_outlined,
                      color: AppColors.primary,
                      text: 'Suggests meals in < 30 secs',
                    ),
                    SizedBox(height: 72.h),
                    NavyButton(
                      label: 'Next Feature',
                      onPressed: () => context.go(AppRoutes.resultsAnalysis),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WhiteLabel extends StatelessWidget {
  const WhiteLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class FeatureLine extends StatelessWidget {
  const FeatureLine({super.key, 
    required this.icon,
    required this.color,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 17.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24.r),
          SizedBox(width: 22.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}