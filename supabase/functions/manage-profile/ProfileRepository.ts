import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { NotFoundError } from '../_shared/errorHandler.ts';

export interface UpdateProfileData {
  gender?: string;
  age?: number;
  weightKg?: number;
  heightCm?: number;
  activityLevel?: string;
  goalType?: string;
  goalPace?: string;
  allergies?: string[];
  favoriteCuisines?: string[];
  favoriteProducts?: string[];
  healthConditions?: string[];
}

export interface MacroTargets {
  calories: number;
  protein: number;
  carbs: number;
  fat: number;
}

const ACTIVITY_MULTIPLIERS: Record<string, number> = {
  sedentary: 1.2,
  light: 1.375,
  moderate: 1.55,
  active: 1.725,
  very_active: 1.9,
};

export class ProfileRepository {
  static async getProfile(userId: string): Promise<Record<string, unknown>> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (error || !data) throw new NotFoundError('Nie znaleziono profilu użytkownika.');
    return data;
  }

  static async updateProfile(
    userId: string,
    data: UpdateProfileData,
  ): Promise<Record<string, unknown>> {
    const supabase = getSupabaseAdmin();
    const payload: Record<string, unknown> = { updated_at: new Date().toISOString() };

    if (data.gender !== undefined)          payload.gender           = data.gender;
    if (data.age !== undefined)             payload.age              = data.age;
    if (data.weightKg !== undefined)        payload.weight_kg        = data.weightKg;
    if (data.heightCm !== undefined)        payload.height_cm        = data.heightCm;
    if (data.activityLevel !== undefined)   payload.activity_level   = data.activityLevel;
    if (data.goalType !== undefined)        payload.goal_type        = data.goalType;
    if (data.goalPace !== undefined)        payload.goal_pace        = data.goalPace;
    if (data.allergies !== undefined)       payload.allergies        = data.allergies;
    if (data.favoriteCuisines !== undefined) payload.favorite_cuisines = data.favoriteCuisines;
    if (data.favoriteProducts !== undefined) payload.favorite_products = data.favoriteProducts;
    if (data.healthConditions !== undefined) payload.health_conditions = data.healthConditions;

    const { data: result, error } = await supabase
      .from('profiles')
      .update(payload)
      .eq('id', userId)
      .select()
      .single();

    if (error || !result) throw new NotFoundError('Nie znaleziono profilu do aktualizacji.');
    return result;
  }

  static async calculateAndSaveTargets(userId: string): Promise<MacroTargets> {
    const profile = await this.getProfile(userId);

    const weight = Number(profile.weight_kg) || 70;
    const height = Number(profile.height_cm) || 170;
    const age    = Number(profile.age) || 30;
    const gender = (profile.gender as string) || 'other';
    const activity = (profile.activity_level as string) || 'moderate';
    const goalType = (profile.goal_type as string) || 'general_health';
    const goalPace = (profile.goal_pace as string) || 'moderate';

    // BMR — Mifflin-St Jeor
    const bmrMale   = 10 * weight + 6.25 * height - 5 * age + 5;
    const bmrFemale = 10 * weight + 6.25 * height - 5 * age - 161;
    const bmr = gender === 'male'
      ? bmrMale
      : gender === 'female'
      ? bmrFemale
      : (bmrMale + bmrFemale) / 2;

    // TDEE
    const multiplier = ACTIVITY_MULTIPLIERS[activity] ?? 1.55;
    const tdee = bmr * multiplier;

    // Kalorie docelowe
    const deficit: Record<string, number> = { slow: 250, moderate: 500, fast: 750 };
    let targetCalories = tdee;
    if (goalType === 'weight_loss')  targetCalories = tdee - (deficit[goalPace] ?? 500);
    if (goalType === 'muscle_gain')  targetCalories = tdee + (deficit[goalPace] ?? 500);

    // Makra
    const protein = weight * (goalType === 'weight_loss' ? 2.0 : 1.6);
    const fat     = (targetCalories * 0.25) / 9;
    const carbs   = (targetCalories - protein * 4 - fat * 9) / 4;

    const targets: MacroTargets = {
      calories: Math.round(targetCalories),
      protein:  Math.round(protein),
      carbs:    Math.round(carbs),
      fat:      Math.round(fat),
    };

    const supabase = getSupabaseAdmin();
    const { error } = await supabase
      .from('profiles')
      .update({
        daily_calorie_target:  targets.calories,
        daily_protein_target:  targets.protein,
        daily_carbs_target:    targets.carbs,
        daily_fat_target:      targets.fat,
        updated_at:            new Date().toISOString(),
      })
      .eq('id', userId);

    if (error) throw new Error(`Błąd zapisu targetów: ${error.message}`);
    return targets;
  }

  static async completeOnboarding(userId: string): Promise<void> {
    const supabase = getSupabaseAdmin();
    const { error } = await supabase
      .from('profiles')
      .update({ onboarding_completed: true, updated_at: new Date().toISOString() })
      .eq('id', userId);

    if (error) throw new Error(`Błąd aktualizacji onboardingu: ${error.message}`);
  }
}
