import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step16 extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const Step16({super.key, required this.selected, required this.onSelected, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ("Rarely", "mostly takeout or delivery"),
      ("A few times a week", "when I have time"),
      ("Almost daily", "I enjoy cooking"),
      ("I meal prep", "batch cooking on weekends"),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("How often do you cook?"),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              children: options.map((e) => OptionCard(title: e.$1, subtitle: e.$2, selected: selected == e.$1, onTap: () => onSelected(e.$1))).toList().animate(interval: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class Step16b extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onNext;
  const Step16b({super.key, required this.selected, required this.onSelected, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('🐢', 'Slow & steady', 'Sustainable, long-term results'),
      ('🚶', 'Moderate', 'Balanced pace, recommended'),
      ('🏃', 'Fast', 'Aggressive, requires discipline'),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("How fast do you want to reach your goal?"),
          SizedBox(height: 8.h),
          const Subtitle("We'll adjust your daily targets accordingly."),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              children: options.map((e) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: GestureDetector(
                  onTap: () => onSelected(e.$2),
                  child: Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: selected == e.$2 ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Text(e.$1, style: TextStyle(fontSize: 32.sp)),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.$2, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: selected == e.$2 ? Colors.white : Colors.black)),
                              Text(e.$3, style: TextStyle(fontSize: 13.sp, color: selected == e.$2 ? Colors.white70 : Colors.grey)),
                            ],
                          ),
                        ),
                        if (selected == e.$2)
                          Icon(Icons.check_circle, color: Colors.white, size: 20.r),
                      ],
                    ),
                  ),
                ),
              )).toList().animate(interval: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}