import 'dart:async';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_event.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final PageController _pageController = PageController();

  int _currentStep = 0;
  bool _isLoading = false;

  String? _gender;
  String _heightUnit = 'cm';
  int _heightCm = 175;
  int _heightFt = 5;
  int _heightIn = 9;

  String _weightUnit = 'kg';
  int _weightKg = 70;
  int _weightLbs = 154;

  int _age = 25;
  String? _goal;
  String? _blocker;
  String? _activity;
  double _waterLiters = 2.0;
  final List<String> _dietary = [];
  final List<String> _allergies = [];
  final List<String> _healthConditions = [];
  final List<String> _kitchenStaples = [];
  String? _cookingFrequency;
  int _rating = 0;
  String _pace = 'Moderate';

  static const int _totalPages = 28;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalPages - 1) {
      _pageController.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep++);
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      if (_currentStep == 24) {
        _pageController.animateToPage(
          21,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
        setState(() => _currentStep = 21);
        return;
      }
      if (_currentStep == 26) {
        return; // od planu w dol nie wracamy do ladowania
      }

      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep--);
    } else {
      if (context.canPop()) {
        context.pop();
      } else {
        context.go('/landing');
      }
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);

    int finalHeightCm = _heightUnit == 'cm' ? _heightCm : ((_heightFt * 12 + _heightIn) * 2.54).round();
    int finalWeightKg = _weightUnit == 'kg' ? _weightKg : (_weightLbs * 0.453592).round();

    final data = {
      'gender': _gender,
      'height_cm': finalHeightCm,
      'weight_kg': finalWeightKg,
      'age': _age,
      'goal': _goal,
      'activity_level': _activity,
      'dietary_preferences': _dietary,
      'allergies': _allergies,
      'health_conditions': _healthConditions,
      'kitchen_staples': _kitchenStaples,
      'cooking_frequency': _cookingFrequency,
      'goal_pace': _pace,
      'daily_water_target': (_waterLiters * 1000).round(),
    };

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('onboarding_data', jsonEncode(data));

      context.read<AuthBloc>().add(OnboardingCompleted(onboardingData: data));
      await Future.delayed(const Duration(seconds: 2));

      if (mounted) context.go(AppRoutes.home);
    } catch (e) {
      debugPrint("Error saving onboarding data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Something went wrong. Please try again.'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool hideTopBar = _currentStep == 24 || _currentStep == 25 || _currentStep == 27; 

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            if (!hideTopBar)
              Padding(
                padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: _previousStep,
                      child: Container(
                        width: 36.r,
                        height: 36.r,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2F2F7),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Center(
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            color: Colors.black,
                            size: 16.r,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Container(
                        height: 2.h,
                        color: const Color(0xFFE5E5EA),
                        alignment: Alignment.centerLeft,
                        child: TweenAnimationBuilder<double>(
                          tween: Tween(
                            begin: 0,
                            end: (_currentStep + 1) / _totalPages,
                          ),
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          builder: (context, value, child) {
                            return FractionallySizedBox(
                              widthFactor: value,
                              child: Container(
                                color: AppColors.primary,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step1(onNext: _nextStep),
                  _Step2(onNext: _nextStep),
                  _Step3(selected: _gender, onSelected: (v) => setState(() => _gender = v), onNext: _gender != null ? _nextStep : null),
                  _Step4(unit: _heightUnit, heightCm: _heightCm, heightFt: _heightFt, heightIn: _heightIn, onUnitChanged: (v) => setState(() => _heightUnit = v), onCmChanged: (v) => setState(() => _heightCm = v), onFtChanged: (v) => setState(() => _heightFt = v), onInChanged: (v) => setState(() => _heightIn = v), onNext: _nextStep),
                  _Step5(unit: _weightUnit, weightKg: _weightKg, weightLbs: _weightLbs, onUnitChanged: (v) => setState(() => _weightUnit = v), onKgChanged: (v) => setState(() => _weightKg = v), onLbsChanged: (v) => setState(() => _weightLbs = v), onNext: _nextStep),
                  _Step6(age: _age, onAgeChanged: (v) => setState(() => _age = v), onNext: _nextStep),
                  _Step7(gender: _gender, heightUnit: _heightUnit, heightCm: _heightCm, heightFt: _heightFt, heightIn: _heightIn, weightUnit: _weightUnit, weightKg: _weightKg, weightLbs: _weightLbs, age: _age, onNext: _nextStep),
                  _Step8(selected: _goal, onSelected: (v) => setState(() => _goal = v), onNext: _goal != null ? _nextStep : null),
                  _Step8b(
                    selected: _blocker,
                    onSelected: (v) => setState(() => _blocker = v),
                    onNext: _blocker != null ? _nextStep : null,
                  ),
                  _Step9(goal: _goal, onNext: _nextStep),
                  _Step10(selected: _activity, onSelected: (v) => setState(() => _activity = v), onNext: _activity != null ? _nextStep : null),
                  _Step10b(
                    waterLiters: _waterLiters,
                    onWaterChanged: (v) => setState(() => _waterLiters = v),
                    onNext: _nextStep,
                    weightKg: _weightKg.toDouble(),
                    activity: _activity,
                  ),
                  _Step11(selected: _dietary, onToggle: (v) { setState(() { if (v == 'No restrictions') { _dietary.clear(); _dietary.add(v); } else { _dietary.remove('No restrictions'); _dietary.contains(v) ? _dietary.remove(v) : _dietary.add(v); } }); }, onNext: _dietary.isNotEmpty ? _nextStep : null),
                  _Step12(selected: _allergies, onToggle: (v) { setState(() { if (v == 'None') { _allergies.clear(); _allergies.add(v); } else { _allergies.remove('None'); _allergies.contains(v) ? _allergies.remove(v) : _allergies.add(v); } }); }, onNext: _nextStep),
                  _Step13(selected: _healthConditions, onToggle: (v) { setState(() { if (v == 'None') { _healthConditions.clear(); _healthConditions.add(v); } else { _healthConditions.remove('None'); _healthConditions.contains(v) ? _healthConditions.remove(v) : _healthConditions.add(v); } }); }, onNext: _healthConditions.isNotEmpty ? _nextStep : null),
                  _Step13b(onNext: _nextStep),
                  _Step14(onNext: _nextStep),
                  _Step15(selected: _kitchenStaples, onToggle: (v) { setState(() { _kitchenStaples.contains(v) ? _kitchenStaples.remove(v) : _kitchenStaples.add(v); }); }, onNext: _kitchenStaples.isNotEmpty ? _nextStep : null),
                  _Step16(selected: _cookingFrequency, onSelected: (v) => setState(() => _cookingFrequency = v), onNext: _cookingFrequency != null ? _nextStep : null),
                  _Step16b(
                    selected: _pace,
                    onSelected: (v) => setState(() => _pace = v),
                    onNext: _nextStep,
                  ),
                  _Step17(onNext: _nextStep),
                  _Step18(onNext: _nextStep),
                  _Step19(rating: _rating, onRatingChanged: (v) => setState(() => _rating = v), onNext: _nextStep),
                  _Step19b(onNext: _nextStep),
                  _Step20(onNext: _nextStep),
                  _Step20b(onNext: _nextStep),
                  _Step21(gender: _gender, heightUnit: _heightUnit, heightCm: _heightCm, heightFt: _heightFt, heightIn: _heightIn, weightUnit: _weightUnit, weightKg: _weightKg, weightLbs: _weightLbs, age: _age, goal: _goal, activity: _activity, dietary: _dietary, onNext: _nextStep),
                  _Step22(onNext: _completeOnboarding, isLoading: _isLoading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  const _Heading(this.text, {this.textAlign = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 28.sp,
        fontWeight: FontWeight.w800,
        color: Colors.black,
        letterSpacing: -0.5,
      ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  final String text;
  final TextAlign textAlign;
  const _Subtitle(this.text, {this.textAlign = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: TextStyle(
        fontSize: 15.sp,
        color: const Color(0xFF8A8A8E),
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _CtaButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final String label;
  final bool isLoading;

  const _CtaButton({
    required this.onPressed,
    required this.label,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28.r),
          ),
        ),
        child: isLoading
            ? SizedBox(
                width: 24.r,
                height: 24.r,
                child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
            : Text(
                label,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
              ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  const _OptionCard({
    required this.title,
    this.subtitle,
    this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : const Color(0xFFF2F2F7),
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(icon, color: selected ? Colors.white : Colors.black, size: 20.r),
              SizedBox(width: 12.w),
            ],
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: selected ? Colors.white : Colors.black),
                  ),
                  if (subtitle != null) ...[
                    SizedBox(height: 4.h),
                    Text(
                      subtitle!,
                      style: TextStyle(fontSize: 14.sp, color: selected ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF8A8A8E)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 1: KITCHEN / MEALS
// ─────────────────────────────────────────────────────────────────────────────
class _Step1 extends StatelessWidget {
  final VoidCallback onNext;
  const _Step1({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading("Your kitchen.\nYour meals."),
          SizedBox(height: 40.h),
          const _InfoRow(icon: Icons.kitchen, title: "Cook what you have", subtitle: "No wasted groceries"),
          SizedBox(height: 24.h),
          const _InfoRow(icon: Icons.favorite_border, title: "Eat for your goals", subtitle: "Every meal personalized"),
          SizedBox(height: 24.h),
          const _InfoRow(icon: Icons.check_circle_outline, title: "Zero guesswork", subtitle: "Know exactly what to cook"),
          const Spacer(),
          _CtaButton(onPressed: onNext, label: "Let's Start"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _InfoRow({required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.r, height: 40.r,
          decoration: const BoxDecoration(color: Color(0xFFF2F2F7), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.black, size: 20.r),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(height: 4.h),
              Text(subtitle, style: TextStyle(fontSize: 15.sp, color: const Color(0xFF8A8A8E))),
            ],
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 2: DID YOU KNOW?
// ─────────────────────────────────────────────────────────────────────────────
class _Step2 extends StatelessWidget {
  final VoidCallback onNext;
  const _Step2({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("🗑️", style: TextStyle(fontSize: 72.sp)),
                  SizedBox(height: 24.h),
                  const _Heading("67% of people waste food every week.", textAlign: TextAlign.center),
                  SizedBox(height: 12.h),
                  const _Subtitle("VitaSense helps you cook what you have — nothing goes to waste.", textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
          child: _CtaButton(onPressed: onNext, label: "That's me"),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 3: GENDER
// ─────────────────────────────────────────────────────────────────────────────
class _Step3 extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const _Step3({required this.selected, required this.onSelected, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading("Tell us about you"),
          SizedBox(height: 40.h),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelected('Male'),
                  child: Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: selected == 'Male' ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("👨", style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 16.h),
                        Text("Male", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: selected == 'Male' ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: GestureDetector(
                  onTap: () => onSelected('Female'),
                  child: Container(
                    height: 140.h,
                    decoration: BoxDecoration(
                      color: selected == 'Female' ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text("👩", style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 16.h),
                        Text("Female", style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500, color: selected == 'Female' ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 4: HEIGHT
// ─────────────────────────────────────────────────────────────────────────────
class _Step4 extends StatelessWidget {
  final String unit;
  final int heightCm;
  final int heightFt;
  final int heightIn;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<int> onCmChanged;
  final ValueChanged<int> onFtChanged;
  final ValueChanged<int> onInChanged;
  final VoidCallback onNext;

  const _Step4({
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
          const _Heading("How tall are you?"),
          SizedBox(height: 8.h),
          const _Subtitle("This helps us calculate your daily calorie needs."),
          SizedBox(height: 32.h),
          Row(
            children: [
              _UnitTab(title: "cm", isSelected: unit == 'cm', onTap: () => onUnitChanged('cm')),
              SizedBox(width: 16.w),
              _UnitTab(title: "ft/in", isSelected: unit == 'ft', onTap: () => onUnitChanged('ft')),
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
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _UnitTab extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;
  const _UnitTab({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent, width: 2)),
        ),
        child: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: isSelected ? AppColors.primary : const Color(0xFF8A8A8E),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 5: WEIGHT
// ─────────────────────────────────────────────────────────────────────────────
class _Step5 extends StatelessWidget {
  final String unit;
  final int weightKg;
  final int weightLbs;
  final ValueChanged<String> onUnitChanged;
  final ValueChanged<int> onKgChanged;
  final ValueChanged<int> onLbsChanged;
  final VoidCallback onNext;

  const _Step5({
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
          const _Heading("How much do you weigh?"),
          SizedBox(height: 8.h),
          const _Subtitle("This helps us calculate your daily calorie needs."),
          SizedBox(height: 32.h),
          Row(
            children: [
              _UnitTab(title: "kg", isSelected: unit == 'kg', onTap: () => onUnitChanged('kg')),
              SizedBox(width: 16.w),
              _UnitTab(title: "lbs", isSelected: unit == 'lbs', onTap: () => onUnitChanged('lbs')),
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
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 6: AGE
// ─────────────────────────────────────────────────────────────────────────────
class _Step6 extends StatelessWidget {
  final int age;
  final ValueChanged<int> onAgeChanged;
  final VoidCallback onNext;

  const _Step6({required this.age, required this.onAgeChanged, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading("How old are you?"),
          SizedBox(height: 8.h),
          const _Subtitle("Age affects your metabolism and calorie needs."),
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
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 7: MOTIVATION BMR
// ─────────────────────────────────────────────────────────────────────────────
class _Step7 extends StatelessWidget {
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

  const _Step7({
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
                const _Heading("Based on your measurements,"),
                SizedBox(height: 8.h),
                const _Subtitle("We'll fine-tune this with your goals next."),
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
          child: _CtaButton(onPressed: onNext, label: "Let's continue"),
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

// ─────────────────────────────────────────────────────────────────────────────
// KROK 8: GOAL
// ─────────────────────────────────────────────────────────────────────────────
class _Step8 extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const _Step8({required this.selected, required this.onSelected, required this.onNext});

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
          const _Heading("What's your goal?"),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              children: options.map((e) => _OptionCard(title: e.$1, subtitle: e.$2, icon: e.$3, selected: selected == e.$1, onTap: () => onSelected(e.$1))).toList(),
            ),
          ),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 8b: BLOCKER
// ─────────────────────────────────────────────────────────────────────────────
class _Step8b extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const _Step8b({required this.selected, required this.onSelected, required this.onNext});

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
          const _Heading("What's stopping you from reaching your goals?"),
          SizedBox(height: 8.h),
          const _Subtitle("We'll help you overcome it."),
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
              )).toList(),
            ),
          ),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 9: MOTIVATION GOAL
// ─────────────────────────────────────────────────────────────────────────────
class _Step9 extends StatelessWidget {
  final String? goal;
  final VoidCallback onNext;

  const _Step9({required this.goal, required this.onNext});

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
          const _Subtitle("VitaSense builds your plan around this.", textAlign: TextAlign.center),
          const Spacer(),
          _CtaButton(onPressed: onNext, label: "Got it"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 10: ACTIVITY
// ─────────────────────────────────────────────────────────────────────────────
class _Step10 extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const _Step10({required this.selected, required this.onSelected, required this.onNext});

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
          const _Heading("How active are you?"),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              children: options.map((e) => _OptionCard(title: e.$1, subtitle: e.$2, selected: selected == e.$1, onTap: () => onSelected(e.$1))).toList(),
            ),
          ),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 10b: HYDRATION
// ─────────────────────────────────────────────────────────────────────────────
class _Step10b extends StatefulWidget {
  final double waterLiters;
  final ValueChanged<double> onWaterChanged;
  final VoidCallback onNext;
  final double? weightKg;
  final String? activity;

  const _Step10b({
    required this.waterLiters,
    required this.onWaterChanged,
    required this.onNext,
    this.weightKg,
    this.activity,
  });

  @override
  State<_Step10b> createState() => _Step10bState();
}

class _Step10bState extends State<_Step10b> {
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
          const _Heading("How much water do you drink daily?"),
          SizedBox(height: 8.h),
          _Subtitle("Based on your weight and activity, we recommend ${rec}L per day."),
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
          _CtaButton(onPressed: widget.onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 11: DIETARY
// ─────────────────────────────────────────────────────────────────────────────
class _Step11 extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback? onNext;

  const _Step11({required this.selected, required this.onToggle, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ("✅", "No restrictions"), ("🥦", "Vegetarian"), ("🌱", "Vegan"), ("🌾", "Gluten-free"),
      ("🥛", "Dairy-free"), ("🥩", "Keto"), ("☪️", "Halal"), ("🦴", "Paleo")
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading("Any dietary preferences?"),
          SizedBox(height: 8.h),
          const _Subtitle("Select all that apply"),
          SizedBox(height: 24.h),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.0,
              children: options.map((e) {
                final isSel = selected.contains(e.$2);
                return GestureDetector(
                  onTap: () => onToggle(e.$2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.$1, style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 8.h),
                        Text(
                          e.$2,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: isSel ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 12: ALLERGIES
// ─────────────────────────────────────────────────────────────────────────────
class _Step12 extends StatefulWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback? onNext;

  const _Step12({required this.selected, required this.onToggle, required this.onNext});

  @override
  State<_Step12> createState() => _Step12State();
}

class _Step12State extends State<_Step12> {
  String _searchQuery = '';

  final _allOptions = [
    ("✋", "None"), ("🌾", "Gluten"), ("🥛", "Milk/Dairy"), ("🥚", "Eggs"),
    ("🐟", "Fish"), ("🦐", "Shellfish"), ("🥜", "Peanuts"), ("🌰", "Tree Nuts"),
    ("🫘", "Soy"), ("🫙", "Sesame"), ("🥬", "Celery"), ("🌿", "Mustard"),
    ("🍷", "Sulphites"), ("🫘", "Lupin"), ("🦑", "Molluscs"), ("🍓", "Strawberries"),
    ("🍊", "Citrus"), ("🥝", "Kiwi"), ("🍑", "Peach"), ("🍎", "Apple"),
    ("🍌", "Banana"), ("🥭", "Mango"), ("🥑", "Avocado"), ("🍅", "Tomato"),
    ("🍫", "Chocolate"), ("🌽", "Corn"), ("🍞", "Yeast"), ("🪵", "Cinnamon"),
    ("🥩", "Pork"), ("🐄", "Beef")
  ];

  @override
  Widget build(BuildContext context) {
    final filteredOptions = _allOptions.where((e) {
      if (_searchQuery.isEmpty) return true;
      return e.$2.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const _Heading("Any food allergies?"),
              SizedBox(height: 8.h),
              const _Subtitle("Select all that apply — we'll never suggest these."),
              SizedBox(height: 16.h),
              TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: InputDecoration(
                  hintText: 'Search allergens...',
                  prefixIcon: Icon(Icons.search, color: const Color(0xFF8A8A8E), size: 20.r),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F7),
                  contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: GridView.count(
              padding: EdgeInsets.only(bottom: 16.h),
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.0,
              children: filteredOptions.map((e) {
                final isSel = widget.selected.contains(e.$2);
                return GestureDetector(
                  onTap: () => widget.onToggle(e.$2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.$1, style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            e.$2,
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 32.h),
          child: _CtaButton(onPressed: widget.onNext, label: "Continue"),
        ),
      ],
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 13: HEALTH CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
class _Step13 extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback? onNext;

  const _Step13({required this.selected, required this.onToggle, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ("✋", "None"), ("💉", "Diabetes"), ("❤️", "Hypertension"), ("⚠️", "High cholesterol"),
      ("🫁", "IBS"), ("🩹", "Post-surgery recovery"), ("🫀", "Heart disease"), ("➕", "Other")
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading("Any health conditions?"),
          SizedBox(height: 8.h),
          const _Subtitle("This helps us tailor your meals safely."),
          SizedBox(height: 24.h),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.0,
              children: options.map((e) {
                final isSel = selected.contains(e.$2);
                return GestureDetector(
                  onTap: () => onToggle(e.$2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSel ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.$1, style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 8.h),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Text(
                            e.$2,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                              color: isSel ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 13b: SOCIAL PROOF
// ─────────────────────────────────────────────────────────────────────────────
class _Step13b extends StatelessWidget {
  final VoidCallback onNext;
  const _Step13b({required this.onNext});

  @override
  Widget build(BuildContext context) {
    final reviews = [
      ("Marta K.", "Lost 6kg in 2 months! VitaSense finally made me understand what I'm eating.", 5),
      ("Tomasz W.", "The pantry matching feature is genius. No more food waste.", 5),
      ("Ania S.", "I love the AI meal suggestions. My diet has never been this varied.", 4),
    ];

    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Column(
              children: [
                Text("50,000+", style: TextStyle(fontSize: 56.sp, fontWeight: FontWeight.w800, color: AppColors.primary)),
                Text("people already reach their goals with VitaSense", textAlign: TextAlign.center, style: TextStyle(fontSize: 16.sp, color: Colors.grey[600])),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          const _Heading("What our users say"),
          SizedBox(height: 16.h),
          Expanded(
            child: ListView(
              children: reviews.map((r) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 18.r, backgroundColor: AppColors.primary, child: Text(r.$1[0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp))),
                          SizedBox(width: 10.w),
                          Text(r.$1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                          const Spacer(),
                          Row(children: List.generate(r.$3, (_) => Icon(Icons.star, color: Colors.amber, size: 14.r))),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(r.$2, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 14: VIRTUAL FRIDGE INTRO
// ─────────────────────────────────────────────────────────────────────────────
class _Step14 extends StatelessWidget {
  final VoidCallback onNext;
  const _Step14({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text("🍽️", style: TextStyle(fontSize: 80.sp)),
          SizedBox(height: 32.h),
          const _Heading("What's in your kitchen?", textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          const _Subtitle("Tell us what you usually have at home. We'll only suggest meals you can actually make.", textAlign: TextAlign.center),
          SizedBox(height: 40.h),
          _buildFeature("✅", "No shopping needed"),
          SizedBox(height: 12.h),
          _buildFeature("✅", "Zero food waste"),
          SizedBox(height: 12.h),
          _buildFeature("✅", "Cook what you have"),
          const Spacer(),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildFeature(String icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: TextStyle(fontSize: 16.sp)),
        SizedBox(width: 8.w),
        Text(text, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: const Color(0xFF8A8A8E))),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 15: KITCHEN STAPLES
// ─────────────────────────────────────────────────────────────────────────────
class _Step15 extends StatelessWidget {
  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback? onNext;

  const _Step15({required this.selected, required this.onToggle, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ("🥩", "Proteins"), ("🥬", "Leafy Greens"), ("🥔", "Root Veggies"), ("🍚", "Grains"),
      ("🥚", "Eggs & Dairy"), ("🍝", "Pasta"), ("🍎", "Fruits"), ("🌿", "Spices & Herbs")
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading("What's usually in your kitchen?"),
          SizedBox(height: 24.h),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.1,
              children: options.map((e) {
                final isSel = selected.contains(e.$2);
                return GestureDetector(
                  onTap: () => onToggle(e.$2),
                  child: Container(
                    decoration: BoxDecoration(color: isSel ? AppColors.primary : const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(14.r)),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(e.$1, style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 12.h),
                        Text(e.$2, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: isSel ? Colors.white : Colors.black)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          _CtaButton(onPressed: onNext, label: "Find My Meals"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 16: COOKING FREQUENCY
// ─────────────────────────────────────────────────────────────────────────────
class _Step16 extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  const _Step16({required this.selected, required this.onSelected, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ("Rarely", "mostly takeout or delivery"),
      ("A few times a week", "when I have time"),
      ("Almost daily", "I enjoy cooking"),
      ("I meal prep", "batch cooking on weekends"),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading("How often do you cook?"),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              children: options.map((e) => _OptionCard(title: e.$1, subtitle: e.$2, selected: selected == e.$1, onTap: () => onSelected(e.$1))).toList(),
            ),
          ),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 16b: HOW FAST
// ─────────────────────────────────────────────────────────────────────────────
class _Step16b extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelected;
  final VoidCallback onNext;
  const _Step16b({required this.selected, required this.onSelected, required this.onNext});

  @override
  Widget build(BuildContext context) {
    final options = [
      ('🐢', 'Slow & steady', 'Sustainable, long-term results'),
      ('🚶', 'Moderate', 'Balanced pace, recommended'),
      ('🏃', 'Fast', 'Aggressive, requires discipline'),
    ];
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _Heading("How fast do you want to reach your goal?"),
          SizedBox(height: 8.h),
          const _Subtitle("We'll adjust your daily targets accordingly."),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              children: options.map((e) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: GestureDetector(
                  onTap: () => onSelected(e.$2),
                  child: Container(
                    padding: EdgeInsets.all(20.r),
                    decoration: BoxDecoration(
                      color: selected == e.$2 ? AppColors.primary : const Color(0xFFF2F2F7),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Row(
                      children: [
                        Text(e.$1, style: TextStyle(fontSize: 32.sp)),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.$2, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: selected == e.$2 ? Colors.white : Colors.black)),
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
              )).toList(),
            ),
          ),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 17: SOCIAL PROOF
// ─────────────────────────────────────────────────────────────────────────────
class _Step17 extends StatelessWidget {
  final VoidCallback onNext;
  const _Step17({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          const _Heading("You're in good company.", textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          const _Subtitle("Join thousands already eating smarter.", textAlign: TextAlign.center),
          SizedBox(height: 40.h),
          Text("12,400+", style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w800, color: AppColors.primary, height: 1.0)),
          SizedBox(height: 4.h),
          Text("people using VitaSense", style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8A8A8E))),
          SizedBox(height: 40.h),
          const _ReviewCard(name: "Anna K.", text: "Finally an app that uses what I already have at home. Love it!"),
          SizedBox(height: 12.h),
          const _ReviewCard(name: "Tomasz W.", text: "Lost 4kg in 6 weeks just by following the meal suggestions."),
          const Spacer(),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _ReviewCard extends StatelessWidget {
  final String name;
  final String text;
  const _ReviewCard({required this.name, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(14.r)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(name, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold, color: Colors.black)),
              SizedBox(width: 8.w),
              ...List.generate(5, (_) => Icon(Icons.star, color: Colors.amber, size: 14.r)),
            ],
          ),
          SizedBox(height: 8.h),
          Text(text, style: TextStyle(fontSize: 13.sp, color: const Color(0xFF8A8A8E))),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 18: NOTIFICATIONS
// ─────────────────────────────────────────────────────────────────────────────
class _Step18 extends StatelessWidget {
  final VoidCallback onNext;
  const _Step18({required this.onNext});

  Future<void> _requestNotification() async {
    await Permission.notification.request();
    onNext();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text("🔔", style: TextStyle(fontSize: 72.sp)),
          SizedBox(height: 32.h),
          const _Heading("Don't miss your meals.", textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          const _Subtitle("We'll remind you when it's time to eat and help you stay on track.", textAlign: TextAlign.center),
          const Spacer(),
          _CtaButton(onPressed: _requestNotification, label: "Allow Notifications"),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: onNext,
            child: Text("Not now", style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8A8A8E))),
          )
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 19: RATE US
// ─────────────────────────────────────────────────────────────────────────────
class _Step19 extends StatelessWidget {
  final int rating;
  final ValueChanged<int> onRatingChanged;
  final VoidCallback onNext;

  const _Step19({required this.rating, required this.onRatingChanged, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Spacer(),
          Text("⭐", style: TextStyle(fontSize: 72.sp)),
          SizedBox(height: 32.h),
          const _Heading("Enjoying VitaSense?", textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          const _Subtitle("Your rating helps us improve and reach more people.", textAlign: TextAlign.center),
          SizedBox(height: 40.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return GestureDetector(
                onTap: () => onRatingChanged(index + 1),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4.w),
                  child: Icon(
                    Icons.star,
                    size: 48.r,
                    color: index < rating ? Colors.amber : const Color(0xFFE5E5EA),
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          _CtaButton(onPressed: rating > 0 ? onNext : null, label: "Submit Rating"),
          SizedBox(height: 16.h),
          TextButton(
            onPressed: onNext,
            child: Text("Skip", style: TextStyle(fontSize: 16.sp, color: const Color(0xFF8A8A8E))),
          )
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 19b: APP RATINGS
// ─────────────────────────────────────────────────────────────────────────────
class _Step19b extends StatelessWidget {
  final VoidCallback onNext;
  const _Step19b({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        children: [
          SizedBox(height: 24.h),
          Text('4.8', style: TextStyle(fontSize: 72.sp, fontWeight: FontWeight.w800, color: Colors.black)),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => Icon(Icons.star, color: Colors.amber, size: 32.r)),
          ),
          SizedBox(height: 8.h),
          Text('100K+ App Ratings', style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          SizedBox(height: 32.h),
          const _Heading("VitaSense was made\nfor people like you"),
          SizedBox(height: 24.h),
          Expanded(
            child: ListView(
              children: [
                ('Karol M.', 'Lost 8kg in 3 months. The AI suggestions are spot on!', 5),
                ('Zofia T.', 'Finally an app that understands my dietary needs.', 5),
                ('Piotr B.', 'The pantry feature alone is worth it. Zero food waste!', 5),
              ].map((r) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: Container(
                  padding: EdgeInsets.all(16.r),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF2F2F7),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          CircleAvatar(radius: 18.r, backgroundColor: AppColors.primary, child: Text(r.$1[0], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14.sp))),
                          SizedBox(width: 10.w),
                          Text(r.$1, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp)),
                          const Spacer(),
                          Row(children: List.generate(r.$3, (_) => Icon(Icons.star, color: Colors.amber, size: 14.r))),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Text(r.$2, style: TextStyle(fontSize: 13.sp, color: Colors.grey[700])),
                    ],
                  ),
                ),
              )).toList(),
            ),
          ),
          _CtaButton(onPressed: onNext, label: "Continue"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 20: LOADING SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class _Step20 extends StatefulWidget {
  final VoidCallback onNext;
  const _Step20({required this.onNext});

  @override
  State<_Step20> createState() => _Step20State();
}

class _Step20State extends State<_Step20> with SingleTickerProviderStateMixin {
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
          const _Heading("Setting up your plan...", textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          const _Subtitle("Customizing your meal suggestions.", textAlign: TextAlign.center),
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
          const _AnimatedListItem(text: "✓ Calculating your calories", delay: 600),
          const _AnimatedListItem(text: "✓ Matching your preferences", delay: 1200),
          const _AnimatedListItem(text: "✓ Filtering allergens", delay: 1800),
          const _AnimatedListItem(text: "✓ Building your meal plan", delay: 2400),
          const Spacer(),
        ],
      ),
    );
  }
}

class _AnimatedListItem extends StatelessWidget {
  final String text;
  final int delay;
  const _AnimatedListItem({required this.text, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0.0, end: 1.0),
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeIn,
        builder: (context, val, child) {
          return Opacity(opacity: val, child: Text(text, style: TextStyle(fontSize: 15.sp, color: Colors.black, fontWeight: FontWeight.w600)));
        },
      ).animate(delay: delay.ms),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 20b: PROGRESS ANIMATION
// ─────────────────────────────────────────────────────────────────────────────
class _Step20b extends StatefulWidget {
  final VoidCallback onNext;
  const _Step20b({required this.onNext});

  @override
  State<_Step20b> createState() => _Step20bState();
}

class _Step20bState extends State<_Step20b> {
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
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
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

// ─────────────────────────────────────────────────────────────────────────────
// KROK 21: PLAN SUMMARY
// ─────────────────────────────────────────────────────────────────────────────
class _Step21 extends StatelessWidget {
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

  const _Step21({
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
          const _Heading("Here's your plan."),
          SizedBox(height: 32.h),
          Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(color: const Color(0xFFF2F2F7), borderRadius: BorderRadius.circular(16.r)),
            child: Column(
              children: [
                _SummaryRow(label: "Goal", value: goal ?? "-"),
                const Divider(color: Color(0xFFE5E5EA), height: 32, thickness: 1),
                _SummaryRow(label: "Activity", value: activity ?? "-"),
                const Divider(color: Color(0xFFE5E5EA), height: 32, thickness: 1),
                _SummaryRow(label: "Dietary", value: dietary.isEmpty ? "None" : dietary.join(", ")),
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
          _CtaButton(onPressed: onNext, label: "See My Meal Plan"),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  const _SummaryRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: TextStyle(fontSize: 15.sp, color: const Color(0xFF8A8A8E)))),
        Expanded(flex: 3, child: Text(value, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: Colors.black), textAlign: TextAlign.right)),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// KROK 22: PAYWALL
// ─────────────────────────────────────────────────────────────────────────────
class _Step22 extends StatefulWidget {
  final VoidCallback onNext;
  final bool isLoading;

  const _Step22({required this.onNext, required this.isLoading});

  @override
  State<_Step22> createState() => _Step22State();
}

class _Step22State extends State<_Step22> {
  String _selectedPlan = 'yearly';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      child: SafeArea(
        child: Column(
          children: [

            Text(
              "Start your 3-day FREE trial to continue.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.w800, color: Colors.black, height: 1.2),
            ),
            SizedBox(height: 32.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildTimelineStep(
                      icon: Icons.lock_open,
                      color: AppColors.primary,
                      title: "Today",
                      subtitle: "Unlock all features — meals, pantry matching, and AI suggestions.",
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      icon: Icons.notifications,
                      color: Colors.orange,
                      title: "In 2 Days — Reminder",
                      subtitle: "We'll remind you before your trial ends.",
                      isLast: false,
                    ),
                    _buildTimelineStep(
                      icon: Icons.workspace_premium,
                      color: Colors.black,
                      title: "In 3 Days — Billing Starts",
                      subtitle: "You'll be charged unless you cancel anytime before.",
                      isLast: true,
                    ),
                    SizedBox(height: 32.h),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlan = 'monthly'),
                            child: Container(
                              height: 130.h,
                              width: double.infinity,
                              padding: EdgeInsets.symmetric(vertical: 16.h, horizontal: 8.w),
                              decoration: BoxDecoration(
                                color: _selectedPlan == 'monthly' ? const Color(0xFF2ECC71) : const Color(0xFFF2F2F7),
                                border: _selectedPlan == 'monthly' ? Border.all(color: const Color(0xFF2ECC71), width: 2) : Border.all(color: Colors.transparent, width: 2),
                                borderRadius: BorderRadius.circular(14.r),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_selectedPlan == 'monthly')
                                    Icon(Icons.check_circle, color: Colors.white, size: 20.r),
                                  Text("Monthly", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _selectedPlan == 'monthly' ? Colors.white : Colors.black)),
                                  SizedBox(height: 8.h),
                                  Text("\$9.99/mo", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _selectedPlan == 'monthly' ? Colors.white : Colors.black)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 16.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPlan = 'yearly'),
                            child: Stack(
                              children: [
                                Container(
                                  height: 130.h,
                                  width: double.infinity,
                                  padding: EdgeInsets.only(top: 36.h, left: 8.w, right: 8.w, bottom: 16.h),
                                  decoration: BoxDecoration(
                                    color: _selectedPlan == 'yearly' ? const Color(0xFF2ECC71) : const Color(0xFFF2F2F7),
                                    border: _selectedPlan == 'yearly' ? Border.all(color: const Color(0xFF2ECC71), width: 2) : Border.all(color: Colors.transparent, width: 2),
                                    borderRadius: BorderRadius.circular(14.r),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      if (_selectedPlan == 'yearly')
                                        Icon(Icons.check_circle, color: Colors.white, size: 20.r),
                                      Text("Yearly", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _selectedPlan == 'yearly' ? Colors.white : Colors.black)),
                                      SizedBox(height: 8.h),
                                      Text("\$29.99", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: _selectedPlan == 'yearly' ? Colors.white : Colors.black)),
                                    ],
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: Container(
                                    width: double.infinity,
                                    padding: EdgeInsets.symmetric(vertical: 6.h),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2ECC71),
                                      borderRadius: BorderRadius.only(topLeft: Radius.circular(12.r), topRight: Radius.circular(12.r)),
                                    ),
                                    child: Text(
                                      "3 DAYS FREE",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white, fontSize: 11.sp, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.check, color: const Color(0xFF8A8A8E), size: 16.r),
                        SizedBox(width: 8.w),
                        Text("No Payment Due Now", style: TextStyle(color: const Color(0xFF8A8A8E), fontSize: 14.sp)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 16.h),
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: FilledButton(
                onPressed: widget.isLoading ? null : widget.onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2ECC71),
                  disabledBackgroundColor: const Color(0xFF2ECC71).withValues(alpha: 0.5),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28.r)),
                ),
                child: widget.isLoading
                    ? SizedBox(width: 24.r, height: 24.r, child: const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        _selectedPlan == 'yearly' ? 'Start My 3-Day Free Trial' : 'Start Monthly Plan',
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              _selectedPlan == 'yearly'
                  ? "3 days free, then \$29.99/year. Auto-renews unless cancelled."
                  : "\$9.99/month. Auto-renews unless cancelled.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.sp, color: const Color(0xFF8A8A8E)),
            ),
            SizedBox(height: 16.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("Terms", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8A8A8E))),
                Text(" · ", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8A8A8E))),
                Text("Privacy", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8A8A8E))),
                Text(" · ", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8A8A8E))),
                Text("Restore", style: TextStyle(fontSize: 12.sp, color: const Color(0xFF8A8A8E))),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTimelineStep({required IconData icon, required Color color, required String title, required String subtitle, required bool isLast}) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Column(
            children: [
              Container(
                width: 40.r,
                height: 40.r,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Icon(icon, color: Colors.white, size: 20.r),
              ),
              if (!isLast) Expanded(child: Container(width: 2.w, color: const Color(0xFFE5E5EA))),
            ],
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 24.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 8.h),
                  Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black)),
                  SizedBox(height: 4.h),
                  Text(subtitle, style: TextStyle(fontSize: 14.sp, color: const Color(0xFF8A8A8E), height: 1.3)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
