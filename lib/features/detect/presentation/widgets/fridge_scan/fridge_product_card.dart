part of '../../screens/fridge_scan_result_screen.dart';

class FridgeProductCard extends StatelessWidget {
  final Map<String, dynamic> product;
  final bool isSelected;
  final bool isLast;
  final VoidCallback onToggle;

  const FridgeProductCard({
    super.key,
    required this.product,
    required this.isSelected,
    this.isLast = false,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final name = product['name']?.toString() ?? 'Unknown';
    final qty = (product['estimatedQuantity'] ?? 1) as num;
    final unit = product['unit']?.toString() ?? 'pcs';
    final expiryDays = (product['estimatedExpiryDays'] ?? 7) as num;
    final cal = (product['calories100g'] ?? 0) as num;

    return Column(
      children: [
        InkWell(
          onTap: onToggle,
          borderRadius: isLast
              ? BorderRadius.vertical(bottom: Radius.circular(16.r))
              : BorderRadius.zero,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
            child: Row(
              children: [
                // Checkbox
                AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  width: 22.r,
                  height: 22.r,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.border,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: isSelected
                      ? Icon(Icons.check_rounded,
                          size: 14.r, color: Colors.white)
                      : null,
                ),
                SizedBox(width: 12.w),

                // Name + details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Row(
                        children: [
                          Text(
                            '${qty.toStringAsFixed(qty == qty.toInt() ? 0 : 1)} $unit',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (expiryDays > 0) ...[
                            Text(
                              ' • ',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              '${expiryDays.toInt()}d to expiry',
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: expiryDays <= 3
                                    ? const Color(0xFFEF4444)
                                    : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Calorie chip
                if (cal > 0)
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      '${cal.toInt()} kcal',
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
            height: 1,
            indent: 48.w,
            color: AppColors.borderLight,
          ),
      ],
    );
  }
}
