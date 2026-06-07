import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_event.dart';
import 'package:vitasense/features/auth/bloc/auth_state.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';

// ─── ENTRY POINT ─────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthLoading || state is AuthInitial) {
          return const _ProfileShimmer();
        }
        if (state is AuthAuthenticated) {
          return _ProfileView(user: state.user);
        }
        return const Scaffold(
          backgroundColor: AppColors.background,
          body: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}

// ─── MAIN VIEW ────────────────────────────────────────────────────────────────

class _ProfileView extends StatelessWidget {
  const _ProfileView({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ── HERO SLIVER APP BAR ────────────────────────────────────
          _ProfileSliverAppBar(user: user),

          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── DAILY TARGETS ────────────────────────────────
                  _DailyTargetsCard(user: user),
                  SizedBox(height: 16.h),

                  // ── MY GOALS ─────────────────────────────────────
                  _MyGoalsCard(user: user),
                  SizedBox(height: 16.h),

                  // ── NAVIGATION MENU ───────────────────────────────
                  const _MenuCard(),
                  SizedBox(height: 16.h),

                  // ── SUBSCRIPTION BANNER ───────────────────────────
                  _SubscriptionCard(user: user),
                  SizedBox(height: 24.h),

                  // ── SIGN OUT ──────────────────────────────────────────────
                  const _SignOutButton(),
                  SizedBox(height: 32.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SLIVER APP BAR (HERO) ────────────────────────────────────────────────────

class _ProfileSliverAppBar extends StatelessWidget {
  const _ProfileSliverAppBar({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 200.h,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
      actions: [
        IconButton(
          icon: Icon(Icons.settings_outlined, color: AppColors.textWhite, size: 22.r),
          onPressed: () => context.push(AppRoutes.settings),
        ),
        SizedBox(width: 4.w),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _HeroBanner(user: user),
      ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final isProActive = user.subscriptionStatus?.toLowerCase() == 'active';
    final badgeLabel = isProActive ? 'PRO ACTIVE' : 'FREE PLAN';
    final badgeBg = isProActive
        ? AppColors.primaryLight.withValues(alpha: 0.25)
        : Colors.white.withValues(alpha: 0.15);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 20.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // ── AVATAR ──────────────────────────────────────
                  Container(
                    width: 64.r,
                    height: 64.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.2),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.person,
                      color: AppColors.textWhite,
                      size: 36.r,
                    ),
                  ),
                  SizedBox(width: 16.w),

                  // ── NAME + EMAIL + BADGE ──────────────────────────
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user.fullName?.isNotEmpty == true
                              ? user.fullName!
                              : 'Your Name',
                          style: GoogleFontsSafeStyle.heroBold,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          user.email,
                          style: GoogleFontsSafeStyle.heroSub,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 4.h,
                          ),
                          decoration: BoxDecoration(
                            color: badgeBg,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            badgeLabel,
                            style: TextStyle(
                              fontSize: 10.sp,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textWhite,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── DAILY TARGETS CARD ───────────────────────────────────────────────────────

class _DailyTargetsCard extends StatelessWidget {
  const _DailyTargetsCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Daily Targets',
                      style: AppTextStyles.headingSmall,
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Based on your goals',
                      style: AppTextStyles.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(Icons.flag_outlined, color: AppColors.primary, size: 20.r),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              _MacroColumn(
                value: user.dailyCalorieTarget ?? 0,
                unit: 'kcal',
                label: 'Calories',
                valueColor: AppColors.primary,
              ),
              _MacroColumn(
                value: user.dailyProteinTarget ?? 0,
                unit: 'g',
                label: 'Protein',
                valueColor: AppColors.proteinColor,
              ),
              _MacroColumn(
                value: user.dailyCarbsTarget ?? 0,
                unit: 'g',
                label: 'Carbs',
                valueColor: AppColors.carbsColor,
              ),
              _MacroColumn(
                value: user.dailyFatTarget ?? 0,
                unit: 'g',
                label: 'Fat',
                valueColor: AppColors.fatColor,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroColumn extends StatelessWidget {
  const _MacroColumn({
    required this.value,
    required this.unit,
    required this.label,
    required this.valueColor,
  });

  final int value;
  final String unit;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$value',
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: valueColor,
                  ),
                ),
                TextSpan(
                  text: unit,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w500,
                    color: valueColor.withValues(alpha: 0.75),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MY GOALS CARD ───────────────────────────────────────────────────────────

class _MyGoalsCard extends StatelessWidget {
  const _MyGoalsCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('My Goals', style: AppTextStyles.headingSmall),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push(AppRoutes.userOnboarding),
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'Edit',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _GoalRow(
            icon: Icons.track_changes_outlined,
            iconBg: AppColors.primaryLight,
            iconColor: AppColors.primaryDark,
            label: 'Goal',
            value: _goalLabel(user.goalType),
          ),
          Divider(color: AppColors.border, height: 20.h),
          _GoalRow(
            icon: Icons.speed_outlined,
            iconBg: AppColors.secondaryLight,
            iconColor: AppColors.secondary,
            label: 'Pace',
            value: _paceLabel(null),
          ),
          Divider(color: AppColors.border, height: 20.h),
          _GoalRow(
            icon: Icons.directions_run_outlined,
            iconBg: AppColors.warningLight,
            iconColor: AppColors.warning,
            label: 'Activity',
            value: _activityLabel(null),
          ),
          Divider(color: AppColors.border, height: 20.h),
          const _GoalRow(
            icon: Icons.monitor_weight_outlined,
            iconBg: AppColors.borderLight,
            iconColor: AppColors.textSecondary,
            label: 'Weight',
            value: 'Not set',
          ),
        ],
      ),
    );
  }

  static String _goalLabel(String? goalType) {
    switch (goalType) {
      case 'weight_loss':
        return 'Lose Weight';
      case 'weight_gain':
        return 'Gain Weight';
      case 'maintain':
        return 'Maintain Weight';
      case 'muscle_gain':
        return 'Build Muscle';
      default:
        return 'Not set';
    }
  }

  static String _paceLabel(String? pace) {
    switch (pace) {
      case 'slow':
        return 'Slow & Steady';
      case 'moderate':
        return 'Moderate';
      case 'fast':
        return 'Fast';
      default:
        return 'Not set';
    }
  }

  static String _activityLabel(String? activity) {
    switch (activity) {
      case 'sedentary':
        return 'Sedentary';
      case 'light':
        return 'Lightly Active';
      case 'moderate':
        return 'Moderately Active';
      case 'active':
        return 'Very Active';
      case 'very_active':
        return 'Extremely Active';
      default:
        return 'Not set';
    }
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36.r,
          height: 36.r,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 18.r),
        ),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

// ─── NAVIGATION MENU CARD ─────────────────────────────────────────────────────

class _MenuCard extends StatelessWidget {
  const _MenuCard();

  final List<_MenuItem> _items = const [
    _MenuItem(
      icon: Icons.shopping_cart_outlined,
      iconBg: AppColors.primaryLight,
      iconColor: AppColors.primaryDark,
      label: 'Shopping List',
      route: '/shopping',
    ),
    _MenuItem(
      icon: Icons.family_restroom_outlined,
      iconBg: AppColors.secondaryLight,
      iconColor: AppColors.secondary,
      label: 'Family Plan',
      route: '/family',
    ),
    _MenuItem(
      icon: Icons.menu_book_outlined,
      iconBg: AppColors.warningLight,
      iconColor: AppColors.warning,
      label: 'My Recipes',
      route: null,
    ),
    _MenuItem(
      icon: Icons.explore_outlined,
      iconBg: AppColors.primaryLight,
      iconColor: AppColors.primaryDark,
      label: 'Browse Recipes',
      route: null,
    ),
    _MenuItem(
      icon: Icons.notifications_outlined,
      iconBg: AppColors.borderLight,
      iconColor: AppColors.textSecondary,
      label: 'Notifications',
      route: null,
    ),
    _MenuItem(
      icon: Icons.help_outline,
      iconBg: AppColors.borderLight,
      iconColor: AppColors.textSecondary,
      label: 'Help & Support',
      route: null,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return _Card(
      child: Column(
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          final isLast = index == _items.length - 1;
          return Column(
            children: [
              _MenuRow(item: item),
              if (!isLast) const Divider(color: AppColors.border, height: 1),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _MenuItem {
  const _MenuItem({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.route,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String? route;
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.item});

  final _MenuItem item;

  @override
  Widget build(BuildContext context) {
    final isEnabled = item.route != null;
    return InkWell(
      onTap: isEnabled ? () => context.push(item.route!) : null,
      borderRadius: BorderRadius.circular(12.r),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12.h),
        child: Row(
          children: [
            Container(
              width: 36.r,
              height: 36.r,
              decoration: BoxDecoration(
                color: item.iconBg,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Icon(item.icon, color: item.iconColor, size: 18.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                item.label,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: isEnabled
                      ? AppColors.textPrimary
                      : AppColors.textSecondary,
                ),
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isEnabled
                  ? AppColors.textSecondary
                  : AppColors.textMuted,
              size: 18.r,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── SUBSCRIPTION CARD ────────────────────────────────────────────────────────

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final isActive = user.subscriptionStatus?.toLowerCase() == 'active';
    final statusLabel = isActive ? 'Active subscription' : 'Upgrade to Pro';

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'VitaSense Pro',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textWhite,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  statusLabel,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () => context.push(AppRoutes.settings),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: AppColors.textWhite,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Manage',
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── SIGN OUT BUTTON ──────────────────────────────────────────────────────────

class _SignOutButton extends StatelessWidget {
  const _SignOutButton();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {
          context.read<AuthBloc>().add(const SignOutRequested());
          context.go(AppRoutes.login);
        },
        icon: Icon(Icons.logout, color: AppColors.error, size: 18.r),
        label: Text(
          'Sign Out',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.error,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: AppColors.error.withValues(alpha: 0.4)),
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }
}

// ─── SHIMMER LOADING ──────────────────────────────────────────────────────────

class _ProfileShimmer extends StatelessWidget {
  const _ProfileShimmer();

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

// ─── SHARED CARD WRAPPER ──────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
    );
  }
}

// ─── LOCAL TEXT STYLE HELPERS ─────────────────────────────────────────────────
// (używamy TextStyle bezpośrednio bo AppTextStyles nie ma wariantu białego)

abstract class GoogleFontsSafeStyle {
  static TextStyle get heroBold => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w700,
        color: AppColors.textWhite,
        height: 1.2,
      );

  static TextStyle get heroSub => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w400,
        color: Colors.white.withValues(alpha: 0.75),
      );
}
