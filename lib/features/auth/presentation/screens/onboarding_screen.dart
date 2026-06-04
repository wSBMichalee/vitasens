import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class _GoalOption {
  final String value;
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  const _GoalOption({
    required this.value,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });
}

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String? _healthGoal;
  final List<String> _selectedStaples = [];

  static const int _totalPages = 6;

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
      );
      setState(() => _currentPage--);
    } else {
      context.pop();
    }
  }

  String _goalDisplayName(String? goal) {
    switch (goal) {
      case 'boost_energy':
        return 'Energy Boost';
      case 'manage_weight':
        return 'Weight Management';
      case 'heart_health':
        return 'Heart Health';
      default:
        return 'Your Goal';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ─── HEADER: hidden on last page ──────────────────────────────
            if (_currentPage < _totalPages - 1)
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 16.h, 24.w, 0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: _previousPage,
                    child: Container(
                      width: 40.r,
                      height: 40.r,
                      decoration: BoxDecoration(
                        color: AppColors.backgroundWhite,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.arrow_back_ios_new,
                          size: 16.r,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: Row(
                      children: List.generate(_totalPages, (i) {
                        return Expanded(
                          child: Container(
                            height: 4.h,
                            margin: EdgeInsets.only(left: i == 0 ? 0 : 4.w),
                            decoration: BoxDecoration(
                              color: i <= _currentPage
                                  ? AppColors.textPrimary
                                  : AppColors.border,
                              borderRadius: BorderRadius.circular(2.r),
                            ),
                          ),
                        );
                      }),
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
                  _WhyVitaSensePage(onNext: _nextPage),
                  _ComparisonPage(onNext: _nextPage),
                  _TransformationPage(onNext: _nextPage),
                  _HealthGoalPage(
                    selected: _healthGoal,
                    onSelected: (v) => setState(() => _healthGoal = v),
                    onNext: _healthGoal != null ? _nextPage : null,
                  ),
                  _KitchenStaplesPage(
                    selected: _selectedStaples,
                    onToggle: (v) => setState(() {
                      _selectedStaples.contains(v)
                          ? _selectedStaples.remove(v)
                          : _selectedStaples.add(v);
                    }),
                    onNext: _nextPage,
                  ),
                  _ReinforcementPage(
                    goalName: _goalDisplayName(_healthGoal),
                    onNext: () => context.go(AppRoutes.paywall),
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

// ─── PAGE 2 (index 1): HEALTH GOAL — Screenshot 1 ────────────────────────────
class _HealthGoalPage extends StatelessWidget {
  const _HealthGoalPage({
    required this.selected,
    required this.onSelected,
    required this.onNext,
  });

  final String? selected;
  final ValueChanged<String> onSelected;
  final VoidCallback? onNext;

  static const List<_GoalOption> _goals = [
    _GoalOption(
      value: 'boost_energy',
      title: 'Boost daily energy',
      subtitle: 'Avoid the afternoon sugar crash',
      icon: Icons.battery_charging_full,
      iconColor: AppColors.secondary,
      iconBgColor: AppColors.secondaryLight,
    ),
    _GoalOption(
      value: 'manage_weight',
      title: 'Manage weight',
      subtitle: 'Balanced meals with full nutrition',
      icon: Icons.balance,
      iconColor: AppColors.primary,
      iconBgColor: AppColors.primaryLight,
    ),
    _GoalOption(
      value: 'heart_health',
      title: 'Heart health',
      subtitle: 'Low-sodium, nutrient-dense choices',
      icon: Icons.favorite_border,
      iconColor: AppColors.warning,
      iconBgColor: AppColors.warningLight,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "What's your primary\nhealth goal?",
            style: AppTextStyles.headingXL,
          ),
          SizedBox(height: 8.h),
          Text(
            'This helps us prioritize the right\ningredients for your meals.',
            style: AppTextStyles.bodyMedium,
          ),
          SizedBox(height: 32.h),
          for (int i = 0; i < _goals.length; i++) ...[
            _HealthGoalCard(
              goal: _goals[i],
              selected: selected == _goals[i].value,
              onTap: () => onSelected(_goals[i].value),
            ),
            if (i < _goals.length - 1) SizedBox(height: 12.h),
          ],
          const Spacer(),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.backgroundDark,
                disabledBackgroundColor:
                    AppColors.backgroundDark.withValues(alpha: 0.4),
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
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(begin: 0.05, end: 0);
  }
}

class _HealthGoalCard extends StatelessWidget {
  const _HealthGoalCard({
    required this.goal,
    required this.selected,
    required this.onTap,
  });

  final _GoalOption goal;
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
            color: selected ? AppColors.secondary : AppColors.border,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 48.r,
              height: 48.r,
              decoration: BoxDecoration(
                color: goal.iconBgColor,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(goal.icon, color: goal.iconColor, size: 24.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    goal.title,
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    goal.subtitle,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22.r,
              height: 22.r,
              decoration: BoxDecoration(
                color: selected ? AppColors.secondary : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected ? AppColors.secondary : AppColors.borderMedium,
                  width: 2,
                ),
              ),
              child: selected
                  ? Center(
                      child: Icon(Icons.check, color: Colors.white, size: 12.r),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── PAGE 1 (index 0): THE TRANSFORMATION — Screenshot 3 ────────────────────
class _TransformationPage extends StatelessWidget {
  const _TransformationPage({required this.onNext});

  final VoidCallback onNext;

  // Replace with real CDN/asset URLs before release
  static const String _beforeImageUrl =
      'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=800&q=80';
  static const String _afterImageUrl =
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800&q=80';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Heading ───────────────────────────────────────────────────
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The Transformation', style: AppTextStyles.headingXL),
              SizedBox(height: 8.h),
              Text(
                'See what changes when you cook smarter.',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          SizedBox(height: 24.h),

          // ─── BEFORE card ───────────────────────────────────────────────
          const _TransformationCard(
            imageUrl: _beforeImageUrl,
            label: 'BEFORE',
            labelColor: AppColors.error,
            grayscale: true,
            showAiBadge: false,
            bullets: [
              (Icons.sentiment_dissatisfied, 'Staring at your fridge',
                  AppColors.error),
              (Icons.help_outline, 'Eating random meals', AppColors.error),
              (Icons.battery_alert, 'Feeling tired or unsure', AppColors.error),
            ],
          ).animate(delay: 80.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          SizedBox(height: 16.h),

          // ─── AFTER card ────────────────────────────────────────────────
          const _TransformationCard(
            imageUrl: _afterImageUrl,
            label: 'AFTER',
            labelColor: AppColors.primary,
            grayscale: false,
            showAiBadge: true,
            bullets: [
              (Icons.calendar_today, 'Clear meal plan', AppColors.primary),
              (Icons.restaurant, 'Delicious, healthy food', AppColors.primary),
              (Icons.bolt, 'Full of energy all day', AppColors.primary),
            ],
          ).animate(delay: 160.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

          SizedBox(height: 28.h),

          // ─── CTA ────────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.backgroundDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'See My Plan',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ).animate(delay: 240.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

class _TransformationCard extends StatelessWidget {
  const _TransformationCard({
    required this.imageUrl,
    required this.label,
    required this.labelColor,
    required this.grayscale,
    required this.showAiBadge,
    required this.bullets,
  });

  final String imageUrl;
  final String label;
  final Color labelColor;
  final bool grayscale;
  final bool showAiBadge;
  final List<(IconData, String, Color)> bullets;

  static const _grayscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0,      0,      0,      1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Photo ────────────────────────────────────────────────────
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(16.r)),
            child: SizedBox(
              height: 160.h,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Image (optionally grayscale)
                  ColorFiltered(
                    colorFilter: grayscale
                        ? const ColorFilter.matrix(_grayscaleMatrix)
                        : const ColorFilter.mode(
                            Colors.transparent, BlendMode.color),
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Shimmer.fromColors(
                        baseColor: AppColors.border,
                        highlightColor: AppColors.borderLight,
                        child: Container(color: AppColors.border),
                      ),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.border,
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          color: AppColors.textMuted,
                          size: 32.r,
                        ),
                      ),
                    ),
                  ),

                  // Dark overlay for readability
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.black26, Colors.transparent],
                        stops: [0.0, 0.5],
                      ),
                    ),
                  ),

                  // BEFORE / AFTER badge
                  Positioned(
                    top: 12.h,
                    left: 12.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.w, vertical: 5.h),
                      decoration: BoxDecoration(
                        color: labelColor,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ),
                  ),

                  // AI sparkle badge (AFTER only)
                  if (showAiBadge)
                    Positioned(
                      top: 12.h,
                      right: 12.w,
                      child: Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.08),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.auto_awesome,
                          color: AppColors.primary,
                          size: 16.r,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          // ─── Bullet points ────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 4.h),
            child: Column(
              children: [
                for (int i = 0; i < bullets.length; i++) ...[
                  Row(
                    children: [
                      Container(
                        width: 32.r,
                        height: 32.r,
                        decoration: BoxDecoration(
                          color: bullets[i].$3.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          bullets[i].$1,
                          color: bullets[i].$3,
                          size: 16.r,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          bullets[i].$2,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (i < bullets.length - 1) SizedBox(height: 12.h),
                ],
              ],
            ),
          ),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }
}

// ─── PAGE 3 (index 2): KITCHEN STAPLES — Screenshot 3 ───────────────────────
class _KitchenStaplesPage extends StatelessWidget {
  const _KitchenStaplesPage({
    required this.selected,
    required this.onToggle,
    required this.onNext,
  });

  final List<String> selected;
  final ValueChanged<String> onToggle;
  final VoidCallback onNext;

  static const List<(String, String)> _categories = [
    ('🥩', 'Proteins'),
    ('🥬', 'Leafy Greens'),
    ('🥔', 'Root Veggies'),
    ('🍚', 'Grains'),
    ('🥚', 'Eggs & Dairy'),
    ('🍝', 'Pasta'),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What do you usually\nhave at home?',
            style: AppTextStyles.headingXL,
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
          SizedBox(height: 8.h),
          Text(
            'Select the staples usually found in your kitchen.',
            style: AppTextStyles.bodyMedium,
          ).animate().fadeIn(duration: 300.ms),
          SizedBox(height: 28.h),

          // 2-column grid
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 12.w,
              mainAxisSpacing: 12.h,
              childAspectRatio: 1.1,
              physics: const NeverScrollableScrollPhysics(),
              children: _categories.map((c) {
                final isSelected = selected.contains(c.$2);
                return GestureDetector(
                  onTap: () => onToggle(c.$2),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primaryLight
                          : AppColors.backgroundWhite,
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.border,
                        width: isSelected ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(c.$1,
                            style: TextStyle(fontSize: 36.sp)),
                        SizedBox(height: 12.h),
                        Text(
                          c.$2,
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.backgroundDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'Find My Meals',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 300.ms),
        ],
      ),
    );
  }
}

// ─── PAGE 4 (index 3): WE'VE GOT THIS! — Screenshot 2 ───────────────────────
class _ReinforcementPage extends StatelessWidget {
  const _ReinforcementPage({
    required this.goalName,
    required this.onNext,
  });

  final String goalName;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 24.h),
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // ─── Party popper icon ───────────────────────────────────
                  Container(
                    width: 88.r,
                    height: 88.r,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryLight,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.celebration,
                      color: AppColors.primary,
                      size: 44.r,
                    ),
                  )
                      .animate()
                      .fadeIn(duration: 400.ms)
                      .scale(begin: const Offset(0.8, 0.8), duration: 400.ms),

                  SizedBox(height: 28.h),

                  // ─── Heading ─────────────────────────────────────────────
                  Text(
                    "We've got this!",
                    style: TextStyle(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 80.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  SizedBox(height: 16.h),

                  // ─── Description ─────────────────────────────────────────
                  Text(
                    "Based on your pantry and $goalName goals, we've unlocked 24 new meal options that will keep you on track without buying a single new item.",
                    style: TextStyle(
                      fontSize: 15.sp,
                      color: AppColors.textSecondary,
                      height: 1.55,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(delay: 160.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),

                  SizedBox(height: 32.h),

                  // ─── Summary card ─────────────────────────────────────────
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        horizontal: 20.w, vertical: 16.h),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      border: Border.all(color: AppColors.border),
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    child: Column(
                      children: [
                        _infoRow(
                          'Goal',
                          goalName,
                          valueColor: AppColors.secondary,
                        ),
                        Divider(
                            color: AppColors.border, height: 24.h, thickness: 1),
                        _infoRow('Ingredients found', '12 Items'),
                        Divider(
                            color: AppColors.border, height: 24.h, thickness: 1),
                        _infoRow('Personalized meals', '24 Options'),
                      ],
                    ),
                  )
                      .animate(delay: 240.ms)
                      .fadeIn(duration: 400.ms)
                      .slideY(begin: 0.1, end: 0),
                ],
              ),
            ),

            // ─── CTA ─────────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 56.h,
              child: FilledButton(
                onPressed: onNext,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: Text(
                  'See My Meal Plan',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ).animate(delay: 320.ms).fadeIn(duration: 400.ms),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── PAGE 0 (index 0): WHY VITASENSE? ────────────────────────────────────────
class _WhyVitaSensePage extends StatelessWidget {
  const _WhyVitaSensePage({required this.onNext});
  final VoidCallback onNext;

  static const String _heroImageUrl =
      'https://images.unsplash.com/photo-1512941937669-90a1b58e7e9c?w=1200&q=80';

  static const List<(IconData, Color, Color, String, String)> _features = [
    (
      Icons.kitchen_outlined,
      AppColors.primaryLight,
      AppColors.primary,
      'Use what you already have',
      'We turn your fridge into ready-to-cook meals',
    ),
    (
      Icons.monitor_heart_outlined,
      AppColors.secondaryLight,
      AppColors.secondary,
      'Eat for your health',
      'Meals tailored to your condition and goals',
    ),
    (
      Icons.task_alt_outlined,
      AppColors.borderLight,
      AppColors.textSecondary,
      'No more guessing',
      'Know exactly what to cook every day',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Hero image
        SizedBox(
          height: 200.h,
          width: double.infinity,
          child: CachedNetworkImage(
            imageUrl: _heroImageUrl,
            fit: BoxFit.cover,
            placeholder: (_, __) => Shimmer.fromColors(
              baseColor: AppColors.border,
              highlightColor: AppColors.borderLight,
              child: Container(color: AppColors.border),
            ),
            errorWidget: (_, __, ___) =>
                Container(color: AppColors.secondaryLight),
          ),
        ).animate().fadeIn(duration: 500.ms),

        Expanded(
          child: Padding(
            padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 24.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why VitaSense?',
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: AppTextStyles.headingXL.fontFamily,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),

                SizedBox(height: 20.h),

                Expanded(
                  child: Column(
                    children: List.generate(_features.length, (i) {
                      final f = _features[i];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: Container(
                          padding: EdgeInsets.all(16.r),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(16.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 48.r,
                                height: 48.r,
                                decoration: BoxDecoration(
                                  color: f.$2,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(f.$1, color: f.$3, size: 24.r),
                              ),
                              SizedBox(width: 14.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      f.$4,
                                      style: TextStyle(
                                        fontSize: 15.sp,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textPrimary,
                                      ),
                                    ),
                                    SizedBox(height: 3.h),
                                    Text(
                                      f.$5,
                                      style: TextStyle(
                                        fontSize: 13.sp,
                                        color: AppColors.textSecondary,
                                        height: 1.4,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ).animate(delay: Duration(milliseconds: 80 + i * 80))
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.08, end: 0);
                    }),
                  ),
                ),

                SizedBox(
                  width: double.infinity,
                  height: 56.h,
                  child: FilledButton(
                    onPressed: onNext,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.backgroundDark,
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
                ).animate(delay: 320.ms).fadeIn(duration: 400.ms),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── PAGE 1 (index 1): COOKING MADE SIMPLE ───────────────────────────────────
class _ComparisonPage extends StatelessWidget {
  const _ComparisonPage({required this.onNext});
  final VoidCallback onNext;

  static const String _beforeImageUrl =
      'https://images.unsplash.com/photo-1556909114-f6e7ad7d3136?w=600&q=80';
  static const String _afterImageUrl =
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=600&q=80';

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(24.w, 32.h, 24.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cooking made simple.',
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              fontFamily: AppTextStyles.headingXL.fontFamily,
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),

          SizedBox(height: 6.h),
          Text(
            'Stop guessing. Start eating better.',
            style: AppTextStyles.bodyMedium,
          ).animate().fadeIn(duration: 400.ms),

          SizedBox(height: 24.h),

          // WITHOUT card
          const _ComparisonCard(
            label: 'WITHOUT VITASENSE',
            labelColor: AppColors.error,
            imageUrl: _beforeImageUrl,
            title: 'Decision Fatigue',
            subtitle: 'Staring at the fridge, ordering takeout again.',
            hasBorder: false,
          ),

          SizedBox(height: 12.h),

          // WITH card
          const _ComparisonCard(
            label: 'WITH VITASENSE',
            labelColor: AppColors.primary,
            imageUrl: _afterImageUrl,
            title: 'Total Clarity',
            subtitle: '3 clicks to find a perfect meal with your ingredients.',
            hasBorder: true,
          ),

          const Spacer(),

          SizedBox(
            width: double.infinity,
            height: 56.h,
            child: FilledButton(
              onPressed: onNext,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.backgroundDark,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              child: Text(
                'See My Results',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ).animate(delay: 240.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.label,
    required this.labelColor,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.hasBorder,
  });

  final String label;
  final Color labelColor;
  final String imageUrl;
  final String title;
  final String subtitle;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        border: Border.all(
          color: hasBorder ? AppColors.primary : AppColors.border,
          width: hasBorder ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10.r),
            child: SizedBox(
              width: 72.r,
              height: 72.r,
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (_, __) => Shimmer.fromColors(
                  baseColor: AppColors.border,
                  highlightColor: AppColors.borderLight,
                  child: Container(color: AppColors.border),
                ),
                errorWidget: (_, __, ___) =>
                    Container(color: AppColors.borderLight),
              ),
            ),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: labelColor,
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
