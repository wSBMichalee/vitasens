import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';


class WeeklyConsistencyCard extends StatelessWidget {
  const WeeklyConsistencyCard({super.key, required this.weekly});
  final List<Map<String, dynamic>> weekly;

  @override
  Widget build(BuildContext context) {
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final todayIndex = DateTime.now().weekday - 1;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
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
                      'Weekly consistency',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "YOU'RE DOING BETTER THAN LAST WEEK",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.trending_up_rounded,
                  color: AppColors.primary, size: 22.r),
            ],
          ),

          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(labels.length, (i) {
              final data = weekly.length > i ? weekly[i] : null;
              final isCompleted = data != null &&
                  (data['completed'] == true || data['calories'] != null);
              final isMissed = i < todayIndex && !isCompleted;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 34.r,
                      height: 34.r,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCompleted
                            ? AppColors.primary
                            : isMissed
                                ? AppColors.errorLight
                                : AppColors.borderLight,
                      ),
                      child: Icon(
                        isCompleted
                            ? Icons.check
                            : isMissed
                                ? Icons.close
                                : Icons.remove,
                        size: 15.r,
                        color: isCompleted
                            ? AppColors.textWhite
                            : isMissed
                                ? AppColors.error
                                : AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: isMissed
                            ? AppColors.error
                            : AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}