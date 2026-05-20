import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class PaywallScreen extends StatefulWidget {
  const PaywallScreen({super.key});

  @override
  State<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends State<PaywallScreen> {
  bool _yearlySelected = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          // 1. Hero image (góra, fullWidth, height 280)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 280,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: const Color(0xFFE8F5E9)), // Placeholder
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Color(0xFFF5F5F5),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 400.ms),
          ),

          // 3. Scrollowalny content
          Positioned.fill(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(
                left: 24,
                right: 24,
                top: 240, // Zawartość zaczyna się pod końcem Hero Image
                bottom: 40,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    "Unlock Your Kitchen's Full Potential",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF111827),
                      fontFamily: AppTextStyles.headingXL.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Get personalized meal ideas for every\nhealth goal and every ingredient in your pantry.",
                    style: TextStyle(
                      fontSize: 14,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                      fontFamily: AppTextStyles.bodyMedium.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  
                  _buildFeatureRow("Unlimited Meal Matching"),
                  _buildFeatureRow("Advanced Health Goal Analytics"),
                  _buildFeatureRow("Priority Support & New Recipes Daily"),
                  
                  const SizedBox(height: 28),

                  // PLAN SELECTOR - Yearly plan
                  GestureDetector(
                    onTap: () => setState(() => _yearlySelected = true),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: _yearlySelected ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
                          width: _yearlySelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Yearly",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827),
                                  fontFamily: AppTextStyles.labelLarge.fontFamily,
                                ),
                              ),
                              Text(
                                "BEST VALUE",
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFF22C55E),
                                  letterSpacing: 1.0,
                                  fontFamily: AppTextStyles.captionBold.fontFamily,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                "\$4.99/mo",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF111827),
                                  fontFamily: AppTextStyles.numberMedium.fontFamily,
                                ),
                              ),
                              Text(
                                "Billed annually",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: const Color(0xFF6B7280),
                                  fontFamily: AppTextStyles.bodySmall.fontFamily,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

                  const SizedBox(height: 12),

                  // PLAN SELECTOR - Monthly plan
                  GestureDetector(
                    onTap: () => setState(() => _yearlySelected = false),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                          color: !_yearlySelected ? const Color(0xFF22C55E) : const Color(0xFFE5E7EB),
                          width: !_yearlySelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Text(
                            "Monthly",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: !_yearlySelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
                              fontFamily: AppTextStyles.labelLarge.fontFamily,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            "\$9.99/mo",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: !_yearlySelected ? const Color(0xFF111827) : const Color(0xFF6B7280),
                              fontFamily: AppTextStyles.labelLarge.fontFamily,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),

                  const SizedBox(height: 28),

                  // CTA Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1F2937),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: () => context.go(AppRoutes.successPurchase),
                      child: Text(
                        "Try Free for 7 Days",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          fontFamily: AppTextStyles.labelLarge.fontFamily,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    "NO COMMITMENT. CANCEL ANYTIME.",
                    style: TextStyle(
                      fontSize: 11,
                      color: const Color(0xFF9CA3AF),
                      letterSpacing: 0.5,
                      fontFamily: AppTextStyles.caption.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0, duration: 400.ms),
            ),
          ),

          // 2. X button (top-right)
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: GestureDetector(
                  onTap: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go(AppRoutes.home);
                    }
                  },
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Color(0xFF111827),
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(String feature) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              feature,
              style: TextStyle(
                fontSize: 15,
                color: const Color(0xFF111827),
                fontFamily: AppTextStyles.bodyLarge.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
