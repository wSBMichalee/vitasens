import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step11 extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback? onNext;

  const Step11({super.key, required this.selected, required this.onToggle, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ("✅", "No restrictions"), ("🥦", "Vegetarian"), ("🌱", "Vegan"), ("🌾", "Gluten-free"),
      ("🥛", "Dairy-free"), ("🥩", "Keto"), ("☪️", "Halal"), ("🦴", "Paleo")
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("Any dietary preferences?"),
          SizedBox(height: 8.h),
          const Subtitle("Select all that apply"),
          SizedBox(height: 24.h),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.0,
              children: options.map((e) {
                final isSel = selected.contains(e.$2);
                return GestureDetector(
                  onTap: () => onToggle(e.$2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.$1, style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 8.h),
                        Text(
                          e.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList().animate(interval: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}