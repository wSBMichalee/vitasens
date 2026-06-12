import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step3 extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const Step3({super.key, required this.selected, required this.onSelected, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("Tell us about you"),
          SizedBox(height: 40.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelected('Male'),
                  child: Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: selected == 'Male' ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("👨", style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 16.h),
                        Text("Male", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: selected == 'Male' ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelected('Female'),
                  child: Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: selected == 'Female' ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("👩", style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 16.h),
                        Text("Female", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: selected == 'Female' ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}