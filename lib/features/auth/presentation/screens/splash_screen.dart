import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      final user = SupabaseClientService.instance.currentUser;
      if (user != null) {
        context.go(AppRoutes.home);
      } else {
        context.go(AppRoutes.onboarding);
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
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 40,
              ),
            ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ).fadeIn(duration: 400.ms),
            
            const SizedBox(height: 16),
            
            Text(
              'VitaSense',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
                fontFamily: AppTextStyles.headingXL.fontFamily,
              ),
            ).animate(delay: 200.ms)
             .fadeIn(duration: 400.ms)
             .slideY(begin: 0.1, end: 0, duration: 400.ms),
            
            const SizedBox(height: 8),
            
            Text(
              'Cook smarter. Waste less.',
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF6B7280),
                fontFamily: AppTextStyles.bodyMedium.fontFamily,
              ),
            ).animate(delay: 200.ms)
             .fadeIn(duration: 400.ms)
             .slideY(begin: 0.1, end: 0, duration: 400.ms),
            
            const SizedBox(height: 48),
            
            const CircularProgressIndicator(
              color: Color(0xFF22C55E),
              strokeWidth: 2,
            ).animate(delay: 400.ms)
             .fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
