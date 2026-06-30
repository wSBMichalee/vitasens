import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';


class MacroColumn extends StatelessWidget {
  const MacroColumn({super.key, 
    required this.label,
    required this.consumed,
    required this.goal,
    required this.color,
    this.isLow = false,
    this.animationValue = 1.0,
  });

  final String label;
  final int consumed;
  final int goal;
  final Color color;
  final bool isLow;
  final double animationValue;

  @override
  Widget build(BuildContext context) {
    final int animatedConsumed = (consumed * animationValue).round();
    final double targetProgress = (consumed / goal).clamp(0.0, 1.0);
    final double progress = targetProgress * animationValue;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Etykieta + status LOW
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ),
              if (isLow) ...[  
                SizedBox(width: 4.w),
                Text(
                  '↓',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w900,
                    color: AppColors.error,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 6.h),
          // Wartość
          Text(
            '${animatedConsumed}g',
            style: TextStyle(
              fontSize: 20.sp,
              height: 1.1,
              fontWeight: FontWeight.w900,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'of ${goal}g',
            style: TextStyle(
              fontSize: 12.sp,
              height: 1.5,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 10.h),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6.h,
              color: color,
              backgroundColor: AppColors.borderLight,
            ),
          ),
        ],
      ),
    );
  }
}