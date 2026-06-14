import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'dart:async';

class LoadingView extends StatefulWidget {
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => LoadingViewState();
}

class LoadingViewState extends State<LoadingView> {
  int _currentStep = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Simulate steps changing
    _timer = Timer.periodic(const Duration(milliseconds: 1500), (timer) {
      if (mounted && _currentStep < 3) {
        setState(() {
          _currentStep++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 40.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 24.h),
          Text(
            'Analyzing URL...',
            style: AppTextStyles.headingMedium.copyWith(color: AppColors.textPrimary),
          ),
          SizedBox(height: 40.h),
          _buildLoadingStep(
            index: 0,
            icon: Icons.link,
            title: 'Reading URL',
          ),
          SizedBox(height: 16.h),
          _buildLoadingStep(
            index: 1,
            icon: Icons.movie_outlined,
            title: 'Analyzing video content',
          ),
          SizedBox(height: 16.h),
          _buildLoadingStep(
            index: 2,
            icon: Icons.description_outlined,
            title: 'Extracting recipe',
          ),
          SizedBox(height: 16.h),
          _buildLoadingStep(
            index: 3,
            icon: Icons.kitchen,
            title: 'Comparing with pantry',
          ),
          SizedBox(height: 80.h),
        ],
      ),
    );
  }

  Widget _buildLoadingStep({required int index, required IconData icon, required String title}) {
    final isDone = _currentStep > index;
    final isActive = _currentStep == index;

    return Row(
      children: [
        Container(
          width: 32.r,
          height: 32.r,
          decoration: BoxDecoration(
            color: isDone ? AppColors.primaryLight : AppColors.borderLight,
            shape: BoxShape.circle,
          ),
          child: isDone
              ? Icon(Icons.check, color: AppColors.primary, size: 16.r)
              : isActive
                  ? Padding(
                      padding: EdgeInsets.all(8.r),
                      child: const CircularProgressIndicator(color: AppColors.primary, strokeWidth: 2),
                    )
                  : Icon(icon, color: AppColors.textMuted, size: 16.r),
        ),
        SizedBox(width: 12.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
            color: isDone || isActive ? AppColors.textPrimary : AppColors.textMuted,
          ),
        ),
      ],
    );
  }
}