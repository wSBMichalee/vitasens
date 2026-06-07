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
import 'package:vitasense/features/auth/presentation/screens/login_screen.dart'; // import AnimatedBackground

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: AppColors.textWhite),
        ),
        backgroundColor: success ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16.r),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
      ),
    );
  }

  void _signUp() {
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar("Passwords don't match");
      return;
    }
    if (_passwordController.text.length < 8) {
      _showSnackBar('Password must be at least 8 characters');
      return;
    }
    context.read<AuthBloc>().add(
          SignUpRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            fullName: _fullNameController.text.trim(),
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(AppRoutes.userOnboarding);
        } else if (state is AuthError) {
          _showSnackBar(state.message);
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
                        'Start your free 3-day trial',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ).animate().fadeIn(delay: 300.ms),
                      
                      SizedBox(height: 32.h),
                      
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
                            // Back Button
                            GestureDetector(
                              onTap: () => context.pop(),
                              child: Container(
                                width: 44.r,
                                height: 44.r,
                                decoration: BoxDecoration(
                                  color: AppColors.background,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.arrow_back_ios_new,
                                  color: AppColors.textPrimary,
                                  size: 16.r,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              'Create account',
                              style: TextStyle(
                                fontSize: 24.sp,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              'Join thousands of smart cooks',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            SizedBox(height: 24.h),
                            
                            // FULL NAME
                            _buildTextField(
                              controller: _fullNameController,
                              hintText: 'Full name',
                              icon: Icons.person_outline,
                              keyboardType: TextInputType.name,
                            ),
                            SizedBox(height: 12.h),
                            
                            // EMAIL
                            _buildTextField(
                              controller: _emailController,
                              hintText: 'Email address',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: 12.h),
                            
                            // PASSWORD
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
                            
                            // CONFIRM PASSWORD
                            _buildTextField(
                              controller: _confirmPasswordController,
                              hintText: 'Confirm password',
                              icon: Icons.lock_outlined,
                              obscureText: _obscureConfirm,
                              suffixIcon: GestureDetector(
                                onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                                child: Icon(
                                  _obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                  color: AppColors.textSecondary,
                                  size: 20.r,
                                ),
                              ),
                            ),
                            SizedBox(height: 20.h),
                            
                            // TERMS CHECKBOX
                            GestureDetector(
                              onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 20.r,
                                    height: 20.r,
                                    decoration: BoxDecoration(
                                      color: _agreedToTerms ? AppColors.primary : AppColors.background,
                                      border: Border.all(
                                        color: _agreedToTerms ? AppColors.primary : AppColors.borderMedium,
                                      ),
                                      borderRadius: BorderRadius.circular(6.r),
                                    ),
                                    child: _agreedToTerms
                                        ? Icon(Icons.check, color: AppColors.textWhite, size: 14.r)
                                        : null,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                          fontSize: 13.sp,
                                          color: AppColors.textSecondary,
                                          height: 1.4,
                                        ),
                                        children: const [
                                          TextSpan(text: 'I agree to '),
                                          TextSpan(
                                            text: 'Terms of Service',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(text: ' and '),
                                          TextSpan(
                                            text: 'Privacy Policy',
                                            style: TextStyle(
                                              color: AppColors.primary,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 28.h),
                            
                            // CREATE ACCOUNT BUTTON
                            BlocBuilder<AuthBloc, AuthState>(
                              builder: (context, state) {
                                final isLoading = state is AuthLoading;
                                final isEnabled = _agreedToTerms && !isLoading;
                                return SizedBox(
                                  width: double.infinity,
                                  height: 56.h,
                                  child: FilledButton(
                                    onPressed: isEnabled ? _signUp : null,
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
                                            'Create Account',
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
                            SizedBox(height: 16.h),
                            
                            // BADGE
                            Center(
                              child: Text(
                                '🔒 3-day free trial · Cancel anytime',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.textMuted,
                                ),
                              ),
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
                            
                            // SOCIAL BUTTONS
                            _buildSocialButton(
                              label: 'Continue with Apple',
                              iconWidget: Icon(Icons.apple, color: AppColors.textWhite, size: 24.r),
                              backgroundColor: AppColors.textPrimary,
                              textColor: AppColors.textWhite,
                              onTap: () => context.read<AuthBloc>().add(const SignInWithAppleRequested()),
                            ),
                            SizedBox(height: 12.h),
                            
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
                      
                      // SIGN IN LINK
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          GestureDetector(
                            onTap: () => context.pop(),
                            child: Text(
                              'Sign in',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: AppColors.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ).animate(delay: 400.ms).fadeIn(),
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
        color: AppColors.background,
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
