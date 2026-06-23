import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vitasense/features/auth/data/auth_repository.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/features/subscription/bloc/subscription_bloc.dart';
import 'package:vitasense/features/subscription/bloc/subscription_state.dart';
import 'package:shimmer/shimmer.dart';

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Shimmer.fromColors(
        baseColor: AppColors.borderLight,
        highlightColor: AppColors.border,
        child: Column(
          children: [
            Container(
              height: 200.h,
              color: AppColors.backgroundWhite,
            ),
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: List.generate(
                  4,
                  (i) => Container(
                    margin: EdgeInsets.only(bottom: 16.h),
                    height: i == 0 ? 100.h : 140.h,
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsMenuCard extends StatelessWidget {
  const SettingsMenuCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── Subscription card ──
        BlocBuilder<SubscriptionBloc, SubscriptionState>(
          builder: (context, state) {
            if (state is SubscriptionLoaded) {
              final isActive = state.subscription.isActive;
              return GestureDetector(
                onTap: () => context.push(AppRoutes.subscription),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.primary, AppColors.primaryDark],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 28.r),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VitaSense Pro',
                              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700, color: Colors.white),
                            ),
                            Text(
                              isActive ? 'Active subscription' : 'Upgrade to Pro',
                              style: TextStyle(fontSize: 13.sp, color: Colors.white.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(100.r),
                        ),
                        child: Text(
                          isActive ? 'Manage' : 'Upgrade',
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w700, color: AppColors.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        SizedBox(height: 16.h),
        // ── Settings items ──
        ProfileShimmerCard(
          child: Column(
            children: [
              _buildRow(context, Icons.notifications_outlined, AppColors.borderLight, AppColors.textSecondary, 'Notifications', null, onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Notifications coming soon')))),
              const Divider(color: AppColors.border, height: 1),
              _buildRow(context, Icons.help_outline, AppColors.borderLight, AppColors.textSecondary, 'Help & Support', null, onTap: () async {
                final uri = Uri.parse('mailto:support@vitasense.app');
                if (await canLaunchUrl(uri)) await launchUrl(uri);
              }),
              if (() {
                final providers = Supabase.instance.client.auth.currentUser?.appMetadata['providers'] as List?;
                return providers != null && providers.contains('email') && !providers.contains('google') && !providers.contains('apple');
              }()) ...[
                const Divider(color: AppColors.border, height: 1),
                _buildRow(context, Icons.lock_outline, AppColors.borderLight, AppColors.textSecondary, 'Change Password', AppRoutes.changePassword),
              ],
              const Divider(color: AppColors.border, height: 1),
              _buildRow(context, Icons.shield_outlined, AppColors.borderLight, AppColors.textSecondary, 'Privacy Policy', AppRoutes.privacyPolicy),
              const Divider(color: AppColors.border, height: 1),
              _buildRow(context, Icons.description_outlined, AppColors.borderLight, AppColors.textSecondary, 'Terms of Service', AppRoutes.termsOfService),
              const Divider(color: AppColors.border, height: 1),
              _buildRow(context, Icons.logout_rounded, AppColors.borderLight, AppColors.textSecondary, 'Sign Out', null,
                onTap: () async {
                  await AuthRepository().signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
              const Divider(color: AppColors.border, height: 1),
              _buildRow(context, Icons.delete_outline, AppColors.errorLight, AppColors.error, 'Delete Account', AppRoutes.deleteAccount, isDestructive: true),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(BuildContext context, IconData icon, Color iconBg, Color iconColor, String label, String? route, {VoidCallback? onTap, bool isDestructive = false}) {
    return GestureDetector(
      onTap: onTap ?? (route != null ? () => context.push(route) : null),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 36.r, height: 36.r,
              decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8.r)),
              child: Icon(icon, color: iconColor, size: 18.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: isDestructive ? AppColors.error : AppColors.textPrimary,
                ),
              ),
            ),
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18.r),
          ],
        ),
      ),
    );
  }
}

class ProfileShimmerCard extends StatelessWidget {
  const ProfileShimmerCard({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: child,
    );
  }
}

