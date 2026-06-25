import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'category_grid_widget.dart';

class ManualEntryStep extends StatelessWidget {
  final VoidCallback onDisableManualEntry;
  final TextEditingController manualNameController;
  final ValueChanged<Map<String, String>> onManualSelect;

  const ManualEntryStep({
    super.key,
    required this.onDisableManualEntry,
    required this.manualNameController,
    required this.onManualSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onDisableManualEntry,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.arrow_back_ios, size: 14.r, color: AppColors.primary),
                SizedBox(width: 4.w),
                Text(
                  'Wróć do wyszukiwania',
                  style: TextStyle(fontSize: 14.sp, color: AppColors.primary, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'NAZWA PRODUKTU',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
          ),
          SizedBox(height: 8.h),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 10, offset: const Offset(0, 4)),
              ],
            ),
            child: TextField(
              controller: manualNameController,
              style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
              decoration: InputDecoration(
                hintText: 'np. Jogurt naturalny',
                hintStyle: TextStyle(fontSize: 15.sp, color: Colors.grey.shade400),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Text(
            'WYBIERZ KATEGORIĘ',
            style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade500, letterSpacing: 1.2),
          ),
          SizedBox(height: 12.h),
          CategoryGridWidget(
            onCategoryTap: (_) {},
            onManualSelect: onManualSelect,
          ),
        ],
      ),
    );
  }
}
