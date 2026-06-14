import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class SubstitutesSection extends StatelessWidget {
  final List<String> missingNames;

  const SubstitutesSection({super.key, required this.missingNames});

  static const _substitutes = <String, List<String>>{
    'butter': ['margarine', 'coconut oil', 'applesauce'],
    'milk': ['almond milk', 'oat milk', 'soy milk'],
    'eggs': ['flax eggs', 'chia eggs', 'applesauce'],
    'flour': ['almond flour', 'oat flour', 'rice flour'],
    'sugar': ['honey', 'maple syrup', 'stevia'],
  };

  @override
  Widget build(BuildContext context) {
    final matchedSubstitutes = <String, List<String>>{};
    for (final missing in missingNames) {
      for (final entry in _substitutes.entries) {
        if (missing.contains(entry.key)) {
          matchedSubstitutes[entry.key] = entry.value;
        }
      }
    }

    if (matchedSubstitutes.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'MISSING INGREDIENTS',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.warning,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Common substitutes:',
            style: TextStyle(
              fontSize: 12.sp,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 10.h),
          ...matchedSubstitutes.entries.map((entry) {
            return Padding(
              padding: EdgeInsets.only(bottom: 8.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: entry.value.map((sub) {
                      return Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 8.w, vertical: 4.h),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          border: Border.all(
                              color: AppColors.warning.withValues(alpha: 0.4)),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          sub,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

