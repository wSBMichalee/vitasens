import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/pantry/data/models/ingredient_model.dart';
import 'pantry_expiry_item.dart';

class PantryExpiryBanner extends StatelessWidget {
  const PantryExpiryBanner({super.key, required this.expiring});
  final List<IngredientModel> expiring;

  @override
  Widget build(BuildContext context) {
    
    final others = expiring.length - 1;
    final subtitle = others > 0
        ? '${expiring.first.name} and $others other${others > 1 ? 's' : ''} expire soon'
        : '${expiring.first.name} expires soon';

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.warningLight,
        border: Border.all(color: AppColors.warningBorder),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28.r,
                height: 28.r,
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child:
                    Icon(Icons.schedule, color: AppColors.textWhite, size: 14.r),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use before they go bad',
                      style: TextStyle(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                          fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              for (int i = 0; i < expiring.take(2).length; i++) ...[
                if (i > 0) SizedBox(width: 8.w),
                Expanded(child: ExpiryItem(ingredient: expiring[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
