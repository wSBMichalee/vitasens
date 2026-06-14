import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/features/browse/bloc/browse_bloc.dart';
import 'package:vitasense/features/browse/bloc/browse_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';


class SortChip extends StatelessWidget {
  final String label;
  final String value;
  final String currentSort;

  const SortChip({super.key, required this.label, required this.value, required this.currentSort});

  @override
  Widget build(BuildContext context) {
    final isSelected = currentSort == value;
    return GestureDetector(
      onTap: () => context.read<BrowseBloc>().add(ChangeSortBy(value)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryLight : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}