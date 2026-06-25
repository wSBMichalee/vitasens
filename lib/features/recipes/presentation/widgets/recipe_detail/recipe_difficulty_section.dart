import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class RecipeDifficultySection extends StatelessWidget {
  final int cookTimeMinutes;

  const RecipeDifficultySection({super.key, required this.cookTimeMinutes});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.bar_chart_rounded, color: AppColors.primary, size: 18.r),
          SizedBox(width: 8.w),
          Text('Difficulty', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        SizedBox(height: 12.h),
        Builder(
          builder: (context) {
            final difficultyLevel = cookTimeMinutes <= 20 ? 0 : cookTimeMinutes <= 45 ? 1 : 2;
            final difficultyLabels = ['Easy', 'Medium', 'Hard'];
            final difficultyColors = [AppColors.primary, AppColors.warning, AppColors.error];
            return Row(children: difficultyLabels.asMap().entries.map((e) {
              final active = e.key == difficultyLevel;
              return Expanded(child: Padding(
                padding: EdgeInsets.only(right: e.key < 2 ? 8.w : 0),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10.h),
                  decoration: BoxDecoration(
                    color: active ? difficultyColors[e.key] : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Center(child: Text(e.value,
                    style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700,
                      color: active ? AppColors.textWhite : AppColors.textMuted))),
                ),
              ));
            }).toList());
          }
        ),
      ],
    );
  }
}
