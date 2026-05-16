import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { NotFoundError } from '../_shared/errorHandler.ts';

export interface DailyMacros {
  totalProtein: number;
  totalCarbs: number;
  totalFat: number;
  totalCalories: number;
  mealsCount: number;
}

export interface LoggedMeal {
  id: string;
  userId: string;
  mealDate: string;
  mealTime: string;
  foodName: string;
  photoUrl?: string;
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
  source: string;
  confidence?: number;
  createdAt: string;
}

export interface LogMealDTO {
  userId: string;
  mealDate: string;
  mealTime: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  foodName: string;
  photoUrl?: string;
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
  source: 'ai_detection' | 'manual';
  confidence?: number;
}

export class MacrosRepository {
  static async getDailyTotals(userId: string, date: string): Promise<DailyMacros> {
    console.log('Getting daily macros for:', userId, date);
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase.rpc('get_daily_macros', {
      p_user_id: userId,
      p_date: date
    });

    if (error) throw new Error(`Failed to fetch daily macros: ${error.message}`);
    
    const result = data[0] || {};
    return {
      totalProtein: Number(result.total_protein) || 0,
      totalCarbs: Number(result.total_carbs) || 0,
      totalFat: Number(result.total_fat) || 0,
      totalCalories: Number(result.total_calories) || 0,
      mealsCount: Number(result.meals_count) || 0
    };
  }

  static async getMealsForDay(userId: string, date: string): Promise<LoggedMeal[]> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('meals')
      .select('*')
      .eq('user_id', userId)
      .eq('meal_date', date)
      .order('created_at', { ascending: true });

    if (error) throw new Error(`Failed to fetch meals: ${error.message}`);
    return (data || []).map(this.mapToEntity);
  }

  static async logMeal(data: LogMealDTO): Promise<LoggedMeal> {
    console.log('Logging meal:', data.foodName);
    const supabase = getSupabaseAdmin();
    
    const { data: result, error } = await supabase
      .from('meals')
      .insert({
        user_id: data.userId,
        meal_date: data.mealDate,
        meal_time: data.mealTime,
        food_name: data.foodName,
        photo_url: data.photoUrl,
        protein_g: data.proteinG,
        carbs_g: data.carbsG,
        fat_g: data.fatG,
        calories: data.calories,
        source: data.source,
        confidence: data.confidence
      })
      .select()
      .single();

    if (error || !result) throw new Error(`Failed to log meal: ${error?.message}`);
    return this.mapToEntity(result);
  }

  static async deleteMeal(mealId: string, userId: string): Promise<void> {
    const supabase = getSupabaseAdmin();
    const { error, count } = await supabase
      .from('meals')
      .delete({ count: 'exact' })
      .eq('id', mealId)
      .eq('user_id', userId);

    if (error) throw new Error(`Failed to delete meal: ${error.message}`);
    if (count === 0) throw new NotFoundError('Nie znaleziono posiłku.');
  }

  static async getWeeklyTotals(userId: string, startDate: string, endDate: string): Promise<{ date: string, macros: DailyMacros }[]> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('meals')
      .select('meal_date, protein_g, carbs_g, fat_g, calories')
      .eq('user_id', userId)
      .gte('meal_date', startDate)
      .lte('meal_date', endDate);

    if (error) throw new Error(`Failed to fetch weekly macros: ${error.message}`);

    const grouped: Record<string, DailyMacros> = {};
    (data || []).forEach(meal => {
      const date = meal.meal_date;
      if (!grouped[date]) {
        grouped[date] = { totalProtein: 0, totalCarbs: 0, totalFat: 0, totalCalories: 0, mealsCount: 0 };
      }
      grouped[date].totalProtein += Number(meal.protein_g);
      grouped[date].totalCarbs += Number(meal.carbs_g);
      grouped[date].totalFat += Number(meal.fat_g);
      grouped[date].totalCalories += Number(meal.calories);
      grouped[date].mealsCount += 1;
    });

    return Object.entries(grouped)
      .map(([date, macros]) => ({ date, macros }))
      .sort((a, b) => a.date.localeCompare(b.date));
  }

  private static mapToEntity(row: any): LoggedMeal {
    return {
      id: row.id,
      userId: row.user_id,
      mealDate: row.meal_date,
      mealTime: row.meal_time,
      foodName: row.food_name,
      photoUrl: row.photo_url,
      proteinG: Number(row.protein_g),
      carbsG: Number(row.carbs_g),
      fatG: Number(row.fat_g),
      calories: Number(row.calories),
      source: row.source,
      confidence: row.confidence,
      createdAt: row.created_at
    };
  }
}
