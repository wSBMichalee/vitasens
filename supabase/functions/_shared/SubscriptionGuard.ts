import { getSupabaseAdmin } from './supabaseClient.ts';
import { SubscriptionError, NotFoundError } from './errorHandler.ts';

export class SubscriptionGuard {
  static async checkAccess(userId: string): Promise<void> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('profiles')
      .select('subscription_status, trial_expires_at, subscription_expires_at')
      .eq('id', userId)
      .single();

    if (error || !data) {
      throw new NotFoundError('Nie znaleziono profilu użytkownika.');
    }

    const now = new Date();
    const trialExpiresAt = data.trial_expires_at ? new Date(data.trial_expires_at) : new Date(0);
    const subExpiresAt = data.subscription_expires_at ? new Date(data.subscription_expires_at) : null;

    const isTrialActive = data.subscription_status === 'trialing' && trialExpiresAt > now;
    const isSubActive = data.subscription_status === 'active' && subExpiresAt && subExpiresAt > now;

    if (!isTrialActive && !isSubActive) {
      throw new SubscriptionError(
        'Twój okres próbny wygasł. Wybierz plan aby kontynuować.',
        'SUBSCRIPTION_EXPIRED'
      );
    }
  }

  static async checkFamilyAccess(userId: string): Promise<void> {
    await this.checkAccess(userId);

    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('profiles')
      .select('family_addon, family_addon_expires_at')
      .eq('id', userId)
      .single();

    if (error || !data) {
      throw new NotFoundError('Nie znaleziono profilu użytkownika.');
    }

    const now = new Date();
    const addonExpiresAt = data.family_addon_expires_at ? new Date(data.family_addon_expires_at) : null;

    const isFamilyActive = data.family_addon === true && addonExpiresAt && addonExpiresAt > now;

    if (!isFamilyActive) {
      throw new SubscriptionError(
        'Funkcje rodzinne dostępne tylko w planie Family.',
        'FAMILY_ADDON_REQUIRED'
      );
    }
  }

  static async getRemainingTrialDays(userId: string): Promise<number> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('profiles')
      .select('trial_expires_at')
      .eq('id', userId)
      .single();

    if (error || !data) {
      throw new NotFoundError('Nie znaleziono profilu użytkownika.');
    }

    if (!data.trial_expires_at) {
      return 0;
    }

    const now = new Date();
    const trialExpiresAt = new Date(data.trial_expires_at);

    if (trialExpiresAt <= now) {
      return 0;
    }

    const diffTime = trialExpiresAt.getTime() - now.getTime();
    return Math.ceil(diffTime / (1000 * 60 * 60 * 24));
  }

  static async getSubscriptionStatus(userId: string) {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('profiles')
      .select(`
        subscription_plan,
        subscription_status,
        subscription_expires_at,
        family_addon,
        family_addon_expires_at
      `)
      .eq('id', userId)
      .single();

    if (error || !data) {
      throw new NotFoundError('Nie znaleziono profilu użytkownika.');
    }

    const trialDaysRemaining = await this.getRemainingTrialDays(userId);

    return {
      plan: data.subscription_plan,
      status: data.subscription_status,
      trialDaysRemaining,
      subscriptionExpiresAt: data.subscription_expires_at,
      hasFamilyAddon: data.family_addon,
      familyAddonExpiresAt: data.family_addon_expires_at
    };
  }
}
