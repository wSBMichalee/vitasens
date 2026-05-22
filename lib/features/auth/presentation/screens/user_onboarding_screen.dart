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
  String? _gender;
  int _age = 25;
  double _height = 170;
  double _weight = 70;
  bool _useCm = true;
  bool _useKg = true;
  String? _goal;
  String? _pace;
  String? _activity;
  final List<String> _allergies = [];
  final List<String> _cuisines = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 7) {
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
        'gender': _gender,
        'age': _age,
        'weight_kg': _useKg ? _weight : _weight * 0.453592,
        'height_cm': _useCm ? _height : _height * 30.48,
        'goal_type': _goal,
        'goal_pace': _pace,
        'activity_level': _activity,
        'allergies': _allergies,
        'favorite_cuisines': _cuisines,
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
      backgroundColor: AppColors.background,
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
                      child: Padding(
                        padding: EdgeInsets.only(right: 16.w),
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          color: AppColors.textPrimary,
                          size: 20.r,
                        ),
                      ),
                    ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(
                        begin: 0,
                        end: (_currentStep + 1) / 8,
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
                    '${_currentStep + 1}/8',
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
                    onToggleUnit: () => setState(() => _useCm = !_useCm),
                    onDecrement: () => setState(() => _height--),
                    onIncrement: () => setState(() => _height++),
                    onNext: _nextStep,
                  ),
                  _WeightStep(
                    weight: _weight,
                    useKg: _useKg,
                    onToggleUnit: () => setState(() => _useKg = !_useKg),
                    onDecrement: () {
                      if (_weight > 1) setState(() => _weight--);
                    },
                    onIncrement: () => setState(() => _weight++),
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
// STEP 1: GENDER
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
          color: selected ? AppColors.primary : Colors.white,
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.border,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: selected ? Colors.white : AppColors.textSecondary,
              size: 24.r,
            ),
            SizedBox(width: 16.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: selected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const Spacer(),
            if (selected)
              Icon(Icons.check_circle, color: Colors.white, size: 20.r),
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
    required this.onDecrement,
    required this.onIncrement,
    required this.onNext,
  });

  final double height;
  final bool useCm;
  final VoidCallback onToggleUnit;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onNext;

  String get _displayHeight {
    if (useCm) return height.toStringAsFixed(0);
    final totalInches = height / 2.54;
    final feet = (totalInches / 12).floor();
    final inches = (totalInches % 12).round();
    return "$feet'$inches\"";
  }

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepButton(icon: Icons.remove, onTap: onDecrement),
                SizedBox(width: 32.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _displayHeight,
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
                SizedBox(width: 32.w),
                _StepButton(icon: Icons.add, onTap: onIncrement),
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
// STEP 4: WEIGHT
// ─────────────────────────────────────────────────────────────────────────────
class _WeightStep extends StatelessWidget {
  const _WeightStep({
    required this.weight,
    required this.useKg,
    required this.onToggleUnit,
    required this.onDecrement,
    required this.onIncrement,
    required this.onNext,
  });

  final double weight;
  final bool useKg;
  final VoidCallback onToggleUnit;
  final VoidCallback onDecrement;
  final VoidCallback onIncrement;
  final VoidCallback onNext;

  String get _displayWeight {
    if (useKg) return weight.toStringAsFixed(0);
    return (weight / 0.453592).toStringAsFixed(0);
  }

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
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _StepButton(icon: Icons.remove, onTap: onDecrement),
                SizedBox(width: 32.w),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _displayWeight,
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
                SizedBox(width: 32.w),
                _StepButton(icon: Icons.add, onTap: onIncrement),
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
          color: Colors.white,
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
              : Colors.white,
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
    required this.onComplete,
    required this.isLoading,
  });

  final List<String> allergies;
  final List<String> cuisines;
  final ValueChanged<String> onToggleAllergy;
  final ValueChanged<String> onToggleCuisine;
  final VoidCallback? onComplete;
  final bool isLoading;

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

          // COMPLETE BUTTON
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: FilledButton(
              onPressed: onComplete,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: isLoading
                  ? SizedBox(
                      width: 22.r,
                      height: 22.r,
                      child: const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : Text(
                      'Complete Setup',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),

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
          color: selected ? AppColors.primaryLight : Colors.white,
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
            borderRadius: BorderRadius.circular(16.r),
          ),
        ),
        child: Text(
          'Continue',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48.r,
        height: 48.r,
        decoration: const BoxDecoration(
          color: AppColors.borderLight,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: AppColors.textPrimary, size: 24.r),
      ),
    );
  }
}

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
        color: selected ? Colors.white : Colors.transparent,
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
