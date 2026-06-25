import { getSupabaseAdmin, getSupabaseAuth } from '../_shared/supabaseClient.ts';
import { ValidationError, NotFoundError } from '../_shared/errorHandler.ts';

export interface AuthResult {
  userId: string;
  email: string;
  fullName?: string;
  accessToken?: string;
  refreshToken?: string;
}

export interface UserProfile {
  id: string;
  email: string;
  fullName: string;
  onboardingCompleted: boolean;
  subscriptionStatus: string;
  goalType?: string;
  dailyCalorieTarget?: number;
  dailyProteinTarget?: number;
  dailyCarbsTarget?: number;
  dailyFatTarget?: number;
  goalPace?: string;
  activityLevel?: string;
  weightKg?: number;
  heightCm?: number;
  gender?: string;
  age?: number;
  allergies?: string[];
  healthConditions?: string[];
  dietaryPreferences?: string[];
  dailyWaterTarget?: number;
}

export class AuthRepository {
  static async signUp(
    email: string,
    password: string,
    fullName: string,
  ): Promise<AuthResult> {
    const supabaseAdmin = getSupabaseAdmin();
    const { data, error } = await supabaseAdmin.auth.signUp({
      email,
      password,
      options: {
        data: { full_name: fullName }
      }
    });
    if (error || !data.user) throw new ValidationError(error?.message ?? 'Rejestracja nie powiodła się.');

    // Auto-confirm email to allow immediate sign-in
    try {
      await supabaseAdmin.auth.admin.updateUserById(
        data.user.id,
        { email_confirm: true }
      );
    } catch (e) {
      console.warn(`[manage-auth] signUp - auto-confirm failed:`, e);
    }

    // Ensure the profile is created in the database
    try {
      const trialExpiresAt = new Date(Date.now() + 3 * 24 * 60 * 60 * 1000).toISOString();
      await supabaseAdmin
        .from('profiles')
        .upsert({
          id: data.user.id,
          name: fullName,
          subscription_status: 'trialing',
          trial_expires_at: trialExpiresAt,
        }, { onConflict: 'id' });
    } catch (e) {
      console.warn(`[manage-auth] signUp - profile upsert failed:`, e);
    }

    return {
      userId: data.user.id,
      email: data.user.email ?? email,
      fullName,
    };
  }

  static async signIn(
    email: string,
    password: string,
  ): Promise<AuthResult> {
    const supabase = getSupabaseAuth();
    const { data, error } = await supabase.auth.signInWithPassword({ email, password });
    if (error || !data.session) {
      throw new ValidationError('Nieprawidłowy email lub hasło.');
    }
    return {
      userId: data.user.id,
      email: data.user.email ?? email,
      accessToken: data.session.access_token,
      refreshToken: data.session.refresh_token,
    };
  }

  static async signOut(userId: string): Promise<void> {
    const supabase = getSupabaseAdmin();
    const { error } = await supabase.auth.admin.signOut(userId);
    if (error) throw new Error(`Błąd wylogowania: ${error.message}`);
  }

  static async resetPassword(email: string): Promise<void> {
    const admin = getSupabaseAdmin();
    const { data } = await admin.auth.admin.listUsers({ perPage: 1000 });
    const exists = (data?.users ?? []).some((u) => u.email === email);
    if (!exists) throw new NotFoundError('Nie znaleziono użytkownika z podanym adresem email.');
    const { error } = await admin.auth.resetPasswordForEmail(email, {
      redirectTo: 'vitasense://reset-password',
    });
    if (error) throw new Error(`Błąd wysyłania emaila: ${error.message}`);
  }

  static async refreshToken(refreshToken: string): Promise<AuthResult> {
    const supabase = getSupabaseAuth();
    const { data, error } = await supabase.auth.refreshSession({
      refresh_token: refreshToken,
    });
    if (error || !data.session || !data.user) {
      throw new ValidationError('Nieprawidłowy lub wygasły token odświeżania.');
    }
    return {
      userId: data.user.id,
      email: data.user.email ?? '',
      accessToken: data.session.access_token,
      refreshToken: data.session.refresh_token,
    };
  }

  static async getUser(userId: string): Promise<UserProfile> {
    const admin = getSupabaseAdmin();
    const [authRes, profileRes] = await Promise.all([
      admin.auth.admin.getUserById(userId),
      admin.from('profiles').select('*').eq('id', userId).single(),
    ]);
    if (authRes.error || !authRes.data.user) {
      throw new NotFoundError('Nie znaleziono użytkownika.');
    }
    if (profileRes.error || !profileRes.data) {
      throw new NotFoundError('Nie znaleziono profilu użytkownika.');
    }
    const u = authRes.data.user;
    const p = profileRes.data;
    return {
      id: p.id,
      email: u.email ?? '',
      fullName: p.name,
      onboardingCompleted: p.onboarding_completed === true,
      subscriptionStatus: p.subscription_status,
      goalType: p.goal_type ?? undefined,
      dailyCalorieTarget: p.daily_calorie_target ? Number(p.daily_calorie_target) : undefined,
      dailyProteinTarget: p.daily_protein_target ? Number(p.daily_protein_target) : undefined,
      dailyCarbsTarget:   p.daily_carbs_target   ? Number(p.daily_carbs_target)   : undefined,
      dailyFatTarget:     p.daily_fat_target      ? Number(p.daily_fat_target)     : undefined,
      goalPace: p.goal_pace ?? undefined,
      activityLevel: p.activity_level ?? undefined,
      weightKg: p.weight_kg ? Number(p.weight_kg) : undefined,
      heightCm: p.height_cm ? Number(p.height_cm) : undefined,
      gender: p.gender ?? undefined,
      age: p.age ? Number(p.age) : undefined,
      allergies: p.allergies ?? [],
      healthConditions: p.health_conditions ?? [],
      dietaryPreferences: p.dietary_preferences ?? [],
      dailyWaterTarget: p.daily_water_target ? Number(p.daily_water_target) : undefined,
    };
  }
}
