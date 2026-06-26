import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/services/health_service.dart';
import 'package:vitasense/core/theme/app_colors.dart';

class ActivityCard extends StatefulWidget {
  final int dailyCalorieTarget;
  const ActivityCard({super.key, required this.dailyCalorieTarget});

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  int _steps = 0;
  int _activeCalories = 0;
  bool _loading = true;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _loadHealthData();
  }

  Future<void> _loadHealthData() async {
    final health = HealthService();
    final hasPerms = await health.hasPermissions();
    if (!hasPerms) {
      final granted = await health.requestPermissions();
      if (!granted) {
        if (mounted) setState(() => _loading = false);
        return;
      }
    }
    final data = await health.getTodayData();
    if (mounted) {
      setState(() {
        _steps = data['steps'] ?? 0;
        _activeCalories = data['activeCalories'] ?? 0;
        _hasPermission = true;
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final adjustedGoal = widget.dailyCalorieTarget + _activeCalories;

    if (_loading) {
      return Container(
        height: 80.h,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: AppColors.border),
        ),
        child: Center(child: SizedBox(
          width: 20.r, height: 20.r,
          child: const CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
        )),
      );
    }

    if (!_hasPermission) {
      return GestureDetector(
        onTap: _loadHealthData,
        child: Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: AppColors.backgroundWhite,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(Icons.favorite_outline, color: AppColors.primary, size: 24.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Connect Health', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                    Text('Tap to sync steps & calories', style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20.r),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.favorite, color: AppColors.primary, size: 16.r),
              SizedBox(width: 6.w),
              Text('Activity Today', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: AppColors.textSecondary, letterSpacing: 0.5)),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _StatTile(
                icon: Icons.directions_walk_rounded,
                iconColor: Colors.blue,
                value: _formatSteps(_steps),
                label: 'Steps',
              ),
              Container(width: 1, height: 40.h, color: AppColors.border),
              _StatTile(
                icon: Icons.local_fire_department_rounded,
                iconColor: Colors.orange,
                value: '$_activeCalories',
                label: 'Burned kcal',
              ),
              Container(width: 1, height: 40.h, color: AppColors.border),
              _StatTile(
                icon: Icons.restaurant_rounded,
                iconColor: AppColors.primary,
                value: '$adjustedGoal',
                label: 'Adjusted goal',
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatSteps(int steps) {
    if (steps >= 1000) return '${(steps / 1000).toStringAsFixed(1)}k';
    return '$steps';
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatTile({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: iconColor, size: 20.r),
          SizedBox(height: 6.h),
          Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
          SizedBox(height: 2.h),
          Text(label, style: TextStyle(fontSize: 10.sp, color: AppColors.textSecondary)),
        ],
      ),
    );
  }
}
