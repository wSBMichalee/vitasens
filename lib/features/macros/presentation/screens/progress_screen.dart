import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/features/macros/bloc/macros_bloc.dart';
import 'package:vitasense/features/macros/bloc/macros_event.dart';
import 'package:vitasense/features/macros/bloc/macros_state.dart';
import 'package:vitasense/features/macros/data/macros_repository.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final now = DateTime.now();
        final today = now.toIso8601String().split('T')[0];
        final weekStart =
            now.subtract(Duration(days: now.weekday - 1));
        final weekStartStr = weekStart.toIso8601String().split('T')[0];

        return MacrosBloc(repository: MacrosRepository())
          ..add(LoadDailyMacros(today))
          ..add(LoadWeeklyMacros(weekStartStr, today));
      },
      child: const _ProgressView(),
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: BlocBuilder<MacrosBloc, MacrosState>(
          builder: (context, state) {
            if (state is MacrosLoading || state is MacrosInitial) {
              return _buildShimmer();
            }
            if (state is MacrosError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        color: AppColors.error, size: 48.r),
                    SizedBox(height: 12.h),
                    Text(state.message,
                        style: AppTextStyles.bodyMedium,
                        textAlign: TextAlign.center),
                  ],
                ),
              );
            }

            if (state is MacrosLoaded) {
              return _buildContent(context, state);
            }

            return const SizedBox();
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, MacrosLoaded state) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── HEADER ──────────────────────────────────────────────
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Progress', style: AppTextStyles.headingLarge),
                  Text('Stay consistent', style: AppTextStyles.bodyMedium),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.warningLight,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('✨', style: TextStyle(fontSize: 16.sp)),
                    SizedBox(width: 4.w),
                    Text(
                      '${state.streakDays}',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 24.h),

          // ─── WEEKLY CONSISTENCY CARD ─────────────────────────────
          _WeeklyConsistencyCard(weekly: state.weekly),

          SizedBox(height: 24.h),

          // ─── TODAY'S SUMMARY HEADER ───────────────────────────────
          Row(
            children: [
              Text(
                "TODAY'S SUMMARY",
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),
              Text(
                '${_safeInt(state.daily, ['calories', 'actual'])} kcal consumed',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.secondary,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // ─── MACROS CARD ─────────────────────────────────────────
          _MacrosSummaryCard(daily: state.daily),

          SizedBox(height: 24.h),

          // ─── RECENT MEALS ─────────────────────────────────────────
          Text(
            'RECENT MEALS',
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              letterSpacing: 0.5,
            ),
          ),

          SizedBox(height: 12.h),

          state.meals.isEmpty
              ? Container(
                  padding: EdgeInsets.all(20.r),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWhite,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Center(
                    child: Text('No meals logged today',
                        style: AppTextStyles.bodyMedium),
                  ),
                )
              : ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: state.meals.length,
                  itemBuilder: (context, index) =>
                      _MealHistoryCard(meal: state.meals[index]),
                ),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      child: Column(
        children: List.generate(
          4,
          (i) => Container(
            margin: EdgeInsets.only(bottom: 16.h),
            height: i == 0 ? 60.h : 120.h,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(16.r),
            ),
          ),
        ),
      ),
    );
  }

  int _safeInt(Map<String, dynamic> map, List<String> keys) {
    dynamic val = map;
    for (final key in keys) {
      if (val is Map<String, dynamic> && val.containsKey(key)) {
        val = val[key];
      } else {
        return 0;
      }
    }
    if (val is int) return val;
    if (val is double) return val.toInt();
    return 0;
  }
}

// ─── WEEKLY CONSISTENCY CARD ─────────────────────────────────────────────────

class _WeeklyConsistencyCard extends StatelessWidget {
  final List<Map<String, dynamic>> weekly;

  const _WeeklyConsistencyCard({required this.weekly});

