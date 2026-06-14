import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';


class TodaySummaryHeader extends StatelessWidget {
  const TodaySummaryHeader({super.key, required this.daily});
  final Map<String, dynamic> daily;

  int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is double) return val.toInt();
    return 0;
  }

  String _formatCalories(int cal) {
    if (cal >= 1000) {
      final thousands = cal ~/ 1000;
      final remainder = (cal % 1000).toString().padLeft(3, '0');
      return '$thousands,$remainder';
    }
    return '$cal';
  }

  @override
  Widget build(BuildContext context) {
    final calories = _toInt(
        (daily['calories'] as Map<String, dynamic>?)?['actual'] ??
            daily['calories']);

    return Row(
      children: [
        Text(
          "TODAY'S SUMMARY",
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const Spacer(),
        Text(
          '${_formatCalories(calories)} kcal consumed',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}