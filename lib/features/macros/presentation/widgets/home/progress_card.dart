import 'macro_column.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';


class ProgressCard extends StatelessWidget {
  const ProgressCard({super.key, 
    this.kcalConsumed = 1080,
    this.kcalGoal = 2500,
    this.proteinConsumed = 42,
    this.proteinGoal = 120,
    this.carbsConsumed = 110,
    this.carbsGoal = 180,
    this.fatConsumed = 35,
    this.fatGoal = 65,
  });

  final int kcalConsumed;
  final int kcalGoal;
  final int proteinConsumed;
  final int proteinGoal;
  final int carbsConsumed;
  final int carbsGoal;
  final int fatConsumed;
  final int fatGoal;

  @override
  Widget build(BuildContext context) {
    final double kcalProgress =
        (kcalConsumed / kcalGoal).clamp(0.0, 1.0);

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            blurRadius: 16,
            offset: const Offset(0, 6),
            color: Colors.black.withValues(alpha: 0.04),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── KALORIE — hierarchia priorytet 1 ──────────────────────────
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$kcalConsumed',
                    style: TextStyle(
                      fontSize: 48.sp,
                      height: 1.0,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'of $kcalGoal kcal goal',
                    style: TextStyle(
                      fontSize: 14.sp,
                      height: 1.5,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              // Mini kołowy wskaźnik kalorii
              SizedBox(
                width: 64.r,
                height: 64.r,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: kcalProgress,
                      strokeWidth: 7.r,
                      color: AppColors.primary,
                      backgroundColor: AppColors.borderLight,
                      strokeCap: StrokeCap.round,
                    ),
                    Text(
                      '${(kcalProgress * 100).round()}%',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // ── LINIA PODZIAŁU ──────────────────────────────────────────────
          const Divider(
            color: AppColors.borderLight,
            thickness: 1,
            height: 1,
          ),

          SizedBox(height: 24.h),

          // ── MAKRA — poziomy rząd 3 kolumn (bez overflow) ───────────────
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: MacroColumn(
                    label: 'PROTEIN',
                    consumed: proteinConsumed,
                    goal: proteinGoal,
                    color: AppColors.proteinColor,
                    isLow: proteinConsumed / proteinGoal < 0.5,
                  ),
                ),
                const VerticalDivider(
                  color: AppColors.borderLight,
                  thickness: 1,
                  width: 1,
                ),
                Expanded(
                  child: MacroColumn(
                    label: 'CARBS',
                    consumed: carbsConsumed,
                    goal: carbsGoal,
                    color: AppColors.carbsColor,
                  ),
                ),
                const VerticalDivider(
                  color: AppColors.borderLight,
                  thickness: 1,
                  width: 1,
                ),
                Expanded(
                  child: MacroColumn(
                    label: 'FAT',
                    consumed: fatConsumed,
                    goal: fatGoal,
                    color: AppColors.fatColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}