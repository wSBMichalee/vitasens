import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';


class MacrosListCard extends StatelessWidget {
  const MacrosListCard({super.key, required this.daily});
  final Map<String, dynamic> daily;

  int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is double) return val.toInt();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final protein = daily['protein'] as Map<String, dynamic>? ?? {};
    final carbs = daily['carbs'] as Map<String, dynamic>? ?? {};
    final fat = daily['fat'] as Map<String, dynamic>? ?? {};

    return Container(
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
        children: [
          MacroRow(
            icon: Icons.shield_outlined,
            iconBg: AppColors.secondaryLight,
            iconColor: AppColors.proteinColor,
            label: 'Protein',
            actual: _toInt(protein['actual']),
            target: _toInt(protein['target']),
          ),
          Divider(
              color: AppColors.border,
              height: 1,
              thickness: 1,
              indent: 68.w,
              endIndent: 0),
          MacroRow(
            icon: Icons.eco_outlined,
            iconBg: AppColors.primaryLight,
            iconColor: AppColors.primary,
            label: 'Carbs',
            actual: _toInt(carbs['actual']),
            target: _toInt(carbs['target']),
          ),
          Divider(
              color: AppColors.border,
              height: 1,
              thickness: 1,
              indent: 68.w,
              endIndent: 0),
          MacroRow(
            icon: Icons.local_fire_department_outlined,
            iconBg: AppColors.warningLight,
            iconColor: AppColors.fatColor,
            label: 'Fat',
            actual: _toInt(fat['actual']),
            target: _toInt(fat['target']),
          ),
        ],
      ),
    );
  }
}

class MacroRow extends StatelessWidget {
  const MacroRow({super.key, 
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.actual,
    required this.target,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final int actual;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
        children: [
          Container(
            width: 40.r,
            height: 40.r,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, color: iconColor, size: 20.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '$actual/${target}g',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}