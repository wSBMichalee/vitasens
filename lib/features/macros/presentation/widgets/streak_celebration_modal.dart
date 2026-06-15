import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vitasense/core/services/cache_service.dart';
import 'package:vitasense/core/theme/app_colors.dart';
import 'package:vitasense/features/macros/data/macros_repository.dart';

/// Sprawdza czy pokazać modal celebracji streaka i ewentualnie go wyświetla.
/// Wywołać po udanym zalogowaniu posiłku.
Future<void> maybeShowStreakCelebration(BuildContext context) async {
  final today = DateTime.now().toIso8601String().split('T')[0];

  try {
    final prefs = await SharedPreferences.getInstance();
    final lastShown = prefs.getString('last_streak_celebration_date');
    if (lastShown == today) return;

    final repo = MacrosRepository();
    CacheService().invalidate('daily_macros_$today');

    final daily = await repo.getDailyMacros(today);
    final isGoalMet = daily['isGoalMet'] as bool? ?? false;
    final streakDays = (daily['streakDays'] as int?) ?? 0;

    if (!isGoalMet || streakDays <= 0) return;

    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final mondayStr = monday.toIso8601String().split('T')[0];
    CacheService().invalidate('weekly_macros_${mondayStr}_$today');

    final weekly = await repo.getWeeklyMacros(mondayStr, today);
    final days = (weekly['days'] as List<dynamic>?)
            ?.map((e) => Map<String, dynamic>.from(e as Map))
            .toList() ??
        [];

    await prefs.setString('last_streak_celebration_date', today);

    if (!context.mounted) return;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StreakCelebrationModal(streakDays: streakDays, weekDays: days),
    );
  } catch (_) {
    // Celebracja jest opcjonalna - błąd nie powinien przerywać głównego flow.
  }
}

class StreakCelebrationModal extends StatelessWidget {
  final int streakDays;
  final List<Map<String, dynamic>> weekDays;

  const StreakCelebrationModal({
    super.key,
    required this.streakDays,
    required this.weekDays,
  });

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    final todayStr = now.toIso8601String().split('T')[0];
    const labels = ['Pn', 'Wt', 'Śr', 'Cz', 'Pt', 'Sb', 'Nd'];

    return Container(
      padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 32.h),
      decoration: BoxDecoration(
        color: AppColors.backgroundWhite,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header: branding + streak pill
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.eco_rounded, color: AppColors.primary, size: 18.r),
                  SizedBox(width: 6.w),
                  Text('VitaSense',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 14.r),
                    SizedBox(width: 4.w),
                    Text('$streakDays',
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600, color: AppColors.primary)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),

          // Duży flame icon ze streak number
          SizedBox(
            width: 110.r,
            height: 110.r,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.local_fire_department_rounded, color: AppColors.primary, size: 110.r),
                Padding(
                  padding: EdgeInsets.only(top: 20.h),
                  child: Text('$streakDays',
                      style: TextStyle(fontSize: 32.sp, fontWeight: FontWeight.w700, color: AppColors.backgroundWhite)),
                ),
              ],
            ),
          ),
          SizedBox(height: 12.h),

          Text('$streakDays ${streakDays == 1 ? "dzień" : "dni"} z rzędu',
              style: TextStyle(fontSize: 22.sp, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          SizedBox(height: 4.h),
          Text('Świetna konsekwencja w realizacji celu',
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary)),
          SizedBox(height: 24.h),

          // Tydzień - 7 kółek
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final date = monday.add(Duration(days: i));
              final dateStr = date.toIso8601String().split('T')[0];
              final isToday = dateStr == todayStr;
              final dayData = weekDays.firstWhere(
                (d) => d['date'] == dateStr,
                orElse: () => <String, dynamic>{},
              );
              final goalMet = dayData['isGoalMet'] as bool? ?? false;

              return Column(
                children: [
                  Text(labels[i],
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isToday ? FontWeight.w600 : FontWeight.w400,
                        color: isToday ? AppColors.textPrimary : AppColors.textSecondary,
                      )),
                  SizedBox(height: 6.h),
                  Container(
                    width: 28.r,
                    height: 28.r,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: goalMet ? AppColors.primaryLight : Colors.transparent,
                      border: Border.all(
                        color: isToday ? AppColors.primary : AppColors.border,
                        width: isToday ? 1.5 : 0.5,
                      ),
                    ),
                    child: goalMet
                        ? Icon(Icons.check_rounded, color: AppColors.primary, size: 14.r)
                        : null,
                  ),
                ],
              );
            }),
          ),
          SizedBox(height: 24.h),

          Text('Jesteś na dobrej drodze! Wróć jutro, by kontynuować passę.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.sp, color: AppColors.textSecondary, height: 1.4)),
          SizedBox(height: 20.h),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.backgroundWhite,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
              ),
              child: Text('Kontynuuj',
                  style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
