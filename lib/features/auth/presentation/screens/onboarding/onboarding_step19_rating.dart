import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step19 extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onNext;

  const Step19({super.key, required this.rating, required this.onRatingChanged, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text("⭐", style: TextStyle(fontSize: 72.sp)),
          SizedBox(height: 32.h),
          const Heading("Enjoying VitaSense?", textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          const Subtitle("Your rating helps us improve and reach more people.", textAlign: TextAlign.center),
          SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    Icons.star,
                    size: 48.r,
                    color: index < rating ? Colors.amber : const Color(0xFFE5E5EA),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          CtaButton(onPressed: rating > 0 ? onNext : null, label: "Submit Rating"),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: onNext,
            child: Text("Skip", style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8A8A8E))),
          )
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class Step19b extends StatelessWidget {
  final VoidCallback onNext;
  const Step19b({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          Text('4.8', style: TextStyle(fontSize: 72.sp, fontWeight: FontWeight.w800, color: Colors.black)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => Icon(Icons.star, color: Colors.amber, size: 32.r)),
          ),
          SizedBox(height: 8.h),
          Text('100K+ App Ratings', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          SizedBox(height: 32.h),
          const Heading("VitaSense was made\nfor people like you"),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              children: [
                ('Karol M.', 'Lost 8kg in 3 months. The AI suggestions are spot on!', 5),
                ('Zofia T.', 'Finally an app that understands my dietary needs.', 5),
                ('Piotr B.', 'The pantry feature alone is worth it. Zero food waste!', 5),
              ].map((r) => Padding(
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
              )).toList().animate(interval: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}