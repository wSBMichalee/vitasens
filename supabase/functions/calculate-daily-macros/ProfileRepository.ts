import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { NotFoundError } from '../_shared/errorHandler.ts';

export interface UserProfile {
  id: string;
  name: string;
  avatarUrl?: string;
  goalType: string;
  dailyProteinTarget: number;
  dailyCarbsTarget: number;
  dailyFatTarget: number;
  healthConditions: string[];
  subscriptionPlan: string | null;
  subscriptionStatus: string;
  trialExpiresAt: string;
  subscriptionExpiresAt?: string;
  familyAddon: boolean;
  familyAddonExpiresAt?: string;
  createdAt: string;
  updatedAt: string;
}

export interface MacroTargets {
  dailyProteinTarget: number;
  dailyCarbsTarget: number;
  dailyFatTarget: number;
  dailyCaloriesTarget: number;
}

export interface UpdateProfileDTO {
  name?: string;
  goalType?: string;
  dailyProteinTarget?: number;
  dailyCarbsTarget?: number;
  dailyFatTarget?: number;
  healthConditions?: string[];
  avatarUrl?: string;
}

export class ProfileRepository {
  static async getById(userId: string): Promise<UserProfile> {
    console.log('Getting profile for:', userId);
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase
      .from('profiles')
      .select('*')
      .eq('id', userId)
      .single();

    if (error || !data) throw new NotFoundError('Nie znaleziono profilu użytkownika.');
    return this.mapToEntity(data);
  }

  static async getTargets(userId: string): Promise<MacroTargets> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('profiles')
      .select('daily_protein_target, daily_carbs_target, daily_fat_target')
      .eq('id', userId)
      .single();

    if (error || !data) throw new NotFoundError('Nie znaleziono profilu użytkownika.');

    const protein = Number(data.daily_protein_target) || 0;
    const carbs = Number(data.daily_carbs_target) || 0;
    const fat = Number(data.daily_fat_target) || 0;
    const calories = (protein * 4) + (carbs * 4) + (fat * 9);

    return {
      dailyProteinTarget: protein,
      dailyCarbsTarget: carbs,
      dailyFatTarget: fat,
      dailyCaloriesTarget: calories
    };
  }

  static async update(userId: string, data: UpdateProfileDTO): Promise<UserProfile> {
    const supabase = getSupabaseAdmin();
    const updatePayload: Record<string, any> = {
      updated_at: new Date().toISOString()
    };

    if (data.name !== undefined) updatePayload.name = data.name;
    if (data.goalType !== undefined) updatePayload.goal_type = data.goalType;
    if (data.dailyProteinTarget !== undefined) updatePayload.daily_protein_target = data.dailyProteinTarget;
    if (data.dailyCarbsTarget !== undefined) updatePayload.daily_carbs_target = data.dailyCarbsTarget;
    if (data.dailyFatTarget !== undefined) updatePayload.daily_fat_target = data.dailyFatTarget;
    if (data.healthConditions !== undefined) updatePayload.health_conditions = data.healthConditions;
    if (data.avatarUrl !== undefined) updatePayload.avatar_url = data.avatarUrl;

    const { data: result, error } = await supabase
      .from('profiles')
      .update(updatePayload)
      .eq('id', userId)
      .select()
      .single();

    if (error || !result) throw new NotFoundError('Nie znaleziono profilu do aktualizacji.');
    return this.mapToEntity(result);
  }

  static async updateSubscription(userId: string, data: {
    subscriptionPlan?: string,
    subscriptionStatus?: string,
    subscriptionExpiresAt?: string,
    stripeCustomerId?: string,
    stripeSubscriptionId?: string
  }): Promise<void> {
    console.log('Updating subscription for:', userId);
    const supabase = getSupabaseAdmin();
    const updatePayload: Record<string, any> = {};

    if (data.subscriptionPlan !== undefined) updatePayload.subscription_plan = data.subscriptionPlan;
    if (data.subscriptionStatus !== undefined) updatePayload.subscription_status = data.subscriptionStatus;
    if (data.subscriptionExpiresAt !== undefined) updatePayload.subscription_expires_at = data.subscriptionExpiresAt;
    if (data.stripeCustomerId !== undefined) updatePayload.stripe_customer_id = data.stripeCustomerId;
    if (data.stripeSubscriptionId !== undefined) updatePayload.stripe_subscription_id = data.stripeSubscriptionId;

    const { error } = await supabase.from('profiles').update(updatePayload).eq('id', userId);
    if (error) throw new Error(`Failed to update subscription: ${error.message}`);
  }

  static async updateFamilyAddon(userId: string, data: {
    familyAddon: boolean,
    familyAddonExpiresAt?: string,
    stripeFamilySubscriptionId?: string
  }): Promise<void> {
    console.log('Updating family addon for:', userId);
    const supabase = getSupabaseAdmin();
    const updatePayload: Record<string, any> = { family_addon: data.familyAddon };

    if (data.familyAddonExpiresAt !== undefined) updatePayload.family_addon_expires_at = data.familyAddonExpiresAt;
    if (data.stripeFamilySubscriptionId !== undefined) updatePayload.stripe_family_subscription_id = data.stripeFamilySubscriptionId;

    const { error } = await supabase.from('profiles').update(updatePayload).eq('id', userId);
    if (error) throw new Error(`Failed to update family addon: ${error.message}`);
  }

  private static mapToEntity(row: any): UserProfile {
    return {
      id: row.id,
      name: row.name,
      avatarUrl: row.avatar_url,
      goalType: row.goal_type,
      dailyProteinTarget: Number(row.daily_protein_target),
      dailyCarbsTarget: Number(row.daily_carbs_target),
      dailyFatTarget: Number(row.daily_fat_target),
      healthConditions: row.health_conditions || [],
      subscriptionPlan: row.subscription_plan,
      subscriptionStatus: row.subscription_status,
      trialExpiresAt: row.trial_expires_at,
      subscriptionExpiresAt: row.subscription_expires_at,
      familyAddon: row.family_addon,
      familyAddonExpiresAt: row.family_addon_expires_at,
      createdAt: row.created_at,
      updatedAt: row.updated_at
    };
  }
}
