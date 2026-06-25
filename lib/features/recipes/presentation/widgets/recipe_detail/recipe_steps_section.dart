import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class RecipeStepsSection extends StatelessWidget {
  final List<Map<String, dynamic>> steps;

  const RecipeStepsSection({super.key, required this.steps});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(Icons.menu_book_outlined, color: AppColors.primary, size: 18.r),
          SizedBox(width: 8.w),
          Text('How to prepare', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
        ]),
        SizedBox(height: 16.h),
        if (steps.isEmpty)
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(color: AppColors.borderLight, borderRadius: BorderRadius.circular(12.r)),
            child: Row(children: [
              Icon(Icons.info_outline, color: AppColors.textMuted, size: 20.r),
              SizedBox(width: 12.w),
              Expanded(child: Text('Step-by-step instructions not available yet. Try cooking this recipe after re-syncing.',
                style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.5))),
            ]),
          )
        else
          ...steps.asMap().entries.map((entry) {
            final stepText = entry.value['step']?.toString() ?? '';
            final stepNum = entry.value['number'] ?? (entry.key + 1);
            return Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 32.r, height: 32.r,
                  decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                  child: Center(child: Text('$stepNum',
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textWhite))),
                ),
                SizedBox(width: 12.w),
                Expanded(child: Padding(
                  padding: EdgeInsets.only(top: 6.h),
                  child: Text(stepText, style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary, height: 1.6)),
                )),
              ]),
            );
          }),
      ],
    );
  }
}
