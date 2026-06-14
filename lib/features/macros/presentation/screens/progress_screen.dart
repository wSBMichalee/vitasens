import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/core/theme/app_text_styles.dart';
import 'package:vitasense/core/widgets/app_header.dart';
import 'package:vitasense/features/macros/bloc/macros_bloc.dart';
import 'package:vitasense/features/macros/bloc/macros_event.dart';
import 'package:vitasense/features/macros/bloc/macros_state.dart';
import 'package:vitasense/features/macros/data/macros_repository.dart';
import 'package:vitasense/core/widgets/gradient_scaffold.dart';
import '../widgets/progress/weekly_consistency_card.dart';
import '../widgets/progress/today_summary_header.dart';
import '../widgets/progress/macros_list_card.dart';
import '../widgets/progress/recent_meals_list.dart';

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
                WeeklyConsistencyCard(weekly: state.weekly),

                SizedBox(height: 20.h),

                // ─── Today's summary header ──────────────────────────────
                TodaySummaryHeader(daily: state.daily),

                SizedBox(height: 12.h),

                // ─── Macros list card ────────────────────────────────────
                MacrosListCard(daily: state.daily),

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
                RecentMealsList(meals: state.meals),

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


// ─── Today's summary header ───────────────────────────────────────────────────


// ─── Macros list card ─────────────────────────────────────────────────────────




// ─── Recent meals list ────────────────────────────────────────────────────────

