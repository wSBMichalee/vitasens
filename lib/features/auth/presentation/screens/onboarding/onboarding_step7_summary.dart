import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step7 extends StatelessWidget {
  final String? gender;
  final String heightUnit;
  final int heightCm;
  final int heightFt;
  final int heightIn;
  final String weightUnit;
  final int weightKg;
  final int weightLbs;
  final int age;
  final VoidCallback onNext;

  const Step7({super.key, 
    required this.gender, required this.heightUnit, required this.heightCm, required this.heightFt, required this.heightIn,
    required this.weightUnit, required this.weightKg, required this.weightLbs, required this.age, required this.onNext,
  });

  int _calculateBmr() {
    double h = heightUnit == 'cm' ? heightCm.toDouble() : (heightFt * 12 + heightIn) * 2.54;
    double w = weightUnit == 'kg' ? weightKg.toDouble() : weightLbs * 0.453592;
    double bmr = (10 * w) + (6.25 * h) - (5 * age);
    if (gender == 'Male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }
    return bmr.round();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 40.h),
                Text("${_calculateBmr()}", style: TextStyle(fontSize: 64.sp, fontWeight: FontWeight.w800, color: Colors.black, height: 1.0)),
                SizedBox(height: 4.h),
                Text("kcal / day", style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8A8A8E))),
                SizedBox(height: 24.h),
                const Heading("Based on your measurements,"),
                SizedBox(height: 8.h),
                const Subtitle("We'll fine-tune this with your goals next."),
                SizedBox(height: 24.h),
                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(16.r)),
                  child: Column(
                    children: [
                      _buildRow("Height", heightUnit == 'cm' ? "$heightCm cm" : "$heightFt ft $heightIn in"),
                      const Divider(color: Color(0xFFE5E5EA), height: 32, thickness: 1),
                      _buildRow("Weight", weightUnit == 'kg' ? "$weightKg kg" : "$weightLbs lbs"),
                      const Divider(color: Color(0xFFE5E5EA), height: 32, thickness: 1),
                      _buildRow("Age", "$age years"),
                    ],
                  ),
                ),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
          child: CtaButton(onPressed: onNext, label: "Let's continue"),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 15.sp, color: const Color(0xFF8A8A8E))),
        Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black)),
      ],
    );
  }
}