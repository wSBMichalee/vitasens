import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/subscription/bloc/subscription_bloc.dart';
import 'package:vitasense/features/subscription/bloc/subscription_event.dart';
import 'package:vitasense/features/subscription/bloc/subscription_state.dart';
import 'package:vitasense/features/auth/data/auth_repository.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SubscriptionBloc()..add(const LoadSubscription()),
      child: const _SettingsView(),
    );
  }
}

class _SettingsView extends StatelessWidget {
  const _SettingsView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<SubscriptionBloc, SubscriptionState>(
      listener: (context, state) {
        if (state is SubscriptionCancelled) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Subscription cancelled. Access until end of period.'),
              backgroundColor: AppColors.primary, // Zielony jak prosił user
            ),
          );
          // Odśwież status
          context.read<SubscriptionBloc>().add(const LoadSubscription());
        } else if (state is SubscriptionError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── AppHeader: wariant nested (push navigation, back po lewej) ────
              AppHeader(
                title: 'Settings',
                variant: AppHeaderVariant.nested,
                onBack: () => context.pop(),
              ),

              // ── Scrollable body ─────────────────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SubscriptionCardSection(),
                      SizedBox(height: 24.h),
                      const _PlanDetailsSection(),
                      SizedBox(height: 24.h),
                      const _AccountSettingsSection(),
                      SizedBox(height: 24.h),
                      const _DangerZoneSection(),
                      SizedBox(height: 48.h),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── SUBSCRIPTION CARD ────────────────────────────────────────────────────────

class _SubscriptionCardSection extends StatelessWidget {
  const _SubscriptionCardSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoading || state is SubscriptionInitial) {
          return Shimmer.fromColors(
            baseColor: AppColors.borderLight,
            highlightColor: AppColors.border,
            child: Container(
              height: 120.h,
              decoration: BoxDecoration(
                color: AppColors.backgroundWhite,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          );
        }

        if (state is SubscriptionLoaded) {
          final sub = state.subscription;
          final isActive = sub.isActive;
          
          return Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isActive 
                  ? [AppColors.primary, AppColors.primaryDark]
                  : [AppColors.textMuted, AppColors.textSecondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isActive ? 'VitaSense Pro ✓' : 'Subscription Expired',
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textWhite,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        isActive ? sub.planName : 'Renew to continue using VitaSense',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textWhite.withValues(alpha: 0.9),
                        ),
                      ),
                      if (isActive) ...[
                        SizedBox(height: 4.h),
                        Text(
                          sub.isTrialActive 
                            ? 'Trial ends in ${sub.trialDaysRemaining} days'
                            : 'Expires in ${sub.daysRemaining} days',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textWhite.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (isActive)
                  SizedBox(
                    height: 44.h,
                    child: OutlinedButton(
                      onPressed: () => context.read<SubscriptionBloc>().add(const SyncSubscription()),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.textWhite),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                      ),
                      child: Text(
                        'Sync',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textWhite,
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 44.h,
                    child: FilledButton(
                      onPressed: () => context.push(AppRoutes.paywall),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.textWhite,
                        foregroundColor: AppColors.textSecondary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                      ),
                      child: Text(
                        'Renew Now',
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        }

        return const SizedBox();
      },
    );
  }
}

// ─── PLAN DETAILS ─────────────────────────────────────────────────────────────

class _PlanDetailsSection extends StatelessWidget {
  const _PlanDetailsSection();

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Plan Details',
      child: BlocBuilder<SubscriptionBloc, SubscriptionState>(
        builder: (context, state) {
          if (state is SubscriptionLoaded) {
            final sub = state.subscription;
            return Column(
              children: [
                _DetailRow(
                  label: 'Status',
                  value: sub.statusLabel,
                  valueColor: sub.isActive ? AppColors.primary : AppColors.error,
                ),
                const Divider(color: AppColors.border),
                _DetailRow(
                  label: 'Plan',
                  value: sub.planName,
                ),
                const Divider(color: AppColors.border),
                _DetailRow(
                  label: 'Price',
                  value: sub.priceLabel,
                ),
                const Divider(color: AppColors.border),
                _DetailRow(
                  label: 'Next billing',
                  value: sub.expiresAtFormatted,
                ),
                const Divider(color: AppColors.border),
                _DetailRow(
                  label: 'Trial',
                  value: sub.isTrialActive 
                    ? 'Active (${sub.trialDaysRemaining} days left)' 
                    : 'Not active',
                ),
              ],
            );
          }
          if (state is SubscriptionLoading || state is SubscriptionInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          return const SizedBox();
        },
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── ACCOUNT SETTINGS ─────────────────────────────────────────────────────────

class _AccountSettingsSection extends StatelessWidget {
  const _AccountSettingsSection();

  @override
  Widget build(BuildContext context) {
    return _BaseCard(
      title: 'Account Settings',
      child: Column(
        children: [
          _ActionRow(
            icon: Icons.lock_outline,
            label: 'Change Password',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(color: AppColors.border),
          _ActionRow(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(color: AppColors.border),
          _ActionRow(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () => _showComingSoon(context),
          ),
          const Divider(color: AppColors.border),
          _ActionRow(
            icon: Icons.logout_rounded,
            label: 'Sign Out',
            onTap: () async {
              await AuthRepository().signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
          const Divider(color: AppColors.border),
          _ActionRow(
            icon: Icons.delete_outline,
            label: 'Delete Account',
            onTap: () => _showComingSoon(context),
            isDestructive: true,
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}

class _ActionRow extends StatelessWidget {
  const _ActionRow({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.error : AppColors.textPrimary;
    
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20.r),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: AppColors.textMuted,
              size: 20.r,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── DANGER ZONE ──────────────────────────────────────────────────────────────

class _DangerZoneSection extends StatelessWidget {
  const _DangerZoneSection();

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cancel Subscription?'),
        content: const Text(
            "You'll lose access at the end of your billing period."),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Keep Plan'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              context.read<SubscriptionBloc>().add(const CancelSubscription());
            },
            child: const Text(
              'Cancel Subscription',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SubscriptionBloc, SubscriptionState>(
      builder: (context, state) {
        if (state is SubscriptionLoaded && state.subscription.isActive) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Account',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                  letterSpacing: 0.5,
                ),
              ),
              SizedBox(height: 12.h),
              Container(
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
                child: SizedBox(
                  height: 56.h,
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _showCancelDialog(context),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppColors.error.withValues(alpha: 0.5)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      'Cancel Subscription',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        }
        return const SizedBox();
      },
    );
  }
}

// ─── BASE CARD ────────────────────────────────────────────────────────────────

class _BaseCard extends StatelessWidget {
  const _BaseCard({
    required this.title,
    required this.child,
  });

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.textSecondary,
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 12.h),
        Container(
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
        ),
      ],
    );
  }
}
