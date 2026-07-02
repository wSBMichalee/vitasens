part of '../../screens/shopping_list_screen.dart';

class ShoppingHistoryTab extends StatelessWidget {
  final List<ShoppingItemModel> history;

  const ShoppingHistoryTab({
    super.key,
    required this.history,
  });

  String _monthName(int month) {
    const months = ['sty', 'lut', 'mar', 'kwi', 'maj', 'cze', 'lip', 'sie', 'wrz', 'paź', 'lis', 'gru'];
    return months[month - 1];
  }

  Map<String, List<ShoppingItemModel>> _groupByDate(List<ShoppingItemModel> items) {
    final groups = <String, List<ShoppingItemModel>>{};
    for (final item in items) {
      final date = item.purchasedAt ?? item.createdAt ?? DateTime.now();
      String label;
      final now = DateTime.now();
      if (date.year == now.year && date.month == now.month && date.day == now.day) {
        label = 'Today';
      } else if (date.year == now.year && date.month == now.month && date.day == now.day - 1) {
        label = 'Yesterday';
      } else {
        label = '${date.day} ${_monthName(date.month)} ${date.year}';
      }
      groups.putIfAbsent(label, () => []).add(item);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64.r, color: AppColors.border),
            SizedBox(height: 16.h),
            Text(
              'No purchase history yet',
              style: TextStyle(fontSize: 16.sp, color: AppColors.textSecondary),
            ),
          ],
        ),
      );
    }

    final groups = _groupByDate(history);
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h).copyWith(bottom: 80.h),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final dateLabel = groups.keys.elementAt(index);
        final items = groups[dateLabel]!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
              child: Text(
                '$dateLabel • ${items.length} produktów',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            ...items.map((item) => Container(
              margin: EdgeInsets.only(bottom: 8.h),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.borderLight),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textPrimary.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 40.r,
                    height: 40.r,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Center(
                      child: Text(
                        getCategoryEmoji(item.name, item.category),
                        style: TextStyle(fontSize: 20.sp),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          '${item.quantity.toStringAsFixed(item.quantity.truncateToDouble() == item.quantity ? 0 : 1)} ${item.unit}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.check_circle, color: AppColors.primary, size: 20.r),
                      SizedBox(height: 4.h),
                      Text(
                        'kupiono',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: AppColors.textMuted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        );
      },
    );
  }
}
