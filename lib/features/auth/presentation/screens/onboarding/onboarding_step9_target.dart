import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step9 extends StatelessWidget {
  final String? goal;
  final VoidCallback onNext;

  const Step9({super.key, required this.goal, required this.onNext});

  (String, String) _getContent() {
    switch (goal) {
      case 'Lose weight': return ("🔥", "Smart food choices burn more fat than any workout.");
      case 'Gain muscle': return ("💪", "Protein timing matters more than most people think.");
      case 'Eat healthier': return ("🥗", "80% of how you feel is what you eat.");
      case 'Boost energy': return ("⚡", "The right breakfast changes your entire day.");
      case 'Manage a condition': return ("🫀", "Food is medicine. Let's use it right.");
      default: return ("🌟", "Every great journey starts with a simple choice.");
    }
  }

  @override
  Widget build(BuildContext context) {
    final content = _getContent();
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text(content.$1, style: TextStyle(fontSize: 80.sp)),
          SizedBox(height: 32.h),
          Text(content.$2, textAlign: TextAlign.center, style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: -0.5)),
          SizedBox(height: 16.h),
          const Subtitle("VitaSense builds your plan around this.", textAlign: TextAlign.center),
          const Spacer(),
          CtaButton(onPressed: onNext, label: "Got it"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}