import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});
  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _emailController = TextEditingController();
  bool _sent = false;
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;
    final isEmailUser = user?.appMetadata['provider'] == 'email';

    return Scaffold(
      backgroundColor: AppColors.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary, size: 24.r),
          onPressed: () => context.pop(),
        ),
        title: Text('Change Password', style: TextStyle(fontSize: 17.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
      ),
      body: Padding(
        padding: EdgeInsets.all(24.r),
        child: !isEmailUser
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.info_outline, size: 48.r, color: AppColors.textSecondary),
                  SizedBox(height: 16.h),
                  Text('Password change is not available for Google/Apple login accounts.', textAlign: TextAlign.center, style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary)),
                ],
              ),
            )
          : _sent
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_circle, size: 64.r, color: AppColors.primary),
                  SizedBox(height: 16.h),
                  Text('Reset link sent!', style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w700)),
                  SizedBox(height: 8.h),
                  Text('Check your email for a password reset link.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('We\'ll send a password reset link to your email.', style: TextStyle(fontSize: 15.sp, color: AppColors.textSecondary)),
                  SizedBox(height: 24.h),
                  TextField(
                    controller: _emailController..text = user?.email ?? '',
                    decoration: InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  SizedBox(
                    width: double.infinity,
                    height: 52.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r))),
                      onPressed: _loading ? null : () async {
                        setState(() => _loading = true);
                        try {
                          await Supabase.instance.client.auth.resetPasswordForEmail(_emailController.text.trim());
                          setState(() { _sent = true; _loading = false; });
                        } catch (e) {
                          setState(() => _loading = false);
                          if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      child: _loading ? const CircularProgressIndicator(color: Colors.white) : Text('Send Reset Link', style: TextStyle(color: Colors.white, fontSize: 15.sp, fontWeight: FontWeight.w600)),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
