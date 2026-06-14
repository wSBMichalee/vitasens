import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class NutritionTile extends StatelessWidget {
  const NutritionTile({super.key, required this.label, required this.value, required this.unit, required this.color});
  final String label, value, unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 6.w),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(children: [
          Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w800, color: color)),
          Text(unit, style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.w600, color: color)),
          SizedBox(height: 2.h),
          Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textMuted)),
        ]),
      ),
    );
  }
}

