import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step21 extends StatefulWidget {
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

  @override
  State<Step21> createState() => _Step21State();
}

class _Step21State extends State<Step21> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _calorieAnim;
  int _lastHapticProgress = -1;
  int _targetCalories = 0;

  @override
  void initState() {
    super.initState();
    _targetCalories = _calculateCalories();
    
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    
    _calorieAnim = IntTween(begin: 0, end: _targetCalories).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.addListener(() {
      int currentProgress = (_controller.value * 10).floor();
      if (currentProgress > _lastHapticProgress && currentProgress < 10) {
        HapticFeedback.selectionClick();
        _lastHapticProgress = currentProgress;
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.mediumImpact();
      }
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  int _calculateCalories() {
    double h = widget.heightUnit == 'cm' ? widget.heightCm.toDouble() : (widget.heightFt * 12 + widget.heightIn) * 2.54;
    double w = widget.weightUnit == 'kg' ? widget.weightKg.toDouble() : widget.weightLbs * 0.453592;
    double bmr = (10 * w) + (6.25 * h) - (5 * widget.age);
    if (widget.gender == 'Male') {
      bmr += 5;
    } else {
      bmr -= 161;
    }
    
    double m = 1.2;
    if (widget.activity == 'Lightly active') m = 1.375;
    if (widget.activity == 'Moderately active') m = 1.55;
    if (widget.activity == 'Very active') m = 1.725;

    double tdee = bmr * m;
    if (widget.goal == 'Lose weight') tdee -= 500;
    if (widget.goal == 'Gain muscle') tdee += 500;

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
                SummaryRow(label: "Goal", value: widget.goal ?? "-"),
                const Divider(color: Color(0xFFE5E5EA), height: 32, thickness: 1),
                SummaryRow(label: "Activity", value: widget.activity ?? "-"),
                const Divider(color: Color(0xFFE5E5EA), height: 32, thickness: 1),
                SummaryRow(label: "Dietary", value: widget.dietary.isEmpty ? "None" : widget.dietary.join(", ")),
                const Divider(color: Color(0xFFE5E5EA), height: 32, thickness: 1),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: Text("Daily Calories", style: TextStyle(fontSize: 15.sp, color: const Color(0xFF8A8A8E)))),
                    Expanded(
                      flex: 3, 
                      child: AnimatedBuilder(
                        animation: _calorieAnim,
                        builder: (context, child) {
                          return Text(
                            "${_calorieAnim.value} kcal", 
                            style: TextStyle(
                              fontSize: 18.sp, 
                              fontWeight: FontWeight.w800, 
                              color: AppColors.primary
                            ), 
                            textAlign: TextAlign.right
                          );
                        }
                      ),
                    ),
                  ],
                ),
              ].animate(interval: 150.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ),
          SizedBox(height: 16.h),
          Center(
            child: Text(
              "Meals are suggestions. Consult a doctor for medical decisions.", 
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8A8A8E)), 
              textAlign: TextAlign.center
            )
          ).animate(delay: 1500.ms).fadeIn(duration: 400.ms),
          const Spacer(),
          CtaButton(onPressed: widget.onNext, label: "See My Meal Plan")
            .animate(delay: 1800.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0, curve: Curves.easeOutQuad),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}