import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step6 extends StatelessWidget {
  final int age;
  final ValueChanged<int> onAgeChanged;
  final VoidCallback onNext;

  const Step6({super.key, required this.age, required this.onAgeChanged, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("How old are you?"),
          SizedBox(height: 8.h),
          const Subtitle("Age affects your metabolism and calorie needs."),
          SizedBox(height: 32.h),
          Container(
            height: 200.h,
            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(14.r)),
            child: CupertinoPicker(
              scrollController: FixedExtentScrollController(initialItem: age - 16),
              itemExtent: 40.h,
              selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: const Color(0xFFE5E5EA).withValues(alpha: 0.5)),
              onSelectedItemChanged: (i) => onAgeChanged(i + 16),
              children: List.generate(65, (i) => Center(child: Text("${i + 16}", style: TextStyle(fontSize: 22.sp, color: Colors.black, fontWeight: FontWeight.w600)))),
            ),
          ),
          const Spacer(),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}