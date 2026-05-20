import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class PaywallDiscountScreen extends StatefulWidget {
  const PaywallDiscountScreen({super.key});

  @override
  State<PaywallDiscountScreen> createState() => _PaywallDiscountScreenState();
}

class _PaywallDiscountScreenState extends State<PaywallDiscountScreen> {
  Timer? _timer;
  int _totalSeconds = 14 * 60 + 52; // 14 min 52 sec

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_totalSeconds > 0) {
        setState(() {
          _totalSeconds--;
        });
      } else {
        timer.cancel();
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
    final int minutes = _totalSeconds ~/ 60;
    final int seconds = _totalSeconds % 60;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1F2E),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // X Button (top-right)
              Align(
                alignment: Alignment.centerRight,
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
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close, color: Colors.white, size: 18),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Badge "LIMITED TIME OFFER"
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF22C55E), width: 1.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    "LIMITED TIME OFFER",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF22C55E),
                      letterSpacing: 1.0,
                      fontFamily: AppTextStyles.labelSmall.fontFamily,
                    ),
                  ),
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.1, end: 0, duration: 400.ms),

              const SizedBox(height: 24),

              // Title
              Text(
                "Save 50% Today",
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  fontFamily: AppTextStyles.headingXL.fontFamily,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

              const SizedBox(height: 12),

              // Subtitle
              Text(
                "Join 12,000+ others making smarter food\nchoices every day. Only for the next 15 minutes.",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withOpacity(0.7),
                  fontFamily: AppTextStyles.bodyMedium.fontFamily,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

              const SizedBox(height: 32),

              // Countdown Timer
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _TimerBox(value: minutes.toString().padLeft(2, '0'), label: "MIN"),
                  const SizedBox(width: 12),
                  _TimerBox(value: seconds.toString().padLeft(2, '0'), label: "SEC"),
                ],
              ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

              const SizedBox(height: 32),

              // Plan Card
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.06),
                  border: Border.all(color: Colors.white.withOpacity(0.15)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.bolt, color: Color(0xFF22C55E), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pro Yearly Plan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            fontFamily: AppTextStyles.labelLarge.fontFamily,
                          ),
                        ),
                        Text(
                          "Full access included",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.6),
                            fontFamily: AppTextStyles.bodyMedium.fontFamily,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "\$99.99",
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.white.withOpacity(0.4),
                            decoration: TextDecoration.lineThrough,
                            fontFamily: AppTextStyles.bodyMedium.fontFamily,
                          ),
                        ),
                        Text(
                          "\$49.99",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF22C55E),
                            fontFamily: AppTextStyles.numberMedium.fontFamily,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ).animate(delay: 300.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

              const SizedBox(height: 32),

              // CTA Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  onPressed: () => context.go(AppRoutes.successPurchase),
                  child: Text(
                    "CLAIM MY 50% DISCOUNT",
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      letterSpacing: 0.5,
                      fontFamily: AppTextStyles.labelLarge.fontFamily,
                    ),
                  ),
                ),
              ).animate(delay: 400.ms).fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0, duration: 400.ms),

              const SizedBox(height: 12),

              // Bottom Text
              Text(
                "ENDS SOON. DISCOUNT APPLIED AUTOMATICALLY.",
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white.withOpacity(0.4),
                  letterSpacing: 0.5,
                  fontFamily: AppTextStyles.caption.fontFamily,
                ),
                textAlign: TextAlign.center,
              ).animate(delay: 500.ms).fadeIn(duration: 400.ms),
            ],
          ),
        ),
      ),
    );
  }
}

class _TimerBox extends StatelessWidget {
  final String value;
  final String label;

  const _TimerBox({required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.08),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              fontFamily: AppTextStyles.numberLarge.fontFamily,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: Colors.white.withOpacity(0.6),
              letterSpacing: 1.0,
              fontFamily: AppTextStyles.caption.fontFamily,
            ),
          ),
        ],
      ),
    );
  }
}
