part of '../../screens/food_detected_screen.dart';

class _MacroCard extends StatelessWidget {
  final num calories;
  final num protein;
  final num carbs;
  final num fat;

  const _MacroCard({
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Calories
          Text(
            '${calories.toInt()}',
            style: TextStyle(
              fontSize: 48.sp,
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
              height: 1,
            ),
          ),
          Text(
            'kcal',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 20.h),
          // Macros row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _MacroItem(label: 'Protein', value: '${protein.toInt()}g', color: const Color(0xFF3B82F6)),
              _MacroDivider(),
              _MacroItem(label: 'Carbs', value: '${carbs.toInt()}g', color: const Color(0xFFF59E0B)),
              _MacroDivider(),
              _MacroItem(label: 'Fat', value: '${fat.toInt()}g', color: const Color(0xFFEF4444)),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MacroItem({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MacroDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36.h,
      width: 1,
      color: AppColors.borderLight,
    );
  }
}
