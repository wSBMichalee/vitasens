part of '../../screens/food_detected_screen.dart';

class _HeaderSection extends StatelessWidget {
  final String foodName;
  final String confidenceIcon;
  final Color confidenceColor;
  final String confidenceLabel;
  final String cuisineType;
  final String mealType;

  const _HeaderSection({
    required this.foodName,
    required this.confidenceIcon,
    required this.confidenceColor,
    required this.confidenceLabel,
    required this.cuisineType,
    required this.mealType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20.w, 60.h, 20.w, 24.h),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Check icon
          Container(
            width: 44.r,
            height: 44.r,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, color: Colors.white, size: 26.r),
          ),
          SizedBox(height: 14.h),

          // Food name
          Text(
            foodName,
            style: TextStyle(
              fontSize: 26.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1.2,
            ),
          ),
          SizedBox(height: 10.h),

          // Confidence badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Text(
              '$confidenceIcon $confidenceLabel',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
          SizedBox(height: 12.h),

          // Tags row: cuisine + meal type
          Row(
            children: [
              if (cuisineType.isNotEmpty) _HeaderTag(label: cuisineType),
              if (cuisineType.isNotEmpty && mealType.isNotEmpty) SizedBox(width: 8.w),
              if (mealType.isNotEmpty) _HeaderTag(label: mealType),
            ],
          ),
        ],
      ),
    );
  }
}

class _HeaderTag extends StatelessWidget {
  final String label;
  const _HeaderTag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: Colors.white.withValues(alpha: 0.9),
        ),
      ),
    );
  }
}
