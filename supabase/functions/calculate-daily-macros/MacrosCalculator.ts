import { DailyMacros } from './MacrosRepository.ts';
import { MacroTargets } from './ProfileRepository.ts';

export interface MacroProgress {
  actual: number;
  target: number;
  percentage: number;
  remaining: number;
}

export interface DailyProgress {
  date: string;
  protein: MacroProgress;
  carbs: MacroProgress;
  fat: MacroProgress;
  calories: MacroProgress;
  mealsCount: number;
  isGoalMet: boolean;
}

export interface WeeklyProgress {
  startDate: string;
  endDate: string;
  days: DailyProgress[];
  averageProtein: number;
  averageCarbs: number;
  averageFat: number;
  averageCalories: number;
  daysGoalMet: number;
}

export class MacrosCalculator {
  static calculateDailyProgress(
    date: string,
    macros: DailyMacros,
    targets: MacroTargets
  ): DailyProgress {
    const calcProgress = (actual: number, target: number): MacroProgress => ({
      actual,
      target,
      percentage: target > 0 ? Math.round((actual / target) * 100) : 0,
      remaining: Math.max(0, target - actual)
    });

    const protein = calcProgress(macros.totalProtein, targets.dailyProteinTarget);
    const carbs = calcProgress(macros.totalCarbs, targets.dailyCarbsTarget);
    const fat = calcProgress(macros.totalFat, targets.dailyFatTarget);
    const calories = calcProgress(macros.totalCalories, targets.dailyCaloriesTarget);

    const isGoalMet = protein.percentage >= 80 && carbs.percentage >= 70 && fat.percentage <= 120;

    return {
      date,
      protein,
      carbs,
      fat,
      calories,
      mealsCount: macros.mealsCount,
      isGoalMet
    };
  }

    static calculateStreak(
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

  static calculateWeeklyProgress(
    startDate: string,
    endDate: string,
    weeklyData: { date: string, macros: DailyMacros }[],
    targets: MacroTargets
  ): WeeklyProgress {
    const days = weeklyData.map(d => this.calculateDailyProgress(d.date, d.macros, targets));
    
    const count = days.length || 1;
    const sum = (fn: (d: DailyProgress) => number) => days.reduce((acc, d) => acc + fn(d), 0);

    return {
      startDate,
      endDate,
      days,
      averageProtein: Math.round(sum(d => d.protein.actual) / count),
      averageCarbs: Math.round(sum(d => d.carbs.actual) / count),
      averageFat: Math.round(sum(d => d.fat.actual) / count),
      averageCalories: Math.round(sum(d => d.calories.actual) / count),
      daysGoalMet: days.filter(d => d.isGoalMet).length
    };
  }

  static calculateCaloriesFromMacros(proteinG: number, carbsG: number, fatG: number): number {
    return Math.round(proteinG * 4 + carbsG * 4 + fatG * 9);
  }

  static getProgressLabel(percentage: number): string {
    if (percentage < 25) return 'Bardzo mało';
    if (percentage <= 50) return 'Mało';
    if (percentage <= 75) return 'Połowa';
    if (percentage <= 90) return 'Prawie';
    if (percentage <= 110) return 'Cel osiągnięty!';
    return 'Przekroczono';
  }

  static getMacroSplit(proteinG: number, carbsG: number, fatG: number): { proteinPercent: number, carbsPercent: number, fatPercent: number } {
    const totalCals = this.calculateCaloriesFromMacros(proteinG, carbsG, fatG) || 1;
    return {
      proteinPercent: Math.round((proteinG * 4 / totalCals) * 100),
      carbsPercent: Math.round((carbsG * 4 / totalCals) * 100),
      fatPercent: Math.round((fatG * 9 / totalCals) * 100)
    };
  }
}
