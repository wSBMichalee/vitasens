import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (!state.user.onboardingCompleted) {
            context.go(AppRoutes.userOnboarding);
          } else {
            final status = state.user.subscriptionStatus?.toLowerCase();
            final isActive = status == 'active' || status == 'trialing';
            if (!isActive) {
              context.go(AppRoutes.paywall, extra: state.user);
            } else {
              context.go(AppRoutes.home);
            }
          }
        } else if (state is AuthUnauthenticated) {
          context.go(AppRoutes.landing);
        }
      },
      child: Scaffold(
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
      ),
    );
  }
}
