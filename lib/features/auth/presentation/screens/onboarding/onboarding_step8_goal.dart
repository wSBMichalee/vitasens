import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step8 extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const Step8({super.key, required this.selected, required this.onSelected, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ("Lose weight", "Burn fat and get leaner", Icons.trending_down),
      ("Gain muscle", "Build strength and volume", Icons.fitness_center),
      ("Eat healthier", "Focus on nutrition and balance", Icons.restaurant_menu),
      ("Boost energy", "Feel active all day", Icons.bolt),
      ("Manage a condition", "Tailored to your health needs", Icons.health_and_safety),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("What's your goal?"),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              children: options.map((e) => OptionCard(title: e.$1, subtitle: e.$2, icon: e.$3, selected: selected == e.$1, onTap: () => onSelected(e.$1))).toList().animate(interval: 60.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0, curve: Curves.easeOutQuad),
            ),
          ),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class Step8b extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const Step8b({super.key, required this.selected, required this.onSelected, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      (Icons.repeat, "Lack of consistency", "I start but never stick to it"),
      (Icons.fastfood, "Unhealthy eating habits", "I struggle to eat well"),
      (Icons.schedule, "Busy schedule", "No time to plan meals"),
      (Icons.emoji_food_beverage, "Lack of meal inspiration", "I don't know what to cook"),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("What's stopping you from reaching your goals?"),
          SizedBox(height: 8.h),
          const Subtitle("We'll help you overcome it."),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              children: options.map((e) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: GestureDetector(
                  onTap: () => onSelected(e.$2),
                  child: Container(
                    padding: EdgeInsets.all(16.r),
                    decoration: BoxDecoration(
                      color: selected == e.$2 ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Icon(e.$1, color: selected == e.$2 ? Colors.white : Colors.black, size: 24.r),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.$2, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: selected == e.$2 ? Colors.white : Colors.black)),
                              SizedBox(height: 2.h),
                              Text(e.$3, style: TextStyle(fontSize: 13.sp, color: selected == e.$2 ? Colors.white70 : Colors.grey)),
                            ],
                          ),
                        ),
                        if (selected == e.$2)
                          Icon(Icons.check_circle, color: Colors.white, size: 20.r),
                      ],
                    ),
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