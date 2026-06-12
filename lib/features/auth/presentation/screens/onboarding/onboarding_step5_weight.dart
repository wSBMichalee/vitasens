import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step5 extends StatelessWidget {
  final String unit;
  final int weightKg;
  final int weightLbs;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<int> onKgChanged;
  final ValueChanged<int> onLbsChanged;
  final VoidCallback onNext;

  const Step5({super.key, 
    required this.unit,
    required this.weightKg,
    required this.weightLbs,
    required this.onUnitChanged,
    required this.onKgChanged,
    required this.onLbsChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("How much do you weigh?"),
          SizedBox(height: 8.h),
          const Subtitle("This helps us calculate your daily calorie needs."),
          SizedBox(height: 32.h),
          Row(
            children: [
              UnitTab(title: "kg", isSelected: unit == 'kg', onTap: () => onUnitChanged('kg')),
              SizedBox(width: 16.w),
              UnitTab(title: "lbs", isSelected: unit == 'lbs', onTap: () => onUnitChanged('lbs')),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            height: 200.h,
            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(14.r)),
            child: unit == 'kg'
                ? CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: weightKg - 40),
                    itemExtent: 40.h,
                    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: const Color(0xFFE5E5EA).withValues(alpha: 0.5)),
                    onSelectedItemChanged: (i) => onKgChanged(i + 40),
                    children: List.generate(161, (i) => Center(child: Text("${i + 40}", style: TextStyle(fontSize: 22.sp, color: Colors.black, fontWeight: FontWeight.w600)))),
                  )
                : CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: weightLbs - 88),
                    itemExtent: 40.h,
                    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: const Color(0xFFE5E5EA).withValues(alpha: 0.5)),
                    onSelectedItemChanged: (i) => onLbsChanged(i + 88),
                    children: List.generate(353, (i) => Center(child: Text("${i + 88}", style: TextStyle(fontSize: 22.sp, color: Colors.black, fontWeight: FontWeight.w600)))),
                  ),
          ),
          const Spacer(),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}