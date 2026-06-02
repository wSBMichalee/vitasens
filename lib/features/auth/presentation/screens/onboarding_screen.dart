import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  void _previousPage() {
    if (_pageController.page != null && _pageController.page! > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
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
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) => setState(() => _currentPage = index),
                children: [
                  const _TransformationPage(),
                  _ValueExplanationPage(onBack: _previousPage),
                  _SocialProofPage(onBack: _previousPage),
                  _ReinforcementPage(onBack: _previousPage),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 16.h, bottom: 8.h),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: 4,
                effect: WormEffect(
                  dotColor: AppColors.border,
                  activeDotColor: AppColors.primary,
                  dotHeight: 8.r,
                  dotWidth: 8.r,
                ),
              ),
            ),
            _currentPage < 3
                ? const _SwipeHint()
                : const SizedBox.shrink(),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}

// === SWIPE HINT ===
class _SwipeHint extends StatelessWidget {
  const _SwipeHint();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Swipe to continue',
          style: TextStyle(fontSize: 12.sp, color: AppColors.textMuted),
        ),
        SizedBox(width: 4.w),
        Icon(Icons.arrow_forward_ios, color: AppColors.textMuted, size: 12.r),
      ],
    )
        .animate(onPlay: (c) => c.repeat())
        .fadeIn(duration: 600.ms)
        .then()
        .fadeOut(duration: 600.ms);
  }
}

// === STRONA 1: The Transformation ===
class _TransformationPage extends StatelessWidget {
  const _TransformationPage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 32.0.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The Transformation', style: AppTextStyles.headingXL),
              SizedBox(height: 8.h),
              Text(
                'Experience the difference in your kitchen.',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

          SizedBox(height: 32.h),

          // BEFORE Karta
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0.r),
              child: Column(
                children: [
                  Container(
                    height: 140.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'BEFORE',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textWhite),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildListItem(Icons.sentiment_dissatisfied, 'Staring at your fridge', AppColors.error),
                  _buildListItem(Icons.help_outline, 'Eating random meals', AppColors.error),
                  _buildListItem(Icons.battery_alert, 'Feeling tired or unsure', AppColors.error),
                ],
              ),
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

          SizedBox(height: 24.h),

          // AFTER Karta
          Card(
            child: Padding(
              padding: EdgeInsets.all(16.0.r),
              child: Column(
                children: [
                  Container(
                    height: 140.h,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Text(
                              'AFTER',
                              style: AppTextStyles.labelSmall.copyWith(color: AppColors.textWhite),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 12,
                          right: 12,
                          child: Container(
                            padding: EdgeInsets.all(6.r),
                            decoration: const BoxDecoration(
                              color: AppColors.backgroundWhite,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.auto_awesome, color: AppColors.primary, size: 16.r),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 24.h),
                  _buildListItem(Icons.calendar_today, 'Clear meal plan', AppColors.primary),
                  _buildListItem(Icons.restaurant, 'Delicious, healthy food', AppColors.primary),
                  _buildListItem(Icons.bolt, 'Full of energy all day', AppColors.primary),
                ],
              ),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24.r),
          SizedBox(width: 16.w),
          Expanded(
            child: Text(text, style: AppTextStyles.bodyLarge),
          ),
        ],
      ),
    );
  }
}

// === STRONA 2: "Why VitaSense?" ===
class _ValueExplanationPage extends StatelessWidget {
  final VoidCallback onBack;

  const _ValueExplanationPage({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(24.0.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(Icons.chevron_left, size: 28.r),
          ),
          SizedBox(height: 16.h),
          Container(
            height: 200.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

          Container(
            margin: const EdgeInsets.only(top: 24),
            child: Text(
              'Why VitaSense?',
              style: TextStyle(
                fontSize: 28.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontFamily: AppTextStyles.headingXL.fontFamily,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

          SizedBox(height: 24.h),

          _buildFeatureCard(
            icon: Icons.kitchen,
            iconColor: AppColors.primary,
            iconBgColor: AppColors.primaryLight,
            title: 'Use what you already have',
            desc: 'We turn your fridge into ready-to-cook meals',
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

          SizedBox(height: 12.h),

          _buildFeatureCard(
            icon: Icons.monitor_heart,
            iconColor: AppColors.secondary,
            iconBgColor: AppColors.secondaryLight,
            title: 'Eat for your health',
            desc: 'Meals tailored to your condition and goals',
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

          SizedBox(height: 12.h),

          _buildFeatureCard(
            icon: Icons.check_circle_outline,
            iconColor: AppColors.textSecondary,
            iconBgColor: AppColors.borderLight,
            title: 'No more guessing',
            desc: 'Know exactly what to cook every day',
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String desc,
  }) {
    return Container(
      padding: EdgeInsets.all(16.0.r),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: iconColor, size: 24.r),
          ),
          SizedBox(width: 16.w),
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
                    fontFamily: AppTextStyles.bodyLarge.fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                    fontFamily: AppTextStyles.bodyMedium.fontFamily,
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

// === STRONA 3: "50,000+" ===
class _SocialProofPage extends StatelessWidget {
  final VoidCallback onBack;

  const _SocialProofPage({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.0.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: Icon(Icons.chevron_left, size: 28.r),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: SizedBox(
                      width: 40.w + (3 * 28),
                      height: 40.h,
                      child: Stack(
                        children: [
                          Positioned(left: 0, child: _buildAvatarColor(AppColors.primary)),
                          Positioned(left: 28, child: _buildAvatarColor(AppColors.secondary)),
                          Positioned(left: 56, child: _buildAvatarColor(AppColors.warning)),
                          Positioned(left: 84, child: _buildCountAvatar('+12k')),
                        ],
                      ),
                    ),
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Text(
                    '50,000+',
                    style: TextStyle(
                      fontSize: 48.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.secondary,
                      fontFamily: AppTextStyles.numberXL.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Join thousands of people eating smarter',
                    style: TextStyle(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textPrimary,
                      fontFamily: AppTextStyles.headingLarge.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                Container(
                  margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: Text(
                    'People are already using VitaSense to cook\nbetter meals from what they have',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppColors.textSecondary,
                      fontFamily: AppTextStyles.bodyMedium.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) => Icon(Icons.star, color: AppColors.warning, size: 16.r)),
                      ),
                      SizedBox(height: 12.h),
                      Text(
                        '"I stopped wasting groceries and started\nfeeling so much more energetic. VitaSense\nliterally told me what to do with my\nleftover kale and salmon."',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textPrimary,
                          fontStyle: FontStyle.italic,
                          fontFamily: AppTextStyles.bodyMedium.fontFamily,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '— SARAH M., LONDON',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.5,
                          fontFamily: AppTextStyles.caption.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: AppColors.error,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        'LIMITED-TIME ACCESS TO FULL PLAN',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: AppColors.textSecondary,
                          letterSpacing: 1.0,
                          fontFamily: AppTextStyles.caption.fontFamily,
                        ),
                      ),
                    ],
                  ),
                ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarColor(Color color) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.w),
      ),
    );
  }

  Widget _buildCountAvatar(String text) {
    return Container(
      width: 40.w,
      height: 40.h,
      decoration: BoxDecoration(
        color: AppColors.secondary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2.w),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          fontFamily: AppTextStyles.labelSmall.fontFamily,
        ),
      ),
    );
  }
}

// === STRONA 4: "We've got this!" ===
class _ReinforcementPage extends StatelessWidget {
  final VoidCallback onBack;

  const _ReinforcementPage({required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(24.0.r),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Icon(Icons.chevron_left, size: 28.r),
            ),
          ),

          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 48.h),

                Container(
                  width: 80.w,
                  height: 80.h,
                  decoration: const BoxDecoration(
                    color: AppColors.primaryLight,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.celebration, color: AppColors.primary, size: 40.r),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                SizedBox(height: 24.h),

                Text(
                  "We've got this!",
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                    fontFamily: AppTextStyles.headingXL.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                SizedBox(height: 16.h),

                Text(
                  "Based on your pantry and weight goals,\nwe've unlocked 24 new meal options that\nwill keep you on track without buying\na single new item.",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                    height: 1.5,
                    fontFamily: AppTextStyles.bodyLarge.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                SizedBox(height: 32.h),

                Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Column(
                    children: [
                      _infoRow("Goal", "Weight Management", valueColor: AppColors.secondary),
                      Divider(color: AppColors.border, height: 20.h),
                      _infoRow("Ingredients found", "12 Items"),
                      Divider(color: AppColors.border, height: 20.h),
                      _infoRow("Personalized meals", "24 Options"),
                    ],
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
              ],
            ),
          ),

          SizedBox(
            height: 56.h,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.r),
                ),
              ),
              onPressed: () => context.go(AppRoutes.paywall),
              child: const Text('See My Meal Plan'),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

          SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value, {Color? valueColor}) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            color: AppColors.textSecondary,
            fontFamily: AppTextStyles.bodyMedium.fontFamily,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
            fontFamily: AppTextStyles.labelMedium.fontFamily,
          ),
        ),
      ],
    );
  }
}
