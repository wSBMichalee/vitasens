import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class PantryStorageTabs extends StatelessWidget {
  const PantryStorageTabs({super.key, required this.selected, required this.onSelected});
  final String selected; // 'fridge' | 'freezer' | 'pantry'
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4.r),
      decoration: BoxDecoration(
        color: AppColors.borderLight,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        children: [
          Expanded(child: _tab(context, 'fridge', Icons.kitchen_outlined, 'Lodówka')),
          SizedBox(width: 4.w),
          Expanded(child: _tab(context, 'freezer', Icons.ac_unit_outlined, 'Zamrażarka')),
          SizedBox(width: 4.w),
          Expanded(child: _tab(context, 'pantry', Icons.inventory_2_outlined, 'Spiżarnia')),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, String value, IconData icon, String label) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.backgroundWhite : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: isSelected ? [
            BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2)),
          ] : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 18.r, color: isSelected ? AppColors.primary : AppColors.textMuted),
            SizedBox(width: 6.w),
            Text(label, style: TextStyle(
              fontSize: 14.sp,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
              color: isSelected ? AppColors.textPrimary : AppColors.textMuted,
            )),
          ],
        ),
      ),
    );
  }
}
