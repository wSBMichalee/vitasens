import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step10 extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const Step10({super.key, required this.selected, required this.onSelected, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ("Sedentary", "desk job, mostly sitting"),
      ("Lightly active", "walks, light exercise 1–2 days"),
      ("Moderately active", "gym 3–5 days/week"),
      ("Very active", "daily intense training"),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("How active are you?"),
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

class Step10b extends StatefulWidget {
  final double waterLiters;
  final ValueChanged<double> onWaterChanged;
  final VoidCallback onNext;
  final double? weightKg;
  final String? activity;

  const Step10b({super.key, 
    required this.waterLiters,
    required this.onWaterChanged,
    required this.onNext,
    this.weightKg,
    this.activity,
  });

  @override
  State<Step10b> createState() => Step10bState();
}

class Step10bState extends State<Step10b> {
  double _recommended() {
    double base = (widget.weightKg ?? 70) * 0.033;
    if (widget.activity == 'Moderately active') base += 0.3;
    if (widget.activity == 'Very active') base += 0.6;
    return double.parse(base.toStringAsFixed(1));
  }

  @override
  Widget build(BuildContext context) {
    final rec = _recommended();
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("How much water do you drink daily?"),
          SizedBox(height: 8.h),
          Subtitle("Based on your weight and activity, we recommend ${rec}L per day."),
          SizedBox(height: 48.h),
          Center(
            child: Text(
              "${widget.waterLiters.toStringAsFixed(1)}L",
              style: TextStyle(fontSize: 64.sp, fontWeight: FontWeight.w800, color: AppColors.primary),
            ),
          ),
          SizedBox(height: 24.h),
          Slider(
            value: widget.waterLiters,
            min: 0.5,
            max: 3.5,
            divisions: 12,
            activeColor: AppColors.primary,
            inactiveColor: const Color(0xFFF2F2F7),
            onChanged: widget.onWaterChanged,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("0.5L", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
              Text("3.5L", style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.water_drop, color: AppColors.primary, size: 24.r),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    widget.waterLiters >= rec
                        ? "Great! You're hitting your hydration goal 💪"
                        : "Your recommended intake is ${rec}L. Try to increase gradually.",
                    style: TextStyle(fontSize: 14.sp, color: AppColors.primary, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          CtaButton(onPressed: widget.onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}