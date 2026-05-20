import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();

  void _nextPage() {
    if (_pageController.page != null && _pageController.page! < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOutCubic,
      );
    } else {
      context.go(AppRoutes.paywall);
    }
  }

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
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            _TransformationPage(onNext: _nextPage),
            _ValueExplanationPage(onNext: _nextPage, onBack: _previousPage),
            _SocialProofPage(onNext: _nextPage, onBack: _previousPage),
            _ReinforcementPage(onNext: _nextPage, onBack: _previousPage),
          ],
        ),
      ),
    );
  }
}

// === STRONA 1: The Transformation ===
class _TransformationPage extends StatelessWidget {
  final VoidCallback onNext;

  const _TransformationPage({required this.onNext});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('The Transformation', style: AppTextStyles.headingXL),
              const SizedBox(height: 8),
              Text(
                'Experience the difference in your kitchen.',
                style: AppTextStyles.bodyMedium,
              ),
            ],
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
          
          const SizedBox(height: 32),

          // BEFORE Karta
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              borderRadius: BorderRadius.circular(20),
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
                  const SizedBox(height: 24),
                  _buildListItem(Icons.sentiment_dissatisfied, 'Staring at your fridge', AppColors.error),
                  _buildListItem(Icons.help_outline, 'Eating random meals', AppColors.error),
                  _buildListItem(Icons.battery_alert, 'Feeling tired or unsure', AppColors.error),
                ],
              ),
            ),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

          const SizedBox(height: 24),

          // AFTER Karta
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(20),
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
                            padding: const EdgeInsets.all(6),
                            decoration: const BoxDecoration(
                              color: AppColors.backgroundWhite,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.auto_awesome, color: AppColors.primary, size: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildListItem(Icons.calendar_today, 'Clear meal plan', AppColors.primary),
                  _buildListItem(Icons.restaurant, 'Delicious, healthy food', AppColors.primary),
                  _buildListItem(Icons.bolt, 'Full of energy all day', AppColors.primary),
                ],
              ),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

          const SizedBox(height: 32),

          ElevatedButton(
            onPressed: onNext,
            child: const Text('See My Plan'),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildListItem(IconData icon, String text, Color iconColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 16),
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
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _ValueExplanationPage({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.chevron_left, size: 28),
          ),
          const SizedBox(height: 16),
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: const Color(0xFFE5E7EB),
              borderRadius: BorderRadius.circular(16),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
          
          Container(
            margin: const EdgeInsets.only(top: 24),
            child: Text(
              'Why VitaSense?',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
                fontFamily: AppTextStyles.headingXL.fontFamily,
              ),
            ),
          ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
          
          const SizedBox(height: 24),

          _buildFeatureCard(
            icon: Icons.kitchen,
            iconColor: const Color(0xFF22C55E),
            iconBgColor: const Color(0xFFDCFCE7),
            title: 'Use what you already have',
            desc: 'We turn your fridge into ready-to-cook meals',
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
          
          const SizedBox(height: 12),

          _buildFeatureCard(
            icon: Icons.monitor_heart,
            iconColor: const Color(0xFF3B82F6),
            iconBgColor: const Color(0xFFEFF6FF),
            title: 'Eat for your health',
            desc: 'Meals tailored to your condition and goals',
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
          
          const SizedBox(height: 12),

          _buildFeatureCard(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF6B7280),
            iconBgColor: const Color(0xFFF3F4F6),
            title: 'No more guessing',
            desc: 'Know exactly what to cook every day',
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
          
          const SizedBox(height: 32),

          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onNext,
              child: const Text('Continue'),
            ),
          ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
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
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE5E7EB)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF111827),
                    fontFamily: AppTextStyles.bodyLarge.fontFamily,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 14,
                    color: const Color(0xFF6B7280),
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
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _SocialProofPage({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: onBack,
            child: const Icon(Icons.chevron_left, size: 28),
          ),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  child: Center(
                    child: SizedBox(
                      width: 40 + (3 * 28),
                      height: 40,
                      child: Stack(
                        children: [
                          Positioned(left: 0, child: _buildAvatarColor(const Color(0xFF22C55E))),
                          Positioned(left: 28, child: _buildAvatarColor(const Color(0xFF3B82F6))),
                          Positioned(left: 56, child: _buildAvatarColor(const Color(0xFFF59E0B))),
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
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3B82F6),
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
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      fontFamily: AppTextStyles.headingLarge.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(
                    'People are already using VitaSense to cook\nbetter meals from what they have',
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                      fontFamily: AppTextStyles.bodyMedium.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: List.generate(5, (index) => const Icon(Icons.star, color: Color(0xFFF59E0B), size: 16)),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"I stopped wasting groceries and started\nfeeling so much more energetic. VitaSense\nliterally told me what to do with my\nleftover kale and salmon."',
                        style: TextStyle(
                          fontSize: 14,
                          color: const Color(0xFF111827),
                          fontStyle: FontStyle.italic,
                          fontFamily: AppTextStyles.bodyMedium.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '— SARAH M., LONDON',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
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
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFFEF4444),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'LIMITED-TIME ACCESS TO FULL PLAN',
                        style: TextStyle(
                          fontSize: 11,
                          color: const Color(0xFF6B7280),
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
          
          SizedBox(
            height: 56,
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F2937),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: onNext,
              child: const Text('Unlock My Plan'),
            ),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
        ],
      ),
    );
  }

  Widget _buildAvatarColor(Color color) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  Widget _buildCountAvatar(String text) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: const Color(0xFF3B82F6),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          fontFamily: AppTextStyles.labelSmall.fontFamily,
        ),
      ),
    );
  }
}

// === STRONA 4: "We've got this!" ===
class _ReinforcementPage extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;

  const _ReinforcementPage({required this.onNext, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: const Icon(Icons.chevron_left, size: 28),
            ),
          ),
          
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),

                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.celebration, color: Color(0xFF22C55E), size: 40),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                const SizedBox(height: 24),

                Text(
                  "We've got this!",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF111827),
                    fontFamily: AppTextStyles.headingXL.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                const SizedBox(height: 16),

                Text(
                  "Based on your pantry and weight goals,\nwe've unlocked 24 new meal options that\nwill keep you on track without buying\na single new item.",
                  style: TextStyle(
                    fontSize: 16,
                    color: const Color(0xFF6B7280),
                    height: 1.5,
                    fontFamily: AppTextStyles.bodyLarge.fontFamily,
                  ),
                  textAlign: TextAlign.center,
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

                const SizedBox(height: 32),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE5E7EB)),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      _infoRow("Goal", "Weight Management", valueColor: const Color(0xFF3B82F6)),
                      const Divider(color: Color(0xFFE5E7EB), height: 20),
                      _infoRow("Ingredients found", "12 Items"),
                      const Divider(color: Color(0xFFE5E7EB), height: 20),
                      _infoRow("Personalized meals", "24 Options"),
                    ],
                  ),
                ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),
              ],
            ),
          ),

          SizedBox(
            height: 56,
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF22C55E),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () => context.go(AppRoutes.paywall),
              child: const Text('See My Meal Plan'),
            ),
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

          const SizedBox(height: 16),
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
            fontSize: 14,
            color: const Color(0xFF6B7280),
            fontFamily: AppTextStyles.bodyMedium.fontFamily,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor ?? const Color(0xFF111827),
            fontFamily: AppTextStyles.labelMedium.fontFamily,
          ),
        ),
      ],
    );
  }
}
