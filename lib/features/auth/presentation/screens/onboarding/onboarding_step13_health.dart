import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step13 extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback? onNext;

  const Step13({super.key, required this.selected, required this.onToggle, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ("✋", "None"), ("💉", "Diabetes"), ("❤️", "Hypertension"), ("⚠️", "High cholesterol"),
      ("🫁", "IBS"), ("🩹", "Post-surgery recovery"), ("🫀", "Heart disease"), ("➕", "Other")
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("Any health conditions?"),
          SizedBox(height: 8.h),
          const Subtitle("This helps us tailor your meals safely."),
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
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            e.$2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class Step13b extends StatelessWidget {
  final VoidCallback onNext;
  const Step13b({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      ("Marta K.", "Lost 6kg in 2 months! VitaSense finally made me understand what I'm eating.", 5),
      ("Tomasz W.", "The pantry matching feature is genius. No more food waste.", 5),
      ("Ania S.", "I love the AI meal suggestions. My diet has never been this varied.", 4),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text("50,000+", style: TextStyle(fontSize: 56.sp, fontWeight: FontWeight.w800, color: AppColors.primary)),
                Text("people already reach their goals with VitaSense", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          const Heading("What our users say"),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView(
              children: reviews.map((r) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 18.r, backgroundColor: AppColors.primary, child: Text(r.$1[0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp))),
                          SizedBox(width: 10.w),
                          Text(r.$1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                          const Spacer(),
                          Row(children: List.generate(r.$3, (_) => Icon(Icons.star, color: Colors.amber, size: 14.r))),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(r.$2, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}