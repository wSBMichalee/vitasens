import re

# 1. MacrosCalculator.ts
calc_path = 'supabase/functions/calculate-daily-macros/MacrosCalculator.ts'
with open(calc_path, 'r') as f:
    calc = f.read()

streak_method = """  static calculateStreak(
    weeklyData: { date: string, macros: DailyMacros }[],
    targets: MacroTargets,
    today: string
  ): number {
    const map = new Map<string, DailyProgress>();
    weeklyData.forEach(d => map.set(d.date, this.calculateDailyProgress(d.date, d.macros, targets)));

    let streak = 0;
    const cursor = new Date(today + 'T00:00:00Z');

    const todayProgress = map.get(today);
    if (!todayProgress || todayProgress.mealsCount === 0) {
      cursor.setUTCDate(cursor.getUTCDate() - 1);
    }

    while (true) {
      const dateStr = cursor.toISOString().split('T')[0];
      const day = map.get(dateStr);
      if (!day || day.mealsCount === 0 || !day.isGoalMet) break;
      streak++;
      cursor.setUTCDate(cursor.getUTCDate() - 1);
    }

    return streak;
  }
"""

if 'calculateStreak' not in calc:
    calc = calc.replace('static calculateWeeklyProgress(', streak_method + '\n  static calculateWeeklyProgress(')
    with open(calc_path, 'w') as f:
        f.write(calc)


# 2. index.ts
idx_path = 'supabase/functions/calculate-daily-macros/index.ts'
with open(idx_path, 'r') as f:
    idx = f.read()

old_daily = """      case 'daily': {
        const { date } = DailyMacrosSchema.parse({ ...data, userId });
        const [m, t] = await Promise.all([
          MacrosRepository.getDailyTotals(userId, date),
          ProfileRepository.getTargets(userId)
        ]) as [DailyMacros, MacroTargets];
        res = MacrosCalculator.calculateDailyProgress(date, m, t);
        break;
      }"""

new_daily = """      case 'daily': {
        const { date } = DailyMacrosSchema.parse({ ...data, userId });
        const [m, t] = await Promise.all([
          MacrosRepository.getDailyTotals(userId, date),
          ProfileRepository.getTargets(userId)
        ]) as [DailyMacros, MacroTargets];

        const startDateObj = new Date(date + 'T00:00:00Z');
        startDateObj.setUTCDate(startDateObj.getUTCDate() - 59);
        const startDate = startDateObj.toISOString().split('T')[0];
        const weeklyForStreak = await MacrosRepository.getWeeklyTotals(userId, startDate, date);
        const streakDays = MacrosCalculator.calculateStreak(weeklyForStreak, t, date);

        const dailyProgress = MacrosCalculator.calculateDailyProgress(date, m, t);
        res = { ...dailyProgress, streakDays };
        break;
      }"""

if 'calculateStreak' not in idx:
    idx = idx.replace(old_daily, new_daily)
    with open(idx_path, 'w') as f:
        f.write(idx)


# 3. home_screen_content.dart
home_path = 'lib/features/macros/presentation/screens/home_screen_content.dart'
with open(home_path, 'r') as f:
    home = f.read()

# Imports
if 'import \'package:vitasense/features/macros/bloc/macros_bloc.dart\';' not in home:
    imports = """import 'package:vitasense/features/macros/bloc/macros_bloc.dart';
import 'package:vitasense/features/macros/bloc/macros_event.dart';
import 'package:vitasense/features/macros/bloc/macros_state.dart';
import 'package:vitasense/features/macros/data/macros_repository.dart';
"""
    home = imports + home

# BlocProvider wrapping
old_provider = """    return BlocProvider<WaterBloc>(
      create: (context) => WaterBloc()..add(LoadWater()),
      child: BlocProvider<DailyLogBloc>("""
new_provider = """    return BlocProvider<MacrosBloc>(
      create: (context) => MacrosBloc(repository: MacrosRepository())
        ..add(LoadDailyMacros(DateTime.now().toIso8601String().split('T')[0])),
      child: BlocProvider<WaterBloc>(
        create: (context) => WaterBloc()..add(LoadWater()),
        child: BlocProvider<DailyLogBloc>("""
home = home.replace(old_provider, new_provider)

# Additional closing paren at the end of the widget
old_closing = """        ),
      ),
      ),
    );
  }
}"""
new_closing = """        ),
      ),
      ),
      ),
    );
  }
}"""
home = home.replace(old_closing, new_closing)

# Streak pill
old_pill = """                  Container(
                    height: 36.r,
                    padding: EdgeInsets.symmetric(horizontal: 10.w),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWhite,
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.local_fire_department_rounded, color: const Color(0xFFFACC15), size: 16.r),
                        SizedBox(width: 4.w),
                        Text('5', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                      ],
                    ),
                  ),"""

new_pill = """                  GestureDetector(
                    onTap: () => context.push(AppRoutes.progress),
                    child: BlocBuilder<MacrosBloc, MacrosState>(
                      builder: (context, state) {
                        final streak = state is MacrosLoaded ? state.streakDays : 0;
                        return Container(
                          height: 36.r,
                          padding: EdgeInsets.symmetric(horizontal: 10.w),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundWhite,
                            borderRadius: BorderRadius.circular(20.r),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.local_fire_department_rounded, color: const Color(0xFFFACC15), size: 16.r),
                              SizedBox(width: 4.w),
                              Text('$streak', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w900, color: AppColors.textPrimary)),
                            ],
                          ),
                        );
                      },
                    ),
                  ),"""
home = home.replace(old_pill, new_pill)

with open(home_path, 'w') as f:
    f.write(home)

print("Python script completed.")