  @override
  Widget build(BuildContext context) {
    const days = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final todayIndex = DateTime.now().weekday - 1;

    return Container(
      padding: EdgeInsets.all(20.r),
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
              Text(
                'Weekly consistency',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Icon(Icons.trending_up, color: AppColors.primary, size: 20.r),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "YOU'RE DOING BETTER THAN LAST WEEK",
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days.asMap().entries.map((entry) {
              final index = entry.key;
              final day = entry.value;

              final dayData = weekly.length > index ? weekly[index] : null;
              final isToday = index == todayIndex;
              final isCompleted = dayData != null &&
                  (dayData['completed'] == true ||
                      dayData['calories'] != null);
              final isMissed = index < todayIndex && !isCompleted;

              return _DayCard(
                day: day,
                isToday: isToday,
                isCompleted: isCompleted,
                isMissed: isMissed,
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DayCard extends StatelessWidget {
  final String day;
  final bool isToday;
  final bool isCompleted;
  final bool isMissed;

  const _DayCard({
    required this.day,
    required this.isToday,
    required this.isCompleted,
    required this.isMissed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: isToday ? AppColors.backgroundWhite : Colors.transparent,
        border: isToday
            ? Border.all(color: AppColors.textPrimary, width: 2)
            : null,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            day,
            style: TextStyle(
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
              color: isMissed ? AppColors.error : AppColors.textSecondary,
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 28.r,
            height: 28.r,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted
                  ? AppColors.primary
                  : isMissed
                      ? AppColors.errorLight
                      : AppColors.borderLight,
            ),
            child: Icon(
              isCompleted
                  ? Icons.check
                  : isMissed
                      ? Icons.close
                      : Icons.remove,
              size: 14.r,
              color: isCompleted
                  ? AppColors.textWhite
                  : isMissed
                      ? AppColors.error
                      : AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── MACROS SUMMARY CARD ─────────────────────────────────────────────────────

class _MacrosSummaryCard extends StatelessWidget {
  final Map<String, dynamic> daily;

  const _MacrosSummaryCard({required this.daily});

  @override
  Widget build(BuildContext context) {
    final protein = daily['protein'] as Map<String, dynamic>? ?? {};
    final carbs = daily['carbs'] as Map<String, dynamic>? ?? {};
    final fat = daily['fat'] as Map<String, dynamic>? ?? {};

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          _MacroRow(
            icon: Icons.shield_outlined,
            iconColor: AppColors.proteinColor,
            iconBg: AppColors.secondaryLight,
            label: 'Protein',
            actual: _toInt(protein['actual']),
            target: _toInt(protein['target']),
            unit: 'g',
          ),
          Divider(color: AppColors.border, height: 20.h),
          _MacroRow(
            icon: Icons.eco_outlined,
            iconColor: AppColors.primary,
            iconBg: AppColors.primaryLight,
            label: 'Carbs',
            actual: _toInt(carbs['actual']),
            target: _toInt(carbs['target']),
            unit: 'g',
          ),
          Divider(color: AppColors.border, height: 20.h),
          _MacroRow(
            icon: Icons.local_fire_department_outlined,
            iconColor: AppColors.fatColor,
            iconBg: AppColors.warningLight,
            label: 'Fat',
            actual: _toInt(fat['actual']),
            target: _toInt(fat['target']),
            unit: 'g',
          ),
        ],
      ),
    );
  }

  int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is double) return val.toInt();
    return 0;
  }
}

class _MacroRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String label;
  final int actual;
  final int target;
  final String unit;

  const _MacroRow({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.label,
    required this.actual,
    required this.target,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, color: iconColor, size: 20.r),
        ),
        SizedBox(width: 12.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 15.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          '$actual/$target$unit',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─── MEAL HISTORY CARD ────────────────────────────────────────────────────────

class _MealHistoryCard extends StatelessWidget {
  final Map<String, dynamic> meal;

  const _MealHistoryCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    final name = meal['foodName']?.toString() ?? meal['name']?.toString() ?? 'Unknown';
    final calories = meal['calories'] ?? 0;
    final imageUrl = meal['image']?.toString();

    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            width: 56.r,
            height: 56.r,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: imageUrl != null && imageUrl.isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.restaurant,
                        color: AppColors.textMuted,
                        size: 24.r,
                      ),
                    ),
                  )
                : Icon(Icons.restaurant, color: AppColors.textMuted, size: 24.r),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  '$calories KCAL • +1 DAY STREAK',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: AppColors.textMuted, size: 20.r),
        ],
      ),
    );
  }
}
