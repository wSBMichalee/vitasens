import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step21 extends StatelessWidget {
  final String? gender;
  final String heightUnit;
  final int heightCm;
  final int heightFt;
  final int heightIn;
  final String weightUnit;
  final int weightKg;
  final int weightLbs;
  final int age;
  final String? goal;
  final String? activity;
  final List<String> dietary;
  final VoidCallback onNext;

  const Step21({super.key, 
    required this.gender, required this.heightUnit, required this.heightCm, required this.heightFt, required this.heightIn,
    required this.weightUnit, required this.weightKg, required this.weightLbs, required this.age,
    required this.goal, required this.activity, required this.dietary, required this.onNext,
  });

  int _calculateCalories() {
    double h = heightUnit == 'cm' ? heightCm.toDouble() : (heightFt * 12 + heightIn) * 2.54;
    double w = weightUnit == 'kg' ? weightKg.toDouble() : weightLbs * 0.453592;
    double bmr = (10 * w) + (6.25 * h) - (5 * age);
    if (gender == 'Male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }
    
    double m = 1.2;
    if (activity == 'Lightly active') m = 1.375;
    if (activity == 'Moderately active') m = 1.55;
    if (activity == 'Very active') m = 1.725;

    double tdee = bmr * m;
    if (goal == 'Lose weight') tdee -= 500;
    if (goal == 'Gain muscle') tdee += 500;

    return tdee.round();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("Here's your plan."),
          SizedBox(height: 32.h),
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(16.r)),
            child: Column(
              children: [
                SummaryRow(label: "Goal", value: goal ?? "-"),
                const Divider(color: Color(0xFFE5E5EA), height: 32, thickness: 1),
                SummaryRow(label: "Activity", value: activity ?? "-"),
                const Divider(color: Color(0xFFE5E5EA), height: 32, thickness: 1),
                SummaryRow(label: "Dietary", value: dietary.isEmpty ? "None" : dietary.join(", ")),
                const Divider(color: Color(0xFFE5E5EA), height: 32, thickness: 1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Text("Daily Calories", style: TextStyle(fontSize: 15.sp, color: const Color(0xFF8A8A8E)))),
                    Expanded(flex: 3, child: Text("${_calculateCalories()} kcal", style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w800, color: AppColors.primary), textAlign: TextAlign.right)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Center(child: Text("Meals are suggestions. Consult a doctor for medical decisions.", style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8A8A8E)), textAlign: TextAlign.center)),
          const Spacer(),
          CtaButton(onPressed: onNext, label: "See My Meal Plan"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}