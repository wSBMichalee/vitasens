import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';


class NutriBadge extends StatelessWidget {
  const NutriBadge({super.key, required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}