import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vitasense/features/auth/data/auth_repository.dart';
import 'package:vitasense/core/services/cache_service.dart';
import 'package:vitasense/features/macros/bloc/macros_bloc.dart';
import 'package:vitasense/features/macros/bloc/macros_event.dart';
import 'package:vitasense/core/utils/bottom_sheet_utils.dart';
import 'profile_shimmer.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/auth/bloc/auth_bloc.dart';
import 'package:vitasense/features/auth/bloc/auth_event.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';

class MyGoalsCard extends StatelessWidget {
  const MyGoalsCard({super.key, required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return ProfileShimmerCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('My Goals', style: AppTextStyles.headingSmall),
            ],
          ),
          SizedBox(height: 16.h),
          GoalRow(
            icon: Icons.track_changes_outlined,
            iconBg: AppColors.primaryLight,
            iconColor: AppColors.primaryDark,
            label: 'Goal',
            value: _goalLabel(user.goalType),
            onTap: () => _showEditSheet(context, 'goal', user),
          ),
          Divider(color: AppColors.border, height: 20.h),
          GoalRow(
            icon: Icons.speed_outlined,
            iconBg: AppColors.secondaryLight,
            iconColor: AppColors.secondary,
            label: 'Pace',
            value: _paceLabel(user.goalPace),
            onTap: () => _showEditSheet(context, 'pace', user),
          ),
          Divider(color: AppColors.border, height: 20.h),
          GoalRow(
            icon: Icons.directions_run_outlined,
            iconBg: AppColors.warningLight,
            iconColor: AppColors.warning,
            label: 'Activity',
            value: _activityLabel(user.activityLevel),
            onTap: () => _showEditSheet(context, 'activity', user),
          ),
          Divider(color: AppColors.border, height: 20.h),
          GoalRow(
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
      case 'general_health':
        return 'General Health';
      case 'weight_loss':
        return 'Weight Loss';
      case 'muscle_gain':
        return 'Muscle Gain';
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
        return 'Aggressive';
      default:
        return 'Not set';
    }
  }

  static String _activityLabel(String? activity) {
    switch (activity) {
      case 'sedentary':
        return 'Sedentary';
      case 'moderate':
        return 'Moderately Active';
      case 'active':
        return 'Very Active';
      default:
        return 'Not set';
    }
  }

  void _showEditSheet(BuildContext context, String type, UserModel user) {
    showAppBottomSheet(
      context: context,
      builder: (_) => EditGoalSheet(type: type, user: user),
    ).then((_) {
      if (context.mounted) {
        context.read<AuthBloc>().add(const AppStarted());
        context.read<MacrosBloc>().add(LoadDailyMacros(DateTime.now().toIso8601String().split('T')[0]));
      }
    });
  }
}

class GoalRow extends StatelessWidget {
  const GoalRow({super.key, 
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

class EditGoalSheet extends StatefulWidget {
  const EditGoalSheet({super.key, required this.type, required this.user});
  final String type;
  final UserModel user;

  @override
  State<EditGoalSheet> createState() => EditGoalSheetState();
}

class EditGoalSheetState extends State<EditGoalSheet> {
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
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      await supabase
          .from('profiles')
          .update(data)
          .eq('id', userId);

      await AuthRepository().calculateTargets();
      CacheService().invalidate('user_profile');
      CacheService().invalidate('user_targets');

      if (mounted) {
        Navigator.pop(context, true);
      }
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
      height: MediaQuery.of(context).size.height * 0.6,
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
          ),
          SizedBox(height: 24.h),
          if (widget.type == 'goal') ...[
            Text('Edit Goal', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildGoalCard('General Health', 'general_health', Icons.health_and_safety, 'Overall well-being'),
                    SizedBox(height: 10.h),
                    _buildGoalCard('Lose Weight', 'weight_loss', Icons.trending_down, 'Burn fat with smart meals'),
                    SizedBox(height: 10.h),
                    _buildGoalCard('Build Muscle', 'muscle_gain', Icons.fitness_center, 'High protein meals for growth'),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            SaveButton(saving: _saving, onPressed: () => _save({'goal_type': _selectedGoal})),
          ] else if (widget.type == 'pace') ...[
            Text('Edit Pace', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildPaceCard('Slow & Steady', 'slow', '~0.25kg/week', 'More sustainable, easier to maintain'),
                    SizedBox(height: 10.h),
                    _buildPaceCard('Moderate', 'moderate', '~0.5kg/week', 'Balanced approach, recommended'),
                    SizedBox(height: 10.h),
                    _buildPaceCard('Fast', 'fast', '~0.75kg/week', 'Requires strict discipline'),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
            ),
            SaveButton(saving: _saving, onPressed: () => _save({'goal_pace': _selectedPace})),
          ] else if (widget.type == 'activity') ...[
            Text('Edit Activity', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 24.h),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
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
                  ],
                ),
              ),
            ),
            SaveButton(saving: _saving, onPressed: () => _save({'activity_level': _selectedActivity})),
          ] else if (widget.type == 'weight') ...[
            Text('Edit Weight', style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.bold, color: Colors.black)),
            SizedBox(height: 48.h),
            Expanded(
              child: Column(
                children: [
                  Center(
                    child: Text(
                      '$_weight kg',
                      style: TextStyle(fontSize: 48.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                  ),
                  SizedBox(height: 32.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () { if (_weight > 30) setState(() => _weight--); },
                        child: Container(
                          width: 56.r, height: 56.r,
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                          child: Icon(Icons.remove, color: Colors.black, size: 28.r),
                        ),
                      ),
                      SizedBox(width: 48.w),
                      GestureDetector(
                        onTap: () { if (_weight < 300) setState(() => _weight++); },
                        child: Container(
                          width: 56.r, height: 56.r,
                          decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8)]),
                          child: Icon(Icons.add, color: Colors.black, size: 28.r),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SaveButton(saving: _saving, onPressed: () => _save({'weight_kg': _weight.toDouble()})),
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

class SaveButton extends StatelessWidget {
  const SaveButton({super.key, required this.saving, required this.onPressed});
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

