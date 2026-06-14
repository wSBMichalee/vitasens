import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';


class MacroSummaryBar extends StatelessWidget {
  const MacroSummaryBar({super.key, 
    required this.kcalConsumed, required this.kcalGoal,
    required this.proteinConsumed, required this.proteinGoal,
    required this.fatConsumed, required this.fatGoal,
    required this.carbsConsumed, required this.carbsGoal,
  });

  final int kcalConsumed, kcalGoal;
  final int proteinConsumed, proteinGoal;
  final int fatConsumed, fatGoal;
  final int carbsConsumed, carbsGoal;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundWhite,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 12.h),
      child: Row(
        children: [
          MacroBarItem(label: 'Protein', consumed: proteinConsumed, goal: proteinGoal, unit: 'g', color: AppColors.proteinColor),
          MacroBarItem(label: 'Fat', consumed: fatConsumed, goal: fatGoal, unit: 'g', color: AppColors.fatColor),
          MacroBarItem(label: 'Carbs', consumed: carbsConsumed, goal: carbsGoal, unit: 'g', color: AppColors.carbsColor, isLast: true),
        ],
      ),
    );
  }
}

class MacroBarItem extends StatelessWidget {
  const MacroBarItem({super.key, 
    required this.label, required this.consumed, required this.goal,
    required this.unit, required this.color, this.isLast = false,
  });

  final String label, unit;
  final int consumed, goal;
  final Color color;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final progress = (consumed / goal).clamp(0.0, 1.0);
    return Expanded(
      child: Padding(
        padding: EdgeInsets.only(right: isLast ? 0 : 12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              unit == 'kcal' ? '$consumed kcal' : '$consumed/$goal$unit',
              style: TextStyle(fontSize: unit == 'kcal' ? 10.sp : 11.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
            SizedBox(height: 2.h),
            Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
            SizedBox(height: 4.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(2.r),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 3.h,
                backgroundColor: AppColors.borderLight,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}