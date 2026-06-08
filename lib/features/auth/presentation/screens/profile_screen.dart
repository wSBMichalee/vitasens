import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_event.dart';
import 'package:vitasense/features/auth/bloc/auth_state.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';
import 'package:vitasense/features/auth/data/auth_repository.dart';
import 'package:vitasense/features/subscription/bloc/subscription_bloc.dart';
import 'package:vitasense/features/subscription/bloc/subscription_event.dart';
import 'package:vitasense/features/subscription/bloc/subscription_state.dart';

// ─── ENTRY POINT ─────────────────────────────────────────────────────────────

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<SubscriptionBloc>(
      create: (context) => SubscriptionBloc()..add(const LoadSubscription()),
      child: BlocBuilder<AuthBloc, AuthState>(
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
      ),
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
                  const _SettingsMenuCard(),
                  SizedBox(height: 100.h),
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
      expandedHeight: 130.h,
      pinned: true,
      backgroundColor: AppColors.primaryDark,
      elevation: 0,
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
    final String? avatarUrl = Supabase.instance.client.auth.currentUser?.userMetadata?['avatar_url'] as String?
        ?? Supabase.instance.client.auth.currentUser?.userMetadata?['picture'] as String?
        ?? user.avatarUrl;
    final isProActive = user.subscriptionStatus?.toLowerCase() == 'active';
    final badgeLabel = isProActive ? 'PRO ACTIVE' : 'FREE PLAN';
    final badgeBg = isProActive
        ? AppColors.primaryLight.withValues(alpha: 0.25)
        : AppColors.textWhite.withValues(alpha: 0.15);

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
                      color: AppColors.textWhite.withValues(alpha: 0.2),
                      border: Border.all(
                        color: AppColors.textWhite.withValues(alpha: 0.5),
                        width: 2,
                      ),
                    ),
                    child: avatarUrl != null
                        ? ClipOval(
                            child: Image.network(
                              avatarUrl,
                              width: 64.r,
                              height: 64.r,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.person,
                                color: AppColors.textWhite,
                                size: 36.r,
                              ),
                            ),
                          )
                        : Icon(
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
                              color: AppColors.textWhite.withValues(alpha: 0.4),
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
            ],
          ),
          SizedBox(height: 16.h),
          _GoalRow(
            icon: Icons.track_changes_outlined,
            iconBg: AppColors.primaryLight,
            iconColor: AppColors.primaryDark,
            label: 'Goal',
            value: _goalLabel(user.goalType),
            onTap: () => _showEditSheet(context, 'goal', user),
          ),
          Divider(color: AppColors.border, height: 20.h),
          _GoalRow(
            icon: Icons.speed_outlined,
            iconBg: AppColors.secondaryLight,
            iconColor: AppColors.secondary,
            label: 'Pace',
            value: _paceLabel(user.goalPace),
            onTap: () => _showEditSheet(context, 'pace', user),
          ),
          Divider(color: AppColors.border, height: 20.h),
          _GoalRow(
            icon: Icons.directions_run_outlined,
            iconBg: AppColors.warningLight,
            iconColor: AppColors.warning,
            label: 'Activity',
            value: _activityLabel(user.activityLevel),
            onTap: () => _showEditSheet(context, 'activity', user),
          ),
          Divider(color: AppColors.border, height: 20.h),
          _GoalRow(
            icon: Icons.monitor_weight_outlined,
            iconBg: AppColors.borderLight,
            iconColor: AppColors.textSecondary,
            label: 'Weight',
            value: user.weightKg != null ? '${user.weightKg!.toStringAsFixed(1)} kg' : 'Not set',
            onTap: () => _showEditSheet(context, 'weight', user),
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

  void _showEditSheet(BuildContext context, String type, UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditGoalSheet(type: type, user: user),
    );
  }
}

class _GoalRow extends StatelessWidget {
  const _GoalRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.value,
    this.onTap,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
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
          if (onTap != null)
            Icon(Icons.chevron_right, color: AppColors.textMuted, size: 18.r),
        ],
      ),
    );
  }
}

class _EditGoalSheet extends StatefulWidget {
  const _EditGoalSheet({required this.type, required this.user});
  final String type;
  final UserModel user;

  @override
  State<_EditGoalSheet> createState() => _EditGoalSheetState();
}

class _EditGoalSheetState extends State<_EditGoalSheet> {
  late String? _selectedGoal;
  late String? _selectedPace;
  late String? _selectedActivity;
  late int _weight;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _selectedGoal = widget.user.goalType;
    _selectedPace = widget.user.goalPace;
    _selectedActivity = widget.user.activityLevel;
    _weight = widget.user.weightKg?.round() ?? 70;
  }

  Future<void> _save(Map<String, dynamic> data) async {
    setState(() => _saving = true);
    try {
      await AuthRepository().updateProfile(data);
      await AuthRepository().calculateTargets();
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: AppColors.error),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 40.h),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: AppColors.borderMedium,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          if (widget.type == 'goal') ...[
            Text('Edit Goal', style: AppTextStyles.headingSmall),
            SizedBox(height: 20.h),
            _buildGoalCard('Lose Weight', 'weight_loss', Icons.trending_down, 'Burn fat with smart meals'),
            SizedBox(height: 10.h),
            _buildGoalCard('Gain Weight', 'weight_gain', Icons.trending_up, 'Build mass with proper nutrition'),
            SizedBox(height: 10.h),
            _buildGoalCard('Maintain Weight', 'maintain', Icons.balance, 'Stay consistent and healthy'),
            SizedBox(height: 10.h),
            _buildGoalCard('Build Muscle', 'muscle_gain', Icons.fitness_center, 'High protein meals for growth'),
            SizedBox(height: 24.h),
            _SaveButton(saving: _saving, onPressed: () => _save({'goal_type': _selectedGoal})),
          ] else if (widget.type == 'pace') ...[
            Text('Edit Pace', style: AppTextStyles.headingSmall),
            SizedBox(height: 20.h),
            _buildPaceCard('Slow & Steady', 'slow', '~0.25kg/week', 'More sustainable, easier to maintain'),
            SizedBox(height: 10.h),
            _buildPaceCard('Moderate', 'moderate', '~0.5kg/week', 'Balanced approach, recommended'),
            SizedBox(height: 10.h),
            _buildPaceCard('Fast', 'fast', '~0.75kg/week', 'Requires strict discipline'),
            SizedBox(height: 24.h),
            _SaveButton(saving: _saving, onPressed: () => _save({'goal_pace': _selectedPace})),
          ] else if (widget.type == 'activity') ...[
            Text('Edit Activity', style: AppTextStyles.headingSmall),
            SizedBox(height: 20.h),
            _buildActivityCard('Sedentary', 'sedentary', Icons.chair_outlined, 'Desk job, little exercise'),
            SizedBox(height: 10.h),
            _buildActivityCard('Lightly Active', 'light', Icons.directions_walk, 'Light exercise 1–3x/week'),
            SizedBox(height: 10.h),
            _buildActivityCard('Moderately Active', 'moderate', Icons.directions_run, 'Moderate exercise 3–5x/week'),
            SizedBox(height: 10.h),
            _buildActivityCard('Very Active', 'active', Icons.fitness_center, 'Hard exercise 6–7x/week'),
            SizedBox(height: 10.h),
            _buildActivityCard('Extremely Active', 'very_active', Icons.sports, 'Physical job + daily training'),
            SizedBox(height: 24.h),
            _SaveButton(saving: _saving, onPressed: () => _save({'activity_level': _selectedActivity})),
          ] else if (widget.type == 'weight') ...[
            Text('Edit Weight', style: AppTextStyles.headingSmall),
            SizedBox(height: 20.h),
            Center(
              child: Text(
                '$_weight kg',
                style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
              ),
            ),
            SizedBox(height: 20.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () { if (_weight > 30) setState(() => _weight--); },
                  child: Container(
                    width: 48.r, height: 48.r,
                    decoration: const BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle),
                    child: Icon(Icons.remove, color: AppColors.textPrimary, size: 24.r),
                  ),
                ),
                SizedBox(width: 32.w),
                GestureDetector(
                  onTap: () { if (_weight < 300) setState(() => _weight++); },
                  child: Container(
                    width: 48.r, height: 48.r,
                    decoration: const BoxDecoration(color: AppColors.borderLight, shape: BoxShape.circle),
                    child: Icon(Icons.add, color: AppColors.textPrimary, size: 24.r),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24.h),
            _SaveButton(saving: _saving, onPressed: () => _save({'weight_kg': _weight.toDouble()})),
          ],
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, String value, IconData icon, String subtitle) {
    final selected = _selectedGoal == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedGoal = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: selected ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: selected ? null : [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r, height: 44.r,
              decoration: BoxDecoration(color: selected ? AppColors.primaryLight : AppColors.borderLight, borderRadius: BorderRadius.circular(10.r)),
              child: Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
              ]),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20.r),
          ],
        ),
      ),
    );
  }

  Widget _buildPaceCard(String title, String value, String speed, String description) {
    final selected = _selectedPace == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedPace = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: selected ? AppColors.primaryLight.withValues(alpha: 0.3) : AppColors.backgroundWhite,
          border: selected ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: selected ? null : [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(speed, style: TextStyle(fontSize: 13.sp, color: AppColors.primary, fontWeight: FontWeight.w600)),
                Text(description, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
              ]),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20.r),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityCard(String title, String value, IconData icon, String subtitle) {
    final selected = _selectedActivity == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedActivity = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          border: selected ? Border.all(color: AppColors.primary, width: 2) : null,
          boxShadow: selected ? null : [BoxShadow(color: AppColors.textPrimary.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 6))],
          borderRadius: BorderRadius.circular(16.r),
        ),
        child: Row(
          children: [
            Container(
              width: 44.r, height: 44.r,
              decoration: BoxDecoration(color: selected ? AppColors.primaryLight : AppColors.borderLight, borderRadius: BorderRadius.circular(10.r)),
              child: Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 22.r),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                Text(subtitle, style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
              ]),
            ),
            if (selected) Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 20.r),
          ],
        ),
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({required this.saving, required this.onPressed});
  final bool saving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56.h,
      child: FilledButton(
        onPressed: saving ? null : onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          disabledBackgroundColor: AppColors.primary.withValues(alpha: 0.4),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(100.r)),
        ),
        child: saving
            ? SizedBox(width: 22.r, height: 22.r, child: const CircularProgressIndicator(color: AppColors.textWhite, strokeWidth: 2))
            : Text('Save', style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: AppColors.textWhite)),
      ),
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
                    color: AppColors.textWhite.withValues(alpha: 0.8),
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
// ─── SETTINGS MENU CARD ───────────────────────────────────────────────────────

class _SettingsMenuCard extends StatelessWidget {
  const _SettingsMenuCard();

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
        _Card(
          child: Column(
            children: [
              _buildRow(context, Icons.notifications_outlined, AppColors.borderLight, AppColors.textSecondary, 'Notifications', null),
              Divider(color: AppColors.border, height: 1),
              _buildRow(context, Icons.help_outline, AppColors.borderLight, AppColors.textSecondary, 'Help & Support', null),
              Divider(color: AppColors.border, height: 1),
              _buildRow(context, Icons.lock_outline, AppColors.borderLight, AppColors.textSecondary, 'Change Password', AppRoutes.changePassword),
              Divider(color: AppColors.border, height: 1),
              _buildRow(context, Icons.shield_outlined, AppColors.borderLight, AppColors.textSecondary, 'Privacy Policy', AppRoutes.privacyPolicy),
              Divider(color: AppColors.border, height: 1),
              _buildRow(context, Icons.description_outlined, AppColors.borderLight, AppColors.textSecondary, 'Terms of Service', AppRoutes.termsOfService),
              Divider(color: AppColors.border, height: 1),
              _buildRow(context, Icons.logout_rounded, AppColors.borderLight, AppColors.textSecondary, 'Sign Out', null,
                onTap: () async {
                  await AuthRepository().signOut();
                  if (context.mounted) context.go(AppRoutes.login);
                },
              ),
              Divider(color: AppColors.border, height: 1),
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
        color: AppColors.textWhite.withValues(alpha: 0.75),
      );
}
