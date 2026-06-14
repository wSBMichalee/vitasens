import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class WeekStrip extends StatelessWidget {
  const WeekStrip({super.key, required this.selectedDate, required this.onDateSelected});
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateSelected;

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final startOfWeek = today.subtract(Duration(days: today.weekday - 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));
    const dayLabels = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      color: AppColors.backgroundWhite,
      padding: EdgeInsets.fromLTRB(8.w, 6.h, 8.w, 0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(7, (i) {
              final day = days[i];
              final isSelected = day.day == selectedDate.day && day.month == selectedDate.month;
              final isToday = day.day == today.day && day.month == today.month;
              return GestureDetector(
                onTap: () => onDateSelected(day),
                child: SizedBox(
                  width: 40.r,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        dayLabels[i],
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: isSelected ? AppColors.primary : AppColors.textMuted,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: isSelected || isToday ? FontWeight.w800 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : (isToday ? AppColors.textPrimary : AppColors.textSecondary),
                        ),
                      ),
                      SizedBox(height: 6.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 2.h,
                        width: isSelected ? 24.w : 0,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                      SizedBox(height: 2.h),
                    ],
                  ),
                ),
              );
            }),
          ),
          const Divider(color: AppColors.borderLight, height: 1, thickness: 1),
        ],
      ),
    );
  }
}