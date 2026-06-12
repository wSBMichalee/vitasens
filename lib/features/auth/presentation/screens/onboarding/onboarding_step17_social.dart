import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step17 extends StatelessWidget {
  final VoidCallback onNext;
  const Step17({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const Heading("You're in good company.", textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          const Subtitle("Join thousands already eating smarter.", textAlign: TextAlign.center),
          SizedBox(height: 40.h),
          Text("12,400+", style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.0)),
          SizedBox(height: 4.h),
          Text("people using VitaSense", style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8A8A8E))),
          SizedBox(height: 40.h),
          const ReviewCard(name: "Anna K.", text: "Finally an app that uses what I already have at home. Love it!"),
          SizedBox(height: 12.h),
          const ReviewCard(name: "Tomasz W.", text: "Lost 4kg in 6 weeks just by following the meal suggestions."),
          const Spacer(),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}