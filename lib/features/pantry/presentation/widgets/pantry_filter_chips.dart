import 'package:flutter/material.dart' hide FilterChip;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'pantry_filter_chip.dart';

class PantryFilterChips extends StatelessWidget {
  const PantryFilterChips({super.key, required this.selectedFilter, required this.onFilterSelected});
  final String selectedFilter;
  final ValueChanged<String> onFilterSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          FilterChip(
            label: 'ALL',
            isSelected: selectedFilter == 'all',
            onTap: () => onFilterSelected('all'),
          ),
          SizedBox(width: 8.w),
          FilterChip(
            label: 'EXPIRING 🔥',
            isSelected: selectedFilter == 'expiring',
            onTap: () => onFilterSelected('expiring'),
          ),
          SizedBox(width: 8.w),
          FilterChip(
            label: 'LOW STOCK',
            isSelected: selectedFilter == 'low_stock',
            onTap: () => onFilterSelected('low_stock'),
          ),
        ],
      ),
    );
  }
}
