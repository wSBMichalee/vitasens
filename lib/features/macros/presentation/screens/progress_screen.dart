import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/router/app_router.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/macros/bloc/macros_bloc.dart';
import 'package:vitasense/features/macros/bloc/macros_event.dart';
import 'package:vitasense/features/macros/bloc/macros_state.dart';
import 'package:vitasense/features/macros/data/macros_repository.dart';
import 'package:vitasense/core/widgets/gradient_scaffold.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) {
        final now = DateTime.now();
        final today = now.toIso8601String().split('T')[0];
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
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
    return GradientScaffold(
      body: SafeArea(
        child: BlocBuilder<MacrosBloc, MacrosState>(
          builder: (context, state) {
            if (state is MacrosLoading || state is MacrosInitial) {
              return _buildShimmer();
            }
            if (state is MacrosError) {
              return _buildError(context, state.message);
            }
            if (state is MacrosLoaded) {
              return _buildContent(context, state);
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  // ─── Shimmer ──────────────────────────────────────────────────────────────
  Widget _buildShimmer() {
    return Shimmer.fromColors(
      baseColor: AppColors.borderLight,
      highlightColor: AppColors.border,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Column(
          children: [
            _shimmerBox(h: 60.h),
            SizedBox(height: 16.h),
            _shimmerBox(h: 140.h),
            SizedBox(height: 16.h),
            _shimmerBox(h: 160.h),
            SizedBox(height: 16.h),
            _shimmerBox(h: 100.h),
          ],
        ),
      ),
    );
  }

  Widget _shimmerBox({required double h}) => Container(
        width: double.infinity,
        height: h,
        decoration: BoxDecoration(
          color: AppColors.backgroundWhite,
          borderRadius: BorderRadius.circular(16.r),
        ),
      );

  // ─── Error ────────────────────────────────────────────────────────────────
  Widget _buildError(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: AppColors.error, size: 48.r),
          SizedBox(height: 16.h),
          Text(message,
              style: AppTextStyles.bodyMedium, textAlign: TextAlign.center),
          SizedBox(height: 16.h),
          SizedBox(
            height: 50.h,
            child: FilledButton(
              onPressed: () => context.read<MacrosBloc>().add(
                    LoadDailyMacros(
                        DateTime.now().toIso8601String().split('T')[0]),
                  ),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r)),
              ),
              child: Text(
                'Retry',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textWhite,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Main content ─────────────────────────────────────────────────────────
  Widget _buildContent(BuildContext context, MacrosLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── AppHeader: wariant main, streak pill jako action ──────────────
        AppHeader(
          title: 'Progress',
          subtitle: 'Stay consistent',
          variant: AppHeaderVariant.main,
          backgroundColor: AppColors.primary,
          textColor: AppColors.textWhite,
          actions: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
              decoration: BoxDecoration(
                color: AppColors.warningLight,
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(color: AppColors.warningBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('✨', style: TextStyle(fontSize: 14.sp)),
                  SizedBox(width: 4.w),
                  Text(
                    '${state.streakDays}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: AppColors.warningDark,
                      fontFamily: AppTextStyles.numberMedium.fontFamily,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // ── Scrollable body ───────────────────────────────────────────────
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Weekly consistency ──────────────────────────────────
                _WeeklyConsistencyCard(weekly: state.weekly),

                SizedBox(height: 20.h),

                // ─── Today's summary header ──────────────────────────────
                _TodaySummaryHeader(daily: state.daily),

                SizedBox(height: 12.h),

                // ─── Macros list card ────────────────────────────────────
                _MacrosListCard(daily: state.daily),

                SizedBox(height: 20.h),

                // ─── Recent meals ────────────────────────────────────────
                Text(
                  'RECENT MEALS',
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                    letterSpacing: 0.8,
                  ),
                ),
                SizedBox(height: 12.h),
                _RecentMealsList(meals: state.meals),

                SizedBox(height: 16.h),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Weekly consistency card ──────────────────────────────────────────────────
class _WeeklyConsistencyCard extends StatelessWidget {
  const _WeeklyConsistencyCard({required this.weekly});
  final List<Map<String, dynamic>> weekly;

  @override
  Widget build(BuildContext context) {
    const labels = ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'];
    final todayIndex = DateTime.now().weekday - 1;

    return Container(
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
                      'Weekly consistency',
                      style: TextStyle(
                        fontSize: 17.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      "YOU'RE DOING BETTER THAN LAST WEEK",
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.trending_up_rounded,
                  color: AppColors.primary, size: 22.r),
            ],
          ),

          SizedBox(height: 16.h),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(labels.length, (i) {
              final data = weekly.length > i ? weekly[i] : null;
              final isCompleted = data != null &&
                  (data['completed'] == true || data['calories'] != null);
              final isMissed = i < todayIndex && !isCompleted;

              return Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 34.r,
                      height: 34.r,
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
                        size: 15.r,
                        color: isCompleted
                            ? AppColors.textWhite
                            : isMissed
                                ? AppColors.error
                                : AppColors.textMuted,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 9.sp,
                        fontWeight: FontWeight.w600,
                        color: isMissed
                            ? AppColors.error
                            : AppColors.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

// ─── Today's summary header ───────────────────────────────────────────────────
class _TodaySummaryHeader extends StatelessWidget {
  const _TodaySummaryHeader({required this.daily});
  final Map<String, dynamic> daily;

  int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is double) return val.toInt();
    return 0;
  }

  String _formatCalories(int cal) {
    if (cal >= 1000) {
      final thousands = cal ~/ 1000;
      final remainder = (cal % 1000).toString().padLeft(3, '0');
      return '$thousands,$remainder';
    }
    return '$cal';
  }

  @override
  Widget build(BuildContext context) {
    final calories = _toInt(
        (daily['calories'] as Map<String, dynamic>?)?['actual'] ??
            daily['calories']);

    return Row(
      children: [
        Text(
          "TODAY'S SUMMARY",
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textSecondary,
            letterSpacing: 0.8,
          ),
        ),
        const Spacer(),
        Text(
          '${_formatCalories(calories)} kcal consumed',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

// ─── Macros list card ─────────────────────────────────────────────────────────
class _MacrosListCard extends StatelessWidget {
  const _MacrosListCard({required this.daily});
  final Map<String, dynamic> daily;

  int _toInt(dynamic val) {
    if (val is int) return val;
    if (val is double) return val.toInt();
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final protein = daily['protein'] as Map<String, dynamic>? ?? {};
    final carbs = daily['carbs'] as Map<String, dynamic>? ?? {};
    final fat = daily['fat'] as Map<String, dynamic>? ?? {};

    return Container(
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
      child: Column(
        children: [
          _MacroRow(
            icon: Icons.shield_outlined,
            iconBg: AppColors.secondaryLight,
            iconColor: AppColors.proteinColor,
            label: 'Protein',
            actual: _toInt(protein['actual']),
            target: _toInt(protein['target']),
          ),
          Divider(
              color: AppColors.border,
              height: 1,
              thickness: 1,
              indent: 68.w,
              endIndent: 0),
          _MacroRow(
            icon: Icons.eco_outlined,
            iconBg: AppColors.primaryLight,
            iconColor: AppColors.primary,
            label: 'Carbs',
            actual: _toInt(carbs['actual']),
            target: _toInt(carbs['target']),
          ),
          Divider(
              color: AppColors.border,
              height: 1,
              thickness: 1,
              indent: 68.w,
              endIndent: 0),
          _MacroRow(
            icon: Icons.local_fire_department_outlined,
            iconBg: AppColors.warningLight,
            iconColor: AppColors.fatColor,
            label: 'Fat',
            actual: _toInt(fat['actual']),
            target: _toInt(fat['target']),
          ),
        ],
      ),
    );
  }
}

class _MacroRow extends StatelessWidget {
  const _MacroRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.actual,
    required this.target,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final int actual;
  final int target;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      child: Row(
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
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 15.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Text(
            '$actual/${target}g',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Recent meals list ────────────────────────────────────────────────────────
class _RecentMealsList extends StatelessWidget {
  const _RecentMealsList({required this.meals});
  final List<Map<String, dynamic>> meals;

  static const String _fallbackImageUrl =
      'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=400&q=80';

  @override
  Widget build(BuildContext context) {
    if (meals.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24.r),
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
        child: Center(
          child: Column(
            children: [
              Icon(Icons.restaurant_outlined,
                  color: AppColors.textMuted, size: 36.r),
              SizedBox(height: 8.h),
              Text(
                'No meals logged today',
                style:
                    TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
              ),
              SizedBox(height: 16.h),
              SizedBox(
                height: 44.h,
                child: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.aiMeals),
                  icon: Icon(Icons.auto_awesome, size: 18.r),
                  label: Text(
                    'Get AI Meals',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.primaryLight,
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
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
      child: ListView.separated(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: meals.length,
        separatorBuilder: (_, __) =>
            const Divider(color: AppColors.border, height: 1, thickness: 1),
        itemBuilder: (_, i) {
          final meal = meals[i];
          final name =
              (meal['name'] ?? meal['title'] ?? 'Meal').toString();
          final calories = meal['calories'] is int
              ? meal['calories'] as int
              : meal['calories'] is double
                  ? (meal['calories'] as double).toInt()
                  : 0;
          final imageUrl =
              (meal['imageUrl'] ?? meal['image_url'] ?? _fallbackImageUrl)
                  .toString();
          final streak = meal['streak'] as int? ?? 1;

          return Padding(
            padding:
                EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(10.r),
                  child: SizedBox(
                    width: 60.r,
                    height: 60.r,
                    child: CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Shimmer.fromColors(
                        baseColor: AppColors.border,
                        highlightColor: AppColors.borderLight,
                        child: Container(color: AppColors.border),
                      ),
                      errorWidget: (_, __, ___) =>
                          Container(color: AppColors.borderLight),
                    ),
                  ),
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
                      SizedBox(height: 4.h),
                      Text(
                        '$calories KCAL  •  +$streak DAY STREAK',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right,
                    color: AppColors.textMuted, size: 20.r),
              ],
            ),
          );
        },
      ),
    );
  }
}
