import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_event.dart';
import 'package:vitasense/features/auth/bloc/auth_state.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  final List<String> emojis = [
    '🥑', '🥗', '🏋️', '🍎', '🥦', '🏃', '💪', '🫐', '🥕', '🍳', '🥩', '🏊', '🚴', '💚'
  ];
  final Random _random = Random(42);
  late List<_FloatingEmojiData> _emojiData;

  @override
  void initState() {
    super.initState();
    _emojiData = List.generate(20, (index) {
      return _FloatingEmojiData(
        emoji: emojis[_random.nextInt(emojis.length)],
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        size: 20 + _random.nextDouble() * 30,
        delay: _random.nextInt(2000),
        duration: 3000 + _random.nextInt(3000),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      width: double.infinity,
      height: double.infinity,
      child: Stack(
        children: _emojiData.map((data) {
          return Positioned(
            left: data.x * MediaQuery.of(context).size.width,
            top: data.y * MediaQuery.of(context).size.height,
            child: Text(
              data.emoji,
              style: TextStyle(fontSize: data.size.sp),
            )
                .animate(
                  onPlay: (controller) => controller.repeat(reverse: true),
                )
                .slideY(
                  begin: -0.2,
                  end: 0.2,
                  duration: data.duration.ms,
                  delay: data.delay.ms,
                  curve: Curves.easeInOutSine,
                )
                .animate(
                  onPlay: (controller) => controller.repeat(),
                )
                .rotate(
                  begin: -0.05,
                  end: 0.05,
                  duration: (data.duration * 1.5).ms,
                  curve: Curves.easeInOutSine,
                )
                .fadeIn(duration: 500.ms)
                .fade(end: 0.3),
          );
        }).toList(),
      ),
    );
  }
}

class _FloatingEmojiData {
  final String emoji;
  final double x;
  final double y;
  final double size;
  final int delay;
  final int duration;

  _FloatingEmojiData({
    required this.emoji,
    required this.x,
    required this.y,
    required this.size,
    required this.delay,
    required this.duration,
  });
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) return;
    context.read<AuthBloc>().add(
          SignInRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.onboardingCompleted) {
            context.go(AppRoutes.home);
          } else {
            context.go(AppRoutes.userOnboarding);
          }
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                state.message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.textWhite),
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.all(16.r),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            const AnimatedBackground(),
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // LOGO & TITLE
                      Container(
                        width: 72.r,
                        height: 72.r,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.primary,
                        ),
                        child: Icon(
                          Icons.restaurant_menu,
                          color: AppColors.textWhite,
                          size: 36.r,
                        ),
                      ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
                      SizedBox(height: 16.h),
                      Text(
                        'VitaSense',
                        style: TextStyle(
                          fontSize: 28.sp,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn(delay: 200.ms),
                      SizedBox(height: 4.h),
                      Text(
                        'Eat smart. Live better.',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      
                      SizedBox(height: 40.h),
                      
                      // FORM CARD
                      Container(
                        padding: EdgeInsets.all(24.r),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundWhite,
                          borderRadius: BorderRadius.circular(24.r),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.textPrimary.withValues(alpha: 0.06),
                              blurRadius: 32,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            
                            // EMAIL FIELD
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Email address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 16.h),
                            
                            // PASSWORD FIELD
                            _buildTextField(
                              controller: _passwordController,
                              hintText: 'Password',
                              icon: Icons.lock_outlined,
                              obscureText: _obscurePassword,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                                child: Icon(
                                  _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20.r,
                                ),
                              ),
                            ),
                            SizedBox(height: 12.h),
                            
                            // FORGOT PASSWORD
                            Align(
                              alignment: Alignment.centerRight,
                              child: GestureDetector(
                                onTap: () => context.push(AppRoutes.forgotPassword),
                                child: Text(
                                  'Forgot password?',
                                  style: TextStyle(
                                    fontSize: 13.sp,
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 24.h),
                            
                            // SIGN IN BUTTON
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: FilledButton(
                                    onPressed: isLoading ? null : _signIn,
                                    style: FilledButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.5),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(100.r),
                                      ),
                                    ),
                                    child: isLoading
                                        ? SizedBox(
                                            width: 24.r,
                                            height: 24.r,
                                            child: const CircularProgressIndicator(
                                              color: AppColors.textWhite,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 16.sp,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.textWhite,
                                            ),
                                          ),
                                  ),
                                );
                              },
                            ),
                            SizedBox(height: 24.h),
                            
                            // SEPARATOR
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: AppColors.borderLight)),
                                Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Text(
                                    'or continue with',
                                    style: TextStyle(
                                      fontSize: 13.sp,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                                Expanded(child: Container(height: 1, color: AppColors.borderLight)),
                              ],
                            ),
                            SizedBox(height: 24.h),
                            
                            // APPLE BUTTON
                            _buildSocialButton(
                              label: 'Continue with Apple',
                              iconWidget: Icon(Icons.apple, color: AppColors.textWhite, size: 24.r),
                              backgroundColor: AppColors.textPrimary,
                              textColor: AppColors.textWhite,
                              onTap: () => context.read<AuthBloc>().add(const SignInWithAppleRequested()),
                            ),
                            SizedBox(height: 12.h),
                            
                            // GOOGLE BUTTON
                            _buildSocialButton(
                              label: 'Continue with Google',
                              iconWidget: _buildGoogleIcon(),
                              backgroundColor: AppColors.backgroundWhite,
                              textColor: AppColors.textPrimary,
                              borderColor: AppColors.borderMedium,
                              onTap: () => context.read<AuthBloc>().add(const SignInWithGoogleRequested()),
                            ),
                          ],
                        ),
                      ).animate().slideY(begin: 0.1, end: 0, duration: 500.ms, curve: Curves.easeOutQuad).fadeIn(),
                      
                      SizedBox(height: 32.h),
                      
                      // SIGN UP LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.push(AppRoutes.signup),
                            child: Text(
                              'Sign up',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background, // Light gray background
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        style: TextStyle(fontSize: 15.sp, color: AppColors.textPrimary),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 15.sp),
          prefixIcon: Icon(icon, color: AppColors.textSecondary, size: 22.r),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        ),
      ),
    );
  }

  Widget _buildSocialButton({
    required String label,
    required Widget iconWidget,
    required Color backgroundColor,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: FilledButton(
        onPressed: onTap,
        style: FilledButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(100.r),
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            iconWidget,
            SizedBox(width: 12.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 24.r,
      height: 24.r,
      decoration: const BoxDecoration(
        color: AppColors.backgroundWhite,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          'G',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w900,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }
}
