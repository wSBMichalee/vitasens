import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step14 extends StatelessWidget {
  final VoidCallback onNext;
  const Step14({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text("🍽️", style: TextStyle(fontSize: 80.sp)),
          SizedBox(height: 32.h),
          const Heading("What's in your kitchen?", textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          const Subtitle("Tell us what you usually have at home. We'll only suggest meals you can actually make.", textAlign: TextAlign.center),
          SizedBox(height: 40.h),
          _buildFeature("✅", "No shopping needed"),
          SizedBox(height: 12.h),
          _buildFeature("✅", "Zero food waste"),
          SizedBox(height: 12.h),
          _buildFeature("✅", "Cook what you have"),
          const Spacer(),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildFeature(String icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: 16.sp)),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF8A8A8E))),
      ],
    );
  }
}