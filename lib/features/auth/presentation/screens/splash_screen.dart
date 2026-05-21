import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/supabase/supabase_client.dart';
import 'package:vitasense/core/theme/app_colors.dart';
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
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80.w,
              height: 80.h,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Icon(
                Icons.restaurant_menu,
                color: Colors.white,
                size: 40.r,
              ),
            ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.0, 1.0),
              duration: 600.ms,
              curve: Curves.easeOutBack,
            ).fadeIn(duration: 400.ms),
            
            SizedBox(height: 16.h),
            
            Text(
              'VitaSense',
              style: AppTextStyles.headingXL,
            ).animate(delay: 200.ms)
             .fadeIn(duration: 400.ms)
             .slideY(begin: 0.1, end: 0, duration: 400.ms),
            
            SizedBox(height: 8.h),
            
            Text(
              'Cook smarter. Waste less.',
              style: AppTextStyles.bodyMedium,
            ).animate(delay: 200.ms)
             .fadeIn(duration: 400.ms)
             .slideY(begin: 0.1, end: 0, duration: 400.ms),
            
            SizedBox(height: 48.h),
            
            CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 2.w,
            ).animate(delay: 400.ms)
             .fadeIn(duration: 300.ms),
          ],
        ),
      ),
    );
  }
}
