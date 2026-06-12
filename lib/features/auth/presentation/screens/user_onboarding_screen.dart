import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_event.dart';
import 'onboarding/onboarding_step1_intro.dart';
import 'onboarding/onboarding_step3_gender.dart';
import 'onboarding/onboarding_step4_height.dart';
import 'onboarding/onboarding_step5_weight.dart';
import 'onboarding/onboarding_step6_age.dart';
import 'onboarding/onboarding_step7_summary.dart';
import 'onboarding/onboarding_step8_goal.dart';
import 'onboarding/onboarding_step9_target.dart';
import 'onboarding/onboarding_step10_activity.dart';
import 'onboarding/onboarding_step11_diet.dart';
import 'onboarding/onboarding_step12_allergies.dart';
import 'onboarding/onboarding_step13_health.dart';
import 'onboarding/onboarding_step14_kitchen.dart';
import 'onboarding/onboarding_step15_cooking.dart';
import 'onboarding/onboarding_step16_pace.dart';
import 'onboarding/onboarding_step17_social.dart';
import 'onboarding/onboarding_step18_notifications.dart';
import 'onboarding/onboarding_step19_rating.dart';
import 'onboarding/onboarding_step20_loading.dart';
import 'onboarding/onboarding_step21_projection.dart';
import 'onboarding/onboarding_step22_paywall.dart';
// ─────────────────────────────────────────────────────────────────────────────
// KROK 1: KITCHEN / MEALS
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 2: DID YOU KNOW?
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 3: GENDER
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 4: HEIGHT
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 5: WEIGHT
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 6: AGE
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 7: MOTIVATION BMR
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 8: GOAL
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 8b: BLOCKER
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 9: MOTIVATION GOAL
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 10: ACTIVITY
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 10b: HYDRATION
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 11: DIETARY
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 12: ALLERGIES
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 13: HEALTH CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 13b: SOCIAL PROOF
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 14: VIRTUAL FRIDGE INTRO
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 15: KITCHEN STAPLES
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 16: COOKING FREQUENCY
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 16b: HOW FAST
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 17: SOCIAL PROOF
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 18: NOTIFICATIONS
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 19: RATE US
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 19b: APP RATINGS
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 20: LOADING SCREEN
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 20b: PROGRESS ANIMATION
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 21: PLAN SUMMARY
// ─────────────────────────────────────────────────────────────────────────────
// ─────────────────────────────────────────────────────────────────────────────
// KROK 22: PAYWALL
// ─────────────────────────────────────────────────────────────────────────────
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

    // Mapowanie UI → baza
    String? mappedGender;
    if (_gender == 'Male') {
      mappedGender = 'male';
    } else if (_gender == 'Female') mappedGender = 'female';
    else mappedGender = 'other';

    String? mappedGoal;
    if (_goal == 'Lose weight') {
      mappedGoal = 'weight_loss';
    } else if (_goal == 'Gain weight' || _goal == 'Build muscle') mappedGoal = 'muscle_gain';
    else if (_goal == 'Eat healthier' || _goal == 'General Health') mappedGoal = 'general_health';
    else mappedGoal = 'general_health';

    String? mappedActivity;
    if (_activity == 'Sedentary') {
      mappedActivity = 'sedentary';
    } else if (_activity == 'Lightly active') mappedActivity = 'light';
    else if (_activity == 'Moderately active') mappedActivity = 'moderate';
    else if (_activity == 'Very active') mappedActivity = 'active';
    else mappedActivity = 'moderate';

    String mappedPace;
    if (_pace == 'Slow & steady') {
      mappedPace = 'slow';
    } else if (_pace == 'Fast') mappedPace = 'fast';
    else mappedPace = 'moderate';

    final data = {
      'gender': mappedGender,
      'height_cm': finalHeightCm,
      'weight_kg': finalWeightKg,
      'age': _age,
      'goal_type': mappedGoal,
      'activity_level': mappedActivity,
      'dietary_preferences': _dietary,
      'allergies': _allergies,
      'health_conditions': _healthConditions,
      'goal_pace': mappedPace,
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
          const SnackBar(content: Text('Something went wrong. Please try again.'), backgroundColor: Colors.red),
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
                  Step1(onNext: _nextStep),
                  Step2(onNext: _nextStep),
                  Step3(selected: _gender, onSelected: (v) => setState(() => _gender = v), onNext: _gender != null ? _nextStep : null),
                  Step4(unit: _heightUnit, heightCm: _heightCm, heightFt: _heightFt, heightIn: _heightIn, onUnitChanged: (v) => setState(() => _heightUnit = v), onCmChanged: (v) => setState(() => _heightCm = v), onFtChanged: (v) => setState(() => _heightFt = v), onInChanged: (v) => setState(() => _heightIn = v), onNext: _nextStep),
                  Step5(unit: _weightUnit, weightKg: _weightKg, weightLbs: _weightLbs, onUnitChanged: (v) => setState(() => _weightUnit = v), onKgChanged: (v) => setState(() => _weightKg = v), onLbsChanged: (v) => setState(() => _weightLbs = v), onNext: _nextStep),
                  Step6(age: _age, onAgeChanged: (v) => setState(() => _age = v), onNext: _nextStep),
                  Step7(gender: _gender, heightUnit: _heightUnit, heightCm: _heightCm, heightFt: _heightFt, heightIn: _heightIn, weightUnit: _weightUnit, weightKg: _weightKg, weightLbs: _weightLbs, age: _age, onNext: _nextStep),
                  Step8(selected: _goal, onSelected: (v) => setState(() => _goal = v), onNext: _goal != null ? _nextStep : null),
                  Step8b(
                    selected: _blocker,
                    onSelected: (v) => setState(() => _blocker = v),
                    onNext: _blocker != null ? _nextStep : null,
                  ),
                  Step9(goal: _goal, onNext: _nextStep),
                  Step10(selected: _activity, onSelected: (v) => setState(() => _activity = v), onNext: _activity != null ? _nextStep : null),
                  Step10b(
                    waterLiters: _waterLiters,
                    onWaterChanged: (v) => setState(() => _waterLiters = v),
                    onNext: _nextStep,
                    weightKg: _weightKg.toDouble(),
                    activity: _activity,
                  ),
                  Step11(selected: _dietary, onToggle: (v) { setState(() { if (v == 'No restrictions') { _dietary.clear(); _dietary.add(v); } else { _dietary.remove('No restrictions'); _dietary.contains(v) ? _dietary.remove(v) : _dietary.add(v); } }); }, onNext: _dietary.isNotEmpty ? _nextStep : null),
                  Step12(selected: _allergies, onToggle: (v) { setState(() { if (v == 'None') { _allergies.clear(); _allergies.add(v); } else { _allergies.remove('None'); _allergies.contains(v) ? _allergies.remove(v) : _allergies.add(v); } }); }, onNext: _nextStep),
                  Step13(selected: _healthConditions, onToggle: (v) { setState(() { if (v == 'None') { _healthConditions.clear(); _healthConditions.add(v); } else { _healthConditions.remove('None'); _healthConditions.contains(v) ? _healthConditions.remove(v) : _healthConditions.add(v); } }); }, onNext: _healthConditions.isNotEmpty ? _nextStep : null),
                  Step13b(onNext: _nextStep),
                  Step14(onNext: _nextStep),
                  Step15(selected: _kitchenStaples, onToggle: (v) { setState(() { _kitchenStaples.contains(v) ? _kitchenStaples.remove(v) : _kitchenStaples.add(v); }); }, onNext: _kitchenStaples.isNotEmpty ? _nextStep : null),
                  Step16(selected: _cookingFrequency, onSelected: (v) => setState(() => _cookingFrequency = v), onNext: _cookingFrequency != null ? _nextStep : null),
                  Step16b(
                    selected: _pace,
                    onSelected: (v) => setState(() => _pace = v),
                    onNext: _nextStep,
                  ),
                  Step17(onNext: _nextStep),
                  Step18(onNext: _nextStep),
                  Step19(rating: _rating, onRatingChanged: (v) => setState(() => _rating = v), onNext: _nextStep),
                  Step19b(onNext: _nextStep),
                  Step20(onNext: _nextStep),
                  Step20b(onNext: _nextStep),
                  Step21(gender: _gender, heightUnit: _heightUnit, heightCm: _heightCm, heightFt: _heightFt, heightIn: _heightIn, weightUnit: _weightUnit, weightKg: _weightKg, weightLbs: _weightLbs, age: _age, goal: _goal, activity: _activity, dietary: _dietary, onNext: _nextStep),
                  Step22(onNext: _completeOnboarding, isLoading: _isLoading),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}