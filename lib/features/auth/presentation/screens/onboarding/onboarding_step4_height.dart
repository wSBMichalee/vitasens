import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/features/auth/presentation/screens/onboarding/onboarding_shared_widgets.dart';

class Step4 extends StatelessWidget {
  final String unit;
  final int heightCm;
  final int heightFt;
  final int heightIn;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<int> onCmChanged;
  final ValueChanged<int> onFtChanged;
  final ValueChanged<int> onInChanged;
  final VoidCallback onNext;

  const Step4({super.key, 
    required this.unit,
    required this.heightCm,
    required this.heightFt,
    required this.heightIn,
    required this.onUnitChanged,
    required this.onCmChanged,
    required this.onFtChanged,
    required this.onInChanged,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Heading("How tall are you?"),
          SizedBox(height: 8.h),
          const Subtitle("This helps us calculate your daily calorie needs."),
          SizedBox(height: 32.h),
          Row(
            children: [
              UnitTab(title: "cm", isSelected: unit == 'cm', onTap: () => onUnitChanged('cm')),
              SizedBox(width: 16.w),
              UnitTab(title: "ft/in", isSelected: unit == 'ft', onTap: () => onUnitChanged('ft')),
            ],
          ),
          SizedBox(height: 24.h),
          Container(
            height: 200.h,
            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(14.r)),
            child: unit == 'cm'
                ? CupertinoPicker(
                    scrollController: FixedExtentScrollController(initialItem: heightCm - 140),
                    itemExtent: 40.h,
                    selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: const Color(0xFFE5E5EA).withValues(alpha: 0.5)),
                    onSelectedItemChanged: (i) => onCmChanged(i + 140),
                    children: List.generate(81, (i) => Center(child: Text("${i + 140}", style: TextStyle(fontSize: 22.sp, color: Colors.black, fontWeight: FontWeight.w600)))),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: heightFt - 4),
                          itemExtent: 40.h,
                          selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: const Color(0xFFE5E5EA).withValues(alpha: 0.5)),
                          onSelectedItemChanged: (i) => onFtChanged(i + 4),
                          children: List.generate(4, (i) => Center(child: Text("${i + 4} ft", style: TextStyle(fontSize: 22.sp, color: Colors.black, fontWeight: FontWeight.w600)))),
                        ),
                      ),
                      Expanded(
                        child: CupertinoPicker(
                          scrollController: FixedExtentScrollController(initialItem: heightIn),
                          itemExtent: 40.h,
                          selectionOverlay: CupertinoPickerDefaultSelectionOverlay(background: const Color(0xFFE5E5EA).withValues(alpha: 0.5)),
                          onSelectedItemChanged: (i) => onInChanged(i),
                          children: List.generate(12, (i) => Center(child: Text("$i in", style: TextStyle(fontSize: 22.sp, color: Colors.black, fontWeight: FontWeight.w600)))),
                        ),
                      ),
                    ],
                  ),
          ),
          const Spacer(),
          CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}