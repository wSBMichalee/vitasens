import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/auth/data/auth_repository.dart';

class UserOnboardingScreen extends StatefulWidget {
  const UserOnboardingScreen({super.key});

  @override
  State<UserOnboardingScreen> createState() => _UserOnboardingScreenState();
}

class _UserOnboardingScreenState extends State<UserOnboardingScreen> {
  final PageController _pageController = PageController();
  final AuthRepository _authRepository = AuthRepository();

  int _currentStep = 0;

  // Collected data
  final List<String> _accomplishments = [];
  bool? _usedOtherApps;
  String? _gender;
  int _age = 25;
  int _height = 170;
  int _weight = 70;
  int _targetWeight = 70;
  bool _sensitiveData = true;
  bool _tos = true;
  bool _useCm = true;
  bool _useKg = true;
  String? _goal;
  String? _pace;
  String? _activity;
  final List<String> _allergies = [];
  final List<String> _cuisines = [];
  List<String> _healthConditions = ['none'];
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 13) {
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
      _pageController.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentStep--);
    }
  }

  Future<void> _completeOnboarding() async {
    setState(() => _isLoading = true);
    try {
      await _authRepository.updateProfile({
        'accomplishments': _accomplishments,
        'used_other_apps': _usedOtherApps,
        'gender': _gender,
        'age': _age,
        'weight_kg': _useKg ? _weight : _weight * 0.453592,
        'height_cm': _useCm ? _height : _height * 2.54,
        'target_weight_kg': _useKg ? _targetWeight : _targetWeight * 0.453592,
        'goal_type': _goal,
        'goal_pace': _pace,
        'activity_level': _activity,
        'allergies': _allergies,
        'favorite_cuisines': _cuisines,
        'health_conditions': _healthConditions,
      });
      await _authRepository.calculateTargets();
      await _authRepository.completeOnboarding();
      if (mounted) context.go(AppRoutes.paywall);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      body: SafeArea(
        child: Column(
          children: [
            // ─── PROGRESS BAR ──────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 0),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    GestureDetector(
                      onTap: _previousStep,
                      child: Container(
                        margin: EdgeInsets.only(right: 16.w),
                        padding: EdgeInsets.all(8.r),
                        decoration: const BoxDecoration(
                          color: AppColors.borderLight,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary,
                          size: 18.r,
                        ),
                      ),
                    ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: (_currentStep + 1) / 14,
                      ),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOutCubic,
                      builder: (context, value, _) {
                        return LinearProgressIndicator(
                          value: value,
                          color: AppColors.primary,
                          backgroundColor: AppColors.borderLight,
                          minHeight: 4.h,
                          borderRadius: BorderRadius.circular(2.r),
                        );
                      },
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Text(
                    '${_currentStep + 1}/14',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // ─── PAGES ─────────────────────────────────────────────────────
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _AccomplishStep(
                    selected: _accomplishments,
                    onToggle: (v) {
                      setState(() {
                        _accomplishments.contains(v)
                            ? _accomplishments.remove(v)
                            : _accomplishments.add(v);
                      });
                    },
                    onNext: _accomplishments.isNotEmpty ? _nextStep : null,
                  ),
                  _NutritionAppsStep(
                    selected: _usedOtherApps,
                    onSelected: (v) => setState(() => _usedOtherApps = v),
                    onNext: _usedOtherApps != null ? _nextStep : null,
                  ),
                  _MotivationStep(
                    onNext: _nextStep,
                  ),
                  _GenderStep(
                    selected: _gender,
                    onSelected: (v) => setState(() => _gender = v),
                    onNext: _gender != null ? _nextStep : null,
                  ),
                  _AgeStep(
                    age: _age,
                    onDecrement: () {
                      if (_age > 10) setState(() => _age--);
                    },
                    onIncrement: () {
                      if (_age < 120) setState(() => _age++);
                    },
                    onNext: _nextStep,
                  ),
                  _HeightStep(
                    height: _height,
                    useCm: _useCm,
                    onToggleUnit: () {
                      setState(() {
                        if (_useCm) {
                          _height = (_height / 2.54).round();
                        } else {
                          _height = (_height * 2.54).round();
                        }
                        _useCm = !_useCm;
                      });
                    },
                    onChanged: (v) => setState(() => _height = v),
                    onNext: _nextStep,
                  ),
                  _WeightStep(
                    weight: _weight,
                    useKg: _useKg,
                    onToggleUnit: () {
                      setState(() {
                        if (_useKg) {
                          _weight = (_weight * 2.20462).round();
                          _targetWeight = (_targetWeight * 2.20462).round();
                        } else {
                          _weight = (_weight / 2.20462).round();
                          _targetWeight = (_targetWeight / 2.20462).round();
                        }
                        _useKg = !_useKg;
                      });
                    },
                    onChanged: (v) => setState(() => _weight = v),
                    onNext: _nextStep,
                  ),
                  _GoalStep(
                    selected: _goal,
                    onSelected: (v) => setState(() => _goal = v),
                    onNext: _goal != null ? _nextStep : null,
                  ),
                  _PaceStep(
                    selected: _pace,
                    onSelected: (v) => setState(() => _pace = v),
                    onNext: _pace != null ? _nextStep : null,
                  ),
                  _ActivityStep(
                    selected: _activity,
                    onSelected: (v) => setState(() => _activity = v),
                    onNext: _activity != null ? _nextStep : null,
                  ),
                  _TargetWeightStep(
                    targetWeight: _targetWeight,
                    currentWeight: _weight,
                    goal: _goal,
                    useKg: _useKg,
                    onChanged: (v) => setState(() => _targetWeight = v),
                    onNext: _nextStep,
                  ),
                  _PreferencesStep(
                    allergies: _allergies,
                    cuisines: _cuisines,
                    onToggleAllergy: (v) {
                      setState(() {
                        _allergies.contains(v)
                            ? _allergies.remove(v)
                            : _allergies.add(v);
                      });
                    },
                    onToggleCuisine: (v) {
                      setState(() {
                        _cuisines.contains(v)
                            ? _cuisines.remove(v)
                            : _cuisines.add(v);
                      });
                    },
                    onNext: _nextStep,
                  ),
                  _HealthConditionsStep(
                    selected: _healthConditions,
                    onToggle: (v) {
                      setState(() {
                        if (v == 'none') {
                          _healthConditions = ['none'];
                        } else {
                          _healthConditions.remove('none');
                          _healthConditions.contains(v)
                              ? _healthConditions.remove(v)
                              : _healthConditions.add(v);
                          if (_healthConditions.isEmpty) {
                            _healthConditions = ['none'];
                          }
                        }
                      });
                    },
                    onNext: _nextStep,
                  ),
                  _AlmostDoneStep(
                    sensitiveData: _sensitiveData,
                    tos: _tos,
                    onSensitiveDataChanged: (v) => setState(() => _sensitiveData = v ?? false),
                    onTosChanged: (v) => setState(() => _tos = v ?? false),
                    onComplete: _isLoading ? null : _completeOnboarding,
                    isLoading: _isLoading,
                  ),
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
// STEP 1: ACCOMPLISH
// ─────────────────────────────────────────────────────────────────────────────
class _AccomplishStep extends StatelessWidget {
  const _AccomplishStep({
    required this.selected,
    required this.onToggle,
    required this.onNext,
  });

  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final options = [
      ('🍎 Eat and live healthier', 'healthier'),
      ('⚡ Boost my energy and mood', 'energy'),
      ('💪 Stay motivated and consistent', 'motivated'),
      ('🧘 Feel better about my body', 'body'),
      ('🥗 Cook smarter with what I have', 'cook'),
      ('❤️ Eat for my health condition', 'condition'),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What would you like to accomplish?", style: AppTextStyles.headingLarge),
          SizedBox(height: 8.h),
          Text("Choose all that apply", style: AppTextStyles.bodyMedium),
          SizedBox(height: 32.h),
          ...options.map(
            (o) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _MultiSelectCard(
                label: o.$1,
                selected: selected.contains(o.$2),
                onTap: () => onToggle(o.$2),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          _ContinueButton(onPressed: onNext),
          SizedBox(height: 16.h),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

class _MultiSelectCard extends StatelessWidget {
  const _MultiSelectCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.borderLight,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.primary, size: 24.r)
            else
              Icon(Icons.circle_outlined, color: AppColors.textMuted, size: 24.r),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2: NUTRITION APPS
// ─────────────────────────────────────────────────────────────────────────────
class _NutritionAppsStep extends StatelessWidget {
  const _NutritionAppsStep({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final bool? selected;
  final ValueChanged<bool> onSelected;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Have you tried other nutrition apps?", style: AppTextStyles.headingLarge),
          SizedBox(height: 48.h),
          _BinaryCard(
            label: '👍 Yes - I have',
            selected: selected == true,
            onTap: () => onSelected(true),
          ),
          SizedBox(height: 16.h),
          _BinaryCard(
            label: '👎 No - first time',
            selected: selected == false,
            onTap: () => onSelected(false),
          ),
          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

class _BinaryCard extends StatelessWidget {
  const _BinaryCard({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.textPrimary : AppColors.borderLight,
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.textWhite : AppColors.textPrimary,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3: MOTIVATION
// ─────────────────────────────────────────────────────────────────────────────
class _MotivationStep extends StatelessWidget {
  const _MotivationStep({
    required this.onNext,
  });

  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("VitaSense users reach their goals 2x faster", style: AppTextStyles.headingLarge),
          SizedBox(height: 48.h),
          Container(
            padding: EdgeInsets.all(24.r),
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("avg results", style: AppTextStyles.bodySmall.copyWith(color: AppColors.textSecondary)),
                    SizedBox(height: 8.h),
                    Container(
                      width: 60.w,
                      height: 80.h,
                      decoration: BoxDecoration(
                        color: AppColors.borderMedium,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text("Without", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("2X", style: AppTextStyles.headingMedium.copyWith(color: AppColors.primary)),
                    SizedBox(height: 8.h),
                    Container(
                      width: 60.w,
                      height: 160.h,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text("With VitaSense", style: AppTextStyles.bodySmall.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          Text(
            "We track your pantry and personalize every meal to your health goals.",
            style: AppTextStyles.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4: GENDER
// ─────────────────────────────────────────────────────────────────────────────
class _GenderStep extends StatelessWidget {
  const _GenderStep({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What's your gender?", style: AppTextStyles.headingLarge),
          SizedBox(height: 8.h),
          Text(
            'This helps us calculate your metabolism',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 48.h),
          _GenderCard(
            label: 'Male',
            icon: Icons.male,
            value: 'male',
            selected: selected == 'male',
            onTap: () => onSelected('male'),
          ),
          SizedBox(height: 12.h),
          _GenderCard(
            label: 'Female',
            icon: Icons.female,
            value: 'female',
            selected: selected == 'female',
            onTap: () => onSelected('female'),
          ),
          SizedBox(height: 12.h),
          _GenderCard(
            label: 'Other',
            icon: Icons.person,
            value: 'other',
            selected: selected == 'other',
            onTap: () => onSelected('other'),
          ),
          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

class _GenderCard extends StatelessWidget {
  const _GenderCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.backgroundWhite,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? AppColors.textWhite : AppColors.textSecondary,
              size: 24.r,
            ),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: selected ? AppColors.textWhite : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle, color: AppColors.textWhite, size: 20.r),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2: AGE
// ─────────────────────────────────────────────────────────────────────────────
class _AgeStep extends StatelessWidget {
  const _AgeStep({
    required this.age,
    required this.onDecrement,
    required this.onIncrement,
    required this.onNext,
  });

  final int age;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How old are you?', style: AppTextStyles.headingLarge),
          SizedBox(height: 8.h),
          Text(
            'Age affects your calorie needs',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 48.h),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: onDecrement,
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: const BoxDecoration(
                      color: AppColors.borderLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.remove,
                      color: AppColors.textPrimary,
                      size: 24.r,
                    ),
                  ),
                ),
                SizedBox(width: 32.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$age',
                      style: TextStyle(
                        fontSize: 72.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'years old',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 32.w),
                GestureDetector(
                  onTap: onIncrement,
                  child: Container(
                    width: 48.r,
                    height: 48.r,
                    decoration: const BoxDecoration(
                      color: AppColors.borderLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.add,
                      color: AppColors.textPrimary,
                      size: 24.r,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3: HEIGHT
// ─────────────────────────────────────────────────────────────────────────────
class _HeightStep extends StatelessWidget {
  const _HeightStep({
    required this.height,
    required this.useCm,
    required this.onToggleUnit,
    required this.onChanged,
    required this.onNext,
  });

  final int height;
  final bool useCm;
  final VoidCallback onToggleUnit;
  final ValueChanged<int> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What's your height?", style: AppTextStyles.headingLarge),
          SizedBox(height: 48.h),
          Center(child: _UnitToggleRow(useCm: useCm, onToggle: onToggleUnit)),
          SizedBox(height: 32.h),
          Center(
            child: Column(
              children: [
                Text(
                  useCm ? '$height' : '${height ~/ 12}\'${height % 12}"',
                  style: TextStyle(
                    fontSize: 72.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  useCm ? 'cm' : 'ft',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 48.h),
          _RulerPicker(
            key: ValueKey(useCm ? 'cm' : 'in'),
            minValue: useCm ? 100 : 40,
            maxValue: useCm ? 250 : 100,
            initialValue: height,
            onChanged: onChanged,
          ),
          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 4: WEIGHT
// ─────────────────────────────────────────────────────────────────────────────
class _WeightStep extends StatelessWidget {
  const _WeightStep({
    required this.weight,
    required this.useKg,
    required this.onToggleUnit,
    required this.onChanged,
    required this.onNext,
  });

  final int weight;
  final bool useKg;
  final VoidCallback onToggleUnit;
  final ValueChanged<int> onChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What's your current weight?", style: AppTextStyles.headingLarge),
          SizedBox(height: 48.h),
          Center(
            child: _UnitToggleRow(
              useCm: useKg,
              labelA: 'kg',
              labelB: 'lbs',
              onToggle: onToggleUnit,
            ),
          ),
          SizedBox(height: 32.h),
          Center(
            child: Column(
              children: [
                Text(
                  '$weight',
                  style: TextStyle(
                    fontSize: 72.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  useKg ? 'kg' : 'lbs',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 48.h),
          _RulerPicker(
            key: ValueKey(useKg ? 'kg' : 'lbs'),
            minValue: useKg ? 30 : 66,
            maxValue: useKg ? 200 : 440,
            initialValue: weight,
            onChanged: onChanged,
          ),
          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 5: GOAL
// ─────────────────────────────────────────────────────────────────────────────
class _GoalStep extends StatelessWidget {
  const _GoalStep({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What's your goal?", style: AppTextStyles.headingLarge),
          SizedBox(height: 8.h),
          Text("We'll personalize your meal plan", style: AppTextStyles.bodyMedium),
          SizedBox(height: 32.h),
          _GoalCard(
            title: 'Lose Weight',
            subtitle: 'Burn fat with smart meals',
            icon: Icons.trending_down,
            value: 'weight_loss',
            selected: selected == 'weight_loss',
            onTap: () => onSelected('weight_loss'),
          ),
          SizedBox(height: 12.h),
          _GoalCard(
            title: 'Gain Weight',
            subtitle: 'Build mass with proper nutrition',
            icon: Icons.trending_up,
            value: 'weight_gain',
            selected: selected == 'weight_gain',
            onTap: () => onSelected('weight_gain'),
          ),
          SizedBox(height: 12.h),
          _GoalCard(
            title: 'Maintain Weight',
            subtitle: 'Stay consistent and healthy',
            icon: Icons.balance,
            value: 'maintain',
            selected: selected == 'maintain',
            onTap: () => onSelected('maintain'),
          ),
          SizedBox(height: 12.h),
          _GoalCard(
            title: 'Build Muscle',
            subtitle: 'High protein meals for growth',
            icon: Icons.fitness_center,
            value: 'muscle_gain',
            selected: selected == 'muscle_gain',
            onTap: () => onSelected('muscle_gain'),
          ),
          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

class _GoalCard extends StatelessWidget {
  const _GoalCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r,
              height: 44.r,
              decoration: BoxDecoration(
                color: selected ? AppColors.primaryLight : AppColors.borderLight,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(
                icon,
                color: selected ? AppColors.primary : AppColors.textSecondary,
                size: 22.r,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            if (selected)
              Icon(
                Icons.check_circle_rounded,
                color: AppColors.primary,
                size: 20.r,
              ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 6: PACE
// ─────────────────────────────────────────────────────────────────────────────
class _PaceStep extends StatelessWidget {
  const _PaceStep({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How fast do you want to reach your goal?',
            style: AppTextStyles.headingLarge,
          ),
          SizedBox(height: 8.h),
          Text('Slower is more sustainable', style: AppTextStyles.bodyMedium),
          SizedBox(height: 32.h),
          _PaceCard(
            title: 'Slow & Steady',
            value: 'slow',
            speed: '~0.25kg/week',
            description: 'More sustainable, easier to maintain',
            selected: selected == 'slow',
            onTap: () => onSelected('slow'),
          ),
          SizedBox(height: 12.h),
          _PaceCard(
            title: 'Moderate',
            value: 'moderate',
            speed: '~0.5kg/week',
            description: 'Balanced approach, recommended',
            selected: selected == 'moderate',
            onTap: () => onSelected('moderate'),
          ),
          SizedBox(height: 12.h),
          _PaceCard(
            title: 'Fast',
            value: 'fast',
            speed: '~0.75kg/week',
            description: 'Requires strict discipline',
            selected: selected == 'fast',
            onTap: () => onSelected('fast'),
          ),
          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

class _PaceCard extends StatelessWidget {
  const _PaceCard({
    required this.title,
    required this.value,
    required this.speed,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String value;
  final String speed;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primaryLight.withValues(alpha: 0.3)
              : AppColors.backgroundWhite,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        speed,
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(
                    Icons.check_circle_rounded,
                    color: AppColors.primary,
                    size: 20.r,
                  ),
              ],
            ),
            SizedBox(height: 4.h),
            Text(
              description,
              style: TextStyle(
                fontSize: 12.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 7: ACTIVITY
// ─────────────────────────────────────────────────────────────────────────────
class _ActivityStep extends StatelessWidget {
  const _ActivityStep({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    final options = [
      (
        'Sedentary',
        'sedentary',
        Icons.chair_outlined,
        'Desk job, little exercise'
      ),
      (
        'Lightly Active',
        'light',
        Icons.directions_walk,
        'Light exercise 1–3x/week'
      ),
      (
        'Moderately Active',
        'moderate',
        Icons.directions_run,
        'Moderate exercise 3–5x/week'
      ),
      (
        'Very Active',
        'active',
        Icons.fitness_center,
        'Hard exercise 6–7x/week'
      ),
      (
        'Extremely Active',
        'very_active',
        Icons.sports,
        'Physical job + daily training'
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How active are you?', style: AppTextStyles.headingLarge),
          SizedBox(height: 8.h),
          Text(
            'This affects your daily calorie target',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 24.h),
          ...options.map(
            (o) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: _GoalCard(
                title: o.$1,
                subtitle: o.$4,
                icon: o.$3,
                value: o.$2,
                selected: selected == o.$2,
                onTap: () => onSelected(o.$2),
              ),
            ),
          ),
          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 8: PREFERENCES
// ─────────────────────────────────────────────────────────────────────────────
class _PreferencesStep extends StatelessWidget {
  const _PreferencesStep({
    required this.allergies,
    required this.cuisines,
    required this.onToggleAllergy,
    required this.onToggleCuisine,
    required this.onNext,
  });

  final List<String> allergies;
  final List<String> cuisines;
  final ValueChanged<String> onToggleAllergy;
  final ValueChanged<String> onToggleCuisine;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final allergyOptions = [
      ('Gluten', 'gluten'),
      ('Lactose', 'lactose'),
      ('Nuts', 'nuts'),
      ('Eggs', 'eggs'),
      ('Fish', 'fish'),
      ('Shellfish', 'shellfish'),
      ('Soy', 'soy'),
    ];

    final cuisineOptions = [
      ('🇵🇱 Polish', 'polish'),
      ('🇮🇹 Italian', 'italian'),
      ('🇯🇵 Japanese', 'japanese'),
      ('🇨🇳 Chinese', 'chinese'),
      ('🇲🇽 Mexican', 'mexican'),
      ('🇮🇳 Indian', 'indian'),
      ('🇬🇷 Greek', 'greek'),
      ('🇹🇭 Thai', 'thai'),
      ('🇺🇸 American', 'american'),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Any allergies or preferences?',
            style: AppTextStyles.headingLarge,
          ),
          SizedBox(height: 8.h),
          Text(
            "We'll avoid these in your meal suggestions",
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 24.h),

          // ALLERGIES
          Text(
            'ALLERGIES',
            style: AppTextStyles.captionBold.copyWith(letterSpacing: 1.2),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: allergyOptions
                .map(
                  (a) => _SelectableChip(
                    label: a.$1,
                    value: a.$2,
                    selected: allergies.contains(a.$2),
                    onTap: () => onToggleAllergy(a.$2),
                  ),
                )
                .toList(),
          ),

          SizedBox(height: 24.h),

          // CUISINES
          Text(
            'FAVORITE CUISINES',
            style: AppTextStyles.captionBold.copyWith(letterSpacing: 1.2),
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: cuisineOptions
                .map(
                  (c) => _SelectableChip(
                    label: c.$1,
                    value: c.$2,
                    selected: cuisines.contains(c.$2),
                    onTap: () => onToggleCuisine(c.$2),
                  ),
                )
                .toList(),
          ),

          SizedBox(height: 40.h),

          _ContinueButton(onPressed: onNext),

          SizedBox(height: 16.h),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

class _SelectableChip extends StatelessWidget {
  const _SelectableChip({
    required this.label,
    required this.value,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String value;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight : AppColors.backgroundWhite,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            color: selected ? AppColors.primary : AppColors.textPrimary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 9: HEALTH CONDITIONS
// ─────────────────────────────────────────────────────────────────────────────
class _HealthConditionsStep extends StatelessWidget {
  const _HealthConditionsStep({
    required this.selected,
    required this.onToggle,
    required this.onNext,
  });

  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    const conditions = [
      ('Post-surgery recovery', 'post_surgery'),
      ('Diabetes', 'diabetes'),
      ('Thyroid issues', 'thyroid'),
      ('Celiac disease', 'celiac'),
      ('IBS', 'ibs'),
      ('Heart condition', 'heart'),
      ('Hypertension', 'hypertension'),
      ('Pregnancy', 'pregnancy'),
      ('None of the above', 'none'),
    ];

    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Any health conditions?', style: AppTextStyles.headingLarge),
          SizedBox(height: 8.h),
          Text(
            "We'll personalize your meals accordingly",
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 32.h),

          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: conditions.map((c) {
              final isSelected = selected.contains(c.$2);
              return GestureDetector(
                onTap: () => onToggle(c.$2),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primaryLight : AppColors.backgroundWhite,
                    border: Border.all(
                      color:
                          isSelected ? AppColors.primary : AppColors.border,
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    c.$1,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.w400,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _ContinueButton extends StatelessWidget {
  const _ContinueButton({required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
          ),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textWhite,
          ),
        ),
      ),
    );
  }
}

// removed _StepButton

class _UnitToggleRow extends StatelessWidget {
  const _UnitToggleRow({
    required this.useCm,
    required this.onToggle,
    this.labelA = 'cm',
    this.labelB = 'ft',
  });

  final bool useCm;
  final VoidCallback onToggle;
  final String labelA;
  final String labelB;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: EdgeInsets.all(4.r),
        decoration: BoxDecoration(
          color: AppColors.borderLight,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ToggleOption(label: labelA, selected: useCm),
            _ToggleOption(label: labelB, selected: !useCm),
          ],
        ),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  const _ToggleOption({required this.label, required this.selected});

  final String label;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: selected ? AppColors.backgroundWhite : Colors.transparent,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: selected
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                )
              ]
            : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          color: selected ? AppColors.textPrimary : AppColors.textMuted,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// EXTRA COMPONENTS (RULER, TARGET WEIGHT, ALMOST DONE)
// ─────────────────────────────────────────────────────────────────────────────

class _TargetWeightStep extends StatelessWidget {
  const _TargetWeightStep({
    required this.targetWeight,
    required this.currentWeight,
    required this.goal,
    required this.useKg,
    required this.onChanged,
    required this.onNext,
  });

  final int targetWeight;
  final int currentWeight;
  final String? goal;
  final bool useKg;
  final ValueChanged<int> onChanged;
  final VoidCallback onNext;

  String get _label {
    int diff = (targetWeight - currentWeight).abs();
    String unit = useKg ? 'kg' : 'lbs';
    if (goal == 'weight_loss') return 'Lose $diff $unit';
    if (goal == 'weight_gain') return 'Gain $diff $unit';
    return 'Maintain';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("What is your target weight?", style: AppTextStyles.headingLarge),
          SizedBox(height: 48.h),
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(100.r),
              ),
              child: Text(
                _label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          Center(
            child: Column(
              children: [
                Text(
                  '$targetWeight',
                  style: TextStyle(
                    fontSize: 72.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  useKg ? 'kg' : 'lbs',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 48.h),
          _RulerPicker(
            key: ValueKey(useKg ? 'kg' : 'lbs'),
            minValue: useKg ? 30 : 66,
            maxValue: useKg ? 200 : 440,
            initialValue: targetWeight,
            onChanged: onChanged,
          ),
          const Spacer(),
          _ContinueButton(onPressed: onNext),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

class _AlmostDoneStep extends StatelessWidget {
  const _AlmostDoneStep({
    required this.sensitiveData,
    required this.tos,
    required this.onSensitiveDataChanged,
    required this.onTosChanged,
    required this.onComplete,
    required this.isLoading,
  });

  final bool sensitiveData;
  final bool tos;
  final ValueChanged<bool?> onSensitiveDataChanged;
  final ValueChanged<bool?> onTosChanged;
  final VoidCallback? onComplete;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 32.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("A few last things", style: AppTextStyles.headingLarge),
          SizedBox(height: 8.h),
          Text("Almost done!", style: AppTextStyles.bodyMedium),
          SizedBox(height: 32.h),
          _CheckboxRow(
            value: sensitiveData,
            onChanged: onSensitiveDataChanged,
            title: 'Sensitive Data Processing',
            subtitle: 'VitaSense processes your health data for personalization.',
          ),
          SizedBox(height: 24.h),
          _CheckboxRow(
            value: tos,
            onChanged: onTosChanged,
            title: 'Terms of Service and Privacy Policy',
            subtitle: 'I agree to the Terms of Service and Privacy Policy.',
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: FilledButton(
              onPressed: (sensitiveData && tos) ? onComplete : null,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                        color: AppColors.textWhite,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Accept & Continue',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textWhite,
                      ),
                    ),
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

class _CheckboxRow extends StatelessWidget {
  const _CheckboxRow({
    required this.value,
    required this.onChanged,
    required this.title,
    required this.subtitle,
  });

  final bool value;
  final ValueChanged<bool?> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24.w,
          height: 24.h,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _RulerPicker extends StatefulWidget {
  final int minValue;
  final int maxValue;
  final int initialValue;
  final ValueChanged<int> onChanged;

  const _RulerPicker({
    super.key,
    required this.minValue,
    required this.maxValue,
    required this.initialValue,
    required this.onChanged,
  });

  @override
  State<_RulerPicker> createState() => _RulerPickerState();
}

class _RulerPickerState extends State<_RulerPicker> {
  late ScrollController _scrollController;
  final double _itemWidth = 14.w;
  late int _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.initialValue;
    if (_currentValue < widget.minValue) _currentValue = widget.minValue;
    if (_currentValue > widget.maxValue) _currentValue = widget.maxValue;
    
    double initialOffset = (_currentValue - widget.minValue) * _itemWidth;
    _scrollController = ScrollController(initialScrollOffset: initialOffset);
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    double offset = _scrollController.offset;
    int newValue = widget.minValue + (offset / _itemWidth).round();
    if (newValue < widget.minValue) newValue = widget.minValue;
    if (newValue > widget.maxValue) newValue = widget.maxValue;
    if (newValue != _currentValue) {
      setState(() => _currentValue = newValue);
      widget.onChanged(newValue);
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 80.h,
      child: LayoutBuilder(
        builder: (context, constraints) {
          double centerOffset = constraints.maxWidth / 2 - (_itemWidth / 2);
          return NotificationListener<ScrollNotification>(
            onNotification: (scrollNotification) {
              if (scrollNotification is ScrollEndNotification) {
                double offset = _scrollController.offset;
                double targetOffset = (offset / _itemWidth).round() * _itemWidth;
                Future.microtask(() {
                  if (_scrollController.hasClients) {
                    _scrollController.animateTo(
                      targetOffset,
                      duration: const Duration(milliseconds: 200),
                      curve: Curves.easeOut,
                    );
                  }
                });
              }
              return true;
            },
            child: ListView.builder(
              controller: _scrollController,
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.maxValue - widget.minValue + 1,
              padding: EdgeInsets.symmetric(horizontal: centerOffset),
              itemBuilder: (context, index) {
                int value = widget.minValue + index;
                bool isFifth = value % 5 == 0;
                bool isSelected = value == _currentValue;

                double height = isFifth ? 40.h : 20.h;
                
                return SizedBox(
                  width: _itemWidth,
                  child: Stack(
                    alignment: Alignment.bottomCenter,
                    clipBehavior: Clip.none,
                    children: [
                      if (isFifth)
                        Positioned(
                          top: 0,
                          child: Text(
                            '$value',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
                              color: isSelected ? AppColors.primary : AppColors.textSecondary,
                            ),
                          ),
                        ),
                      Container(
                        width: isSelected ? 3.w : 2.w,
                        height: height,
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : AppColors.borderMedium,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
