import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class ProgressHistoryScreen extends StatelessWidget {
  const ProgressHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.r, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Progress History', style: AppTextStyles.headingSmall),
        centerTitle: true,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: AppColors.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header card
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(16.r),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                border: Border.all(color: AppColors.border),
                borderRadius: BorderRadius.circular(16.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.history, color: AppColors.primary, size: 24.r),
                  SizedBox(width: 12.w),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly History',
                        style: AppTextStyles.labelLarge.copyWith(fontSize: 16.sp),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Last 4 weeks overview',
                        style: AppTextStyles.bodySmall.copyWith(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Week cards
            const _WeekCard(label: 'This Week', daysLogged: 5, avgCalories: 1820),
            SizedBox(height: 12.h),
            const _WeekCard(label: 'Last Week', daysLogged: 7, avgCalories: 1950),
            SizedBox(height: 12.h),
            const _WeekCard(label: '2 Weeks Ago', daysLogged: 4, avgCalories: 1740),
            SizedBox(height: 12.h),
            const _WeekCard(label: '3 Weeks Ago', daysLogged: 6, avgCalories: 1880),
          ],
        ),
      ),
    );
  }
}

class _WeekCard extends StatelessWidget {
  const _WeekCard({
    required this.label,
    required this.daysLogged,
    required this.avgCalories,
  });

  final String label;
  final int daysLogged;
  final int avgCalories;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: AppTextStyles.labelMedium.copyWith(fontSize: 15.sp),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      '$daysLogged/7 days logged',
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 12.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$avgCalories avg kcal',
                style: AppTextStyles.labelMedium.copyWith(
                  fontSize: 14.sp,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(3.r),
            child: LinearProgressIndicator(
              value: daysLogged / 7,
              backgroundColor: AppColors.borderLight,
              color: AppColors.primary,
              minHeight: 6.h,
            ),
          ),
        ],
      ),
    );
  }
}
