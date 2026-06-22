import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/auth/data/models/user_model.dart';

class DailyTargetsCard extends StatefulWidget {
  const DailyTargetsCard({super.key, required this.user});

  final UserModel user;

  @override
  State<DailyTargetsCard> createState() => DailyTargetsCardState();
}

class DailyTargetsCardState extends State<DailyTargetsCard> {
  int _consumedCalories = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDailyCalories();
  }

  Future<void> _fetchDailyCalories() async {
    try {
      final now = DateTime.now();
      final firstDay = DateTime(now.year, now.month, 1);
      final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
      final lastDay = DateTime(now.year, now.month, daysInMonth, 23, 59, 59);
      
      final response = await Supabase.instance.client
          .from('meal_logs')
          .select('calories')
          .gte('logged_at', firstDay.toIso8601String())
          .lte('logged_at', lastDay.toIso8601String())
          .eq('user_id', widget.user.id);
          
      int sum = 0;
      for (final row in response) {
        sum += (row['calories'] as num?)?.toInt() ?? 0;
      }
      if (mounted) {
        setState(() {
          _consumedCalories = sum;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  String _formatMacro(int dailyValue, void Function(String) setUnit) {
    setUnit('g');
    return dailyValue.toString();
  }

  String _getMonthName() {
    const months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return months[DateTime.now().month - 1];
  }

  @override
  Widget build(BuildContext context) {
    String proteinUnit = 'g';
    String carbsUnit = 'g';
    String fatUnit = 'g';
    
    final int daysInMonth = DateTime(DateTime.now().year, DateTime.now().month + 1, 0).day;
    final proteinValue = _formatMacro((widget.user.dailyProteinTarget ?? 0) * daysInMonth, (u) => proteinUnit = u);
    final carbsValue = _formatMacro((widget.user.dailyCarbsTarget ?? 0) * daysInMonth, (u) => carbsUnit = u);
    final fatValue = _formatMacro((widget.user.dailyFatTarget ?? 0) * daysInMonth, (u) => fatUnit = u);
    
    final int dailyTarget = widget.user.dailyCalorieTarget ?? 0;
    final int monthlyTarget = dailyTarget * daysInMonth;
    final double progress = monthlyTarget > 0 ? (_consumedCalories / monthlyTarget).clamp(0.0, 1.0) : 0.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MONTHLY TARGETS',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.5,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Your nutrition this month',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(100.r),
                      ),
                      child: Text(
                        _getMonthName(),
                        style: TextStyle(
                          color: const Color(0xFF4CAF50),
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.flag_rounded, color: Colors.grey, size: 18.r),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.h),
            
            // Hero Calories
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(
                  '$monthlyTarget',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 42.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
                SizedBox(width: 6.w),
                Text(
                  'kcal',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Progress Bar
            if (!_loading) ...[
              Container(
                height: 4.h,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2.r),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: progress,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50),
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Text(
                '$_consumedCalories / $monthlyTarget kcal',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 10.sp,
                ),
              ),
            ],
            SizedBox(height: 20.h),
            
            // Macro Tiles
            Row(
              children: [
                PremiumMacroTile(
                  iconColor: Colors.blue,
                  value: proteinValue,
                  unit: proteinUnit,
                  label: 'Protein',
                ),
                Container(width: 1, height: 40.h, color: Colors.grey.withValues(alpha: 0.2)),
                PremiumMacroTile(
                  iconColor: const Color(0xFF4CAF50),
                  value: carbsValue,
                  unit: carbsUnit,
                  label: 'Carbs',
                ),
                Container(width: 1, height: 40.h, color: Colors.grey.withValues(alpha: 0.2)),
                PremiumMacroTile(
                  iconColor: Colors.orange,
                  value: fatValue,
                  unit: fatUnit,
                  label: 'Fat',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class PremiumMacroTile extends StatelessWidget {
  const PremiumMacroTile({super.key, 
    required this.iconColor,
    required this.value,
    required this.label,
    this.unit = 'g',
  });

  final Color iconColor;
  final String value;
  final String label;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 8.r,
            height: 8.r,
            decoration: BoxDecoration(
              color: iconColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                unit,
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

