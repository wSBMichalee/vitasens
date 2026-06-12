import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step20 extends StatefulWidget {
  final VoidCallback onNext;
  const Step20({super.key, required this.onNext});

  @override
  State<Step20> createState() => Step20State();
}

class Step20State extends State<Step20> with SingleTickerProviderStateMixin {
  late AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) widget.onNext();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          ScaleTransition(
            scale: Tween<double>(begin: 0.95, end: 1.05).animate(_animController),
            child: Text("⚡", style: TextStyle(fontSize: 64.sp)),
          ),
          SizedBox(height: 32.h),
          const Heading("Setting up your plan...", textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          const Subtitle("Customizing your meal suggestions.", textAlign: TextAlign.center),
          SizedBox(height: 32.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.w),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: SizedBox(
                height: 6.h,
                child: const LinearProgressIndicator(color: AppColors.primary, backgroundColor: Color(0xFFE5E5EA)),
              ),
            ),
          ),
          SizedBox(height: 32.h),
          const AnimatedListItem(text: "✓ Calculating your calories", delay: 600),
          const AnimatedListItem(text: "✓ Matching your preferences", delay: 1200),
          const AnimatedListItem(text: "✓ Filtering allergens", delay: 1800),
          const AnimatedListItem(text: "✓ Building your meal plan", delay: 2400),
          const Spacer(),
        ],
      ),
    );
  }
}

class Step20b extends StatefulWidget {
  final VoidCallback onNext;
  const Step20b({super.key, required this.onNext});

  @override
  State<Step20b> createState() => Step20bState();
}

class Step20bState extends State<Step20b> {
  double _progress = 0.0;
  int _currentItem = 0;
  Timer? _timer;

  final List<String> _items = [
    "Calculating your daily calories...",
    "Analysing your dietary preferences...",
    "Matching recipes to your pantry...",
    "Preparing your hydration plan...",
    "Personalising your meal schedule...",
    "Your plan is ready! 🎉",
  ];

  @override
  void initState() {
    super.initState();
    _startProgress();
  }

  void _startProgress() {
    _timer = Timer.periodic(const Duration(milliseconds: 600), (timer) {
      if (_progress >= 1.0) {
        timer.cancel();
        Future.delayed(const Duration(milliseconds: 800), widget.onNext);
      } else {
        setState(() {
          _progress += 0.175;
          if (_progress > 1.0) _progress = 1.0;
          _currentItem = (_progress * (_items.length - 1)).round().clamp(0, _items.length - 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_progress * 100).round();
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 48.h, 24.w, 48.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("$percent%", style: TextStyle(fontSize: 72.sp, fontWeight: FontWeight.w800, color: AppColors.primary)),
          SizedBox(height: 8.h),
          Text("We're setting everything up for you", textAlign: TextAlign.center, style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600, color: Colors.black)),
          SizedBox(height: 48.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 8.h,
              backgroundColor: const Color(0xFFF2F2F7),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          SizedBox(height: 32.h),
          Container(
            padding: EdgeInsets.all(16.r),
            decoration: BoxDecoration(
              color: const Color(0xFFF2F2F7),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Daily recommendation for", style: TextStyle(fontSize: 12.sp, color: Colors.grey, fontWeight: FontWeight.w500)),
                SizedBox(height: 8.h),
                ...["Calories", "Carbs", "Protein", "Fats", "Hydration"].map((e) => Padding(
                  padding: EdgeInsets.only(bottom: 4.h),
                  child: Row(
                    children: [
                      Icon(Icons.circle, size: 6.r, color: AppColors.primary),
                      SizedBox(width: 8.w),
                      Text(e, style: TextStyle(fontSize: 14.sp, color: Colors.black87)),
                    ],
                  ),
                )),
              ],
            ),
          ),
          SizedBox(height: 24.h),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Text(
              _items[_currentItem],
              key: ValueKey(_currentItem),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey[600], fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}