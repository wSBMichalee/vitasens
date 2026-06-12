import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step1 extends StatelessWidget {
  final VoidCallback onNext;
  const Step1({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("Your kitchen.\nYour meals."),
          SizedBox(height: 40.h),
          const InfoRow(icon: Icons.kitchen, title: "Cook what you have", subtitle: "No wasted groceries"),
          SizedBox(height: 24.h),
          const InfoRow(icon: Icons.favorite_border, title: "Eat for your goals", subtitle: "Every meal personalized"),
          SizedBox(height: 24.h),
          const InfoRow(icon: Icons.check_circle_outline, title: "Zero guesswork", subtitle: "Know exactly what to cook"),
          const Spacer(),
          CtaButton(onPressed: onNext, label: "Let's Start"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class Step2 extends StatelessWidget {
  final VoidCallback onNext;
  const Step2({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🗑️", style: TextStyle(fontSize: 72.sp)),
                  SizedBox(height: 24.h),
                  const Heading("67% of people waste food every week.", textAlign: TextAlign.center),
                  SizedBox(height: 12.h),
                  const Subtitle("VitaSense helps you cook what you have — nothing goes to waste.", textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
          child: CtaButton(onPressed: onNext, label: "That's me"),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}