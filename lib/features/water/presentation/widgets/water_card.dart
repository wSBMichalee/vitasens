import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/water/bloc/water_bloc.dart';
import 'package:vitasense/features/water/bloc/water_event.dart';
import 'package:vitasense/features/water/bloc/water_state.dart';
import 'package:vitasense/core/utils/bottom_sheet_utils.dart';

class WaterCard extends StatelessWidget {
  const WaterCard({
    super.key, 
    this.dailyWaterTarget,
    this.isEditable = true,
    this.selectedDate,
  });
  
  final int? dailyWaterTarget;
  final bool isEditable;
  final DateTime? selectedDate;

  void _showAddWaterSheet(BuildContext context) {
    showAppBottomSheet(
      context: context,
      builder: (sheetContext) {
        return Container(
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 40.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Add Water',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 24.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _WaterOptionButton(amount: 150, blocContext: context, date: selectedDate),
                  _WaterOptionButton(amount: 250, blocContext: context, date: selectedDate),
                  _WaterOptionButton(amount: 500, blocContext: context, date: selectedDate),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WaterBloc, WaterState>(
      builder: (context, state) {
        int consumed = 0;
        int goal = dailyWaterTarget ?? 2500;
        
        if (state is WaterLoaded) {
          consumed = state.consumedMl;
        }

        final double progress = (consumed / goal).clamp(0.0, 1.0);

        return Container(
          padding: EdgeInsets.all(24.r),
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 44.r,
                    height: 44.r,
                    decoration: BoxDecoration(
                      color: AppColors.proteinColor.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.water_drop_rounded,
                      color: AppColors.proteinColor,
                      size: 24.r,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hydration',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '$consumed / $goal ml',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (isEditable)
                    IconButton(
                      onPressed: () => _showAddWaterSheet(context),
                      style: IconButton.styleFrom(
                        backgroundColor: AppColors.proteinColor.withValues(alpha: 0.1),
                        shape: const CircleBorder(),
                      ),
                      icon: Icon(Icons.add, color: AppColors.proteinColor, size: 24.r),
                    ),
                ],
              ),
              SizedBox(height: 16.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8.h,
                  color: AppColors.proteinColor,
                  backgroundColor: AppColors.borderLight,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _WaterOptionButton extends StatelessWidget {
  const _WaterOptionButton({
    required this.amount, 
    required this.blocContext,
    this.date,
  });

  final int amount;
  final BuildContext blocContext;
  final DateTime? date;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        child: FilledButton(
          onPressed: () {
            blocContext.read<WaterBloc>().add(AddWater(amount, date ?? DateTime.now()));
            Navigator.of(context).pop();
          },
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.proteinColor.withValues(alpha: 0.1),
            foregroundColor: AppColors.proteinColor,
            padding: EdgeInsets.symmetric(vertical: 16.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 0,
          ),
          child: Text(
            '${amount}ml',
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
