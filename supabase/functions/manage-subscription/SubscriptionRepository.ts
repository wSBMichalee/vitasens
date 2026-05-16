import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { NotFoundError } from '../_shared/errorHandler.ts';

export interface ActivateSubscriptionDTO {
  userId: string;
  plan: 'monthly' | 'yearly';
  stripeCustomerId: string;
  stripeSubscriptionId: string;
  subscriptionExpiresAt: string;
}

export interface ActivateFamilyAddonDTO {
  userId: string;
  stripeFamilySubscriptionId: string;
  familyAddonExpiresAt: string;
}

export interface CancelSubscriptionDTO {
  userId: string;
  cancelAtPeriodEnd: boolean;
  subscriptionExpiresAt?: string;
}

export interface SubscriptionStatus {
  userId: string;
  plan: string | null;
  status: string;
  trialDaysRemaining: number;
  subscriptionExpiresAt: string | null;
  hasFamilyAddon: boolean;
  familyAddonExpiresAt: string | null;
  stripeCustomerId: string | null;
}

export class SubscriptionRepository {
  static async getStatus(userId: string): Promise<SubscriptionStatus> {
    const supabase = getSupabaseAdmin();
    
    // Pobierz dni triala
    const { data: trialDays, error: tError } = await supabase
      .rpc('get_trial_days_remaining', { user_id: userId });

    if (tError) console.error('Error fetching trial days:', tError.message);

    // Pobierz status subskrypcji
    const { data: profile, error: pError } = await supabase
      .from('profiles')
      .select(`
        subscription_plan, 
        subscription_status,
        subscription_expires_at, 
        family_addon,
        family_addon_expires_at, 
        stripe_customer_id
      `)
      .eq('id', userId)
      .single();

    if (pError || !profile) throw new NotFoundError('Użytkownik nie istnieje.');

    return {
      userId,
      plan: profile.subscription_plan,
      status: profile.subscription_status,
      trialDaysRemaining: trialDays || 0,
      subscriptionExpiresAt: profile.subscription_expires_at,
      hasFamilyAddon: profile.family_addon,
      familyAddonExpiresAt: profile.family_addon_expires_at,
      stripeCustomerId: profile.stripe_customer_id
    };
  }

  static async activate(data: ActivateSubscriptionDTO): Promise<void> {
    console.log('Activating subscription for:', data.userId);
    const supabase = getSupabaseAdmin();
    const { error } = await supabase
      .from('profiles')
      .update({
        subscription_plan: data.plan,
        subscription_status: 'active',
        subscription_expires_at: data.subscriptionExpiresAt,
        stripe_customer_id: data.stripeCustomerId,
        stripe_subscription_id: data.stripeSubscriptionId,
        updated_at: new Date().toISOString()
      })
      .eq('id', data.userId);

    if (error) throw new Error(`Failed to activate subscription: ${error.message}`);
  }

  static async activateFamilyAddon(data: ActivateFamilyAddonDTO): Promise<void> {
    console.log('Activating family addon for:', data.userId);
    const supabase = getSupabaseAdmin();
    const { error } = await supabase
      .from('profiles')
      .update({
        family_addon: true,
        family_addon_expires_at: data.familyAddonExpiresAt,
        stripe_family_subscription_id: data.stripeFamilySubscriptionId,
        updated_at: new Date().toISOString()
      })
      .eq('id', data.userId);

    if (error) throw new Error(`Failed to activate family addon: ${error.message}`);
  }

  static async cancel(data: CancelSubscriptionDTO): Promise<void> {
    console.log('Canceling subscription for:', data.userId);
    const supabase = getSupabaseAdmin();
    const { error } = await supabase
      .from('profiles')
      .update({
        subscription_status: 'canceled',
        subscription_expires_at: data.subscriptionExpiresAt ?? null,
        updated_at: new Date().toISOString()
      })
      .eq('id', data.userId);

    if (error) throw new Error(`Failed to cancel subscription: ${error.message}`);
  }

  static async cancelFamilyAddon(userId: string): Promise<void> {
    console.log('Canceling family addon for:', userId);
    const supabase = getSupabaseAdmin();
    const { error } = await supabase
      .from('profiles')
      .update({
        family_addon: false,
        family_addon_expires_at: null,
        stripe_family_subscription_id: null,
        updated_at: new Date().toISOString()
      })
      .eq('id', userId);

    if (error) throw new Error(`Failed to cancel family addon: ${error.message}`);
  }

  static async expireSubscription(userId: string): Promise<void> {
    const supabase = getSupabaseAdmin();
    const { error } = await supabase
      .from('profiles')
      .update({
        subscription_status: 'expired',
        updated_at: new Date().toISOString()
      })
      .eq('id', userId);

    if (error) throw new Error(`Failed to expire subscription: ${error.message}`);
  }

  static async findByStripeCustomerId(stripeCustomerId: string): Promise<{ userId: string }> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('profiles')
      .select('id')
      .eq('stripe_customer_id', stripeCustomerId)
      .single();

    if (error || !data) throw new NotFoundError('Nie znaleziono użytkownika dla podanego customer_id.');
    return { userId: data.id };
  }

  static async findByStripeSubscriptionId(stripeSubscriptionId: string): Promise<{ userId: string }> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('profiles')
      .select('id')
      .or(`stripe_subscription_id.eq.${stripeSubscriptionId},stripe_family_subscription_id.eq.${stripeSubscriptionId}`)
      .single();

    if (error || !data) throw new NotFoundError('Nie znaleziono użytkownika dla podanej subskrypcji.');
    return { userId: data.id };
  }
}
