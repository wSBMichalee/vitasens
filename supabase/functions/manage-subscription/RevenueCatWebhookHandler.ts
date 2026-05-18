import { SubscriptionRepository } from './SubscriptionRepository.ts';
import { ExternalAPIError, ValidationError } from '../_shared/errorHandler.ts';

// RevenueCat sends the webhook secret in the Authorization header
// as "Bearer {REVENUECAT_WEBHOOK_SECRET}"
export type RevenueCatEventType =
  | 'INITIAL_PURCHASE'
  | 'RENEWAL'
  | 'CANCELLATION'
  | 'EXPIRATION'
  | 'TRIAL_STARTED'
  | 'TRIAL_CONVERTED'
  | 'TRIAL_CANCELLED'
  | 'PRODUCT_CHANGE'
  | 'BILLING_ISSUE'
  | 'SUBSCRIBER_ALIAS';

export interface RevenueCatEvent {
  type: RevenueCatEventType;
  app_user_id: string;
  original_app_user_id: string;
  product_id: string;
  store: 'APP_STORE' | 'PLAY_STORE' | 'PROMOTIONAL';
  transaction_id: string;
  expiration_at_ms: number | null;
  purchased_at_ms: number;
  period_type: 'NORMAL' | 'TRIAL' | 'INTRO';
  is_family_share: boolean;
}

export interface RevenueCatWebhookPayload {
  api_version: string;
  event: RevenueCatEvent;
}

export interface WebhookResult {
  handled: boolean;
  eventType: RevenueCatEventType | string;
  userId?: string;
}

export class RevenueCatWebhookHandler {
  private readonly webhookSecret: string;

  constructor() {
    const secret = Deno.env.get('REVENUECAT_WEBHOOK_SECRET');
    if (!secret) throw new ExternalAPIError('Brak REVENUECAT_WEBHOOK_SECRET.');
    this.webhookSecret = secret;
  }

  async handle(rawBody: string, authorizationHeader: string): Promise<WebhookResult> {
    this.verifySecret(authorizationHeader);

    let payload: RevenueCatWebhookPayload;
    try {
      payload = JSON.parse(rawBody) as RevenueCatWebhookPayload;
    } catch {
      throw new ValidationError('Nieprawidłowy format webhooka RevenueCat.');
    }

    const event = payload.event;
    console.log('RevenueCat webhook event:', event.type, 'userId:', event.app_user_id);

    switch (event.type) {
      case 'INITIAL_PURCHASE':
      case 'TRIAL_CONVERTED':
        return await this.handleActivation(event);
      case 'RENEWAL':
        return await this.handleRenewal(event);
      case 'TRIAL_STARTED':
        return await this.handleTrialStarted(event);
      case 'CANCELLATION':
      case 'TRIAL_CANCELLED':
        return await this.handleCancellation(event);
      case 'EXPIRATION':
        return await this.handleExpiration(event);
      default:
        console.log('Unhandled RevenueCat event type:', event.type);
        return { handled: false, eventType: event.type };
    }
  }

  private verifySecret(authorizationHeader: string): void {
    const expected = `Bearer ${this.webhookSecret}`;
    if (authorizationHeader !== expected) {
      throw new ExternalAPIError('Nieprawidłowy klucz webhooka RevenueCat.');
    }
  }

  private isFamilyProduct(productId: string): boolean {
    return productId.includes('family');
  }

  private mapProductToPlan(productId: string): 'monthly' | 'yearly' {
    return productId.includes('yearly') ? 'yearly' : 'monthly';
  }

  private msToIso(ms: number | null): string | undefined {
    if (ms === null) return undefined;
    return new Date(ms).toISOString();
  }

  private async handleActivation(event: RevenueCatEvent): Promise<WebhookResult> {
    const userId = event.app_user_id;
    const expiresAt = this.msToIso(event.expiration_at_ms);

    if (this.isFamilyProduct(event.product_id)) {
      await SubscriptionRepository.activateFamilyAddon({
        userId,
        stripeFamilySubscriptionId: event.transaction_id,
        familyAddonExpiresAt: expiresAt ?? new Date(Date.now() + 30 * 86_400_000).toISOString(),
      });
    } else {
      await SubscriptionRepository.activate({
        userId,
        plan: this.mapProductToPlan(event.product_id),
        stripeCustomerId: event.original_app_user_id,
        stripeSubscriptionId: event.transaction_id,
        subscriptionExpiresAt: expiresAt ?? new Date(Date.now() + 30 * 86_400_000).toISOString(),
      });
    }

    console.log('Subscription activated for userId:', userId, 'product:', event.product_id);
    return { handled: true, eventType: event.type, userId };
  }

  private async handleRenewal(event: RevenueCatEvent): Promise<WebhookResult> {
    const userId = event.app_user_id;
    const expiresAt = this.msToIso(event.expiration_at_ms);

    if (this.isFamilyProduct(event.product_id)) {
      await SubscriptionRepository.activateFamilyAddon({
        userId,
        stripeFamilySubscriptionId: event.transaction_id,
        familyAddonExpiresAt: expiresAt ?? new Date(Date.now() + 30 * 86_400_000).toISOString(),
      });
    } else {
      await SubscriptionRepository.activate({
        userId,
        plan: this.mapProductToPlan(event.product_id),
        stripeCustomerId: event.original_app_user_id,
        stripeSubscriptionId: event.transaction_id,
        subscriptionExpiresAt: expiresAt ?? new Date(Date.now() + 30 * 86_400_000).toISOString(),
      });
    }

    console.log('Subscription renewed for userId:', userId);
    return { handled: true, eventType: event.type, userId };
  }

  private async handleTrialStarted(event: RevenueCatEvent): Promise<WebhookResult> {
    const userId = event.app_user_id;
    const trialExpiresAt = this.msToIso(event.expiration_at_ms)
      ?? new Date(Date.now() + 3 * 86_400_000).toISOString();

    await SubscriptionRepository.activate({
      userId,
      plan: this.mapProductToPlan(event.product_id),
      stripeCustomerId: event.original_app_user_id,
      stripeSubscriptionId: event.transaction_id,
      subscriptionExpiresAt: trialExpiresAt,
    });

    console.log('Trial started for userId:', userId, 'expires:', trialExpiresAt);
    return { handled: true, eventType: event.type, userId };
  }

  private async handleCancellation(event: RevenueCatEvent): Promise<WebhookResult> {
    const userId = event.app_user_id;
    const expiresAt = this.msToIso(event.expiration_at_ms);

    if (this.isFamilyProduct(event.product_id)) {
      await SubscriptionRepository.cancelFamilyAddon(userId);
    } else {
      await SubscriptionRepository.cancel({
        userId,
        cancelAtPeriodEnd: expiresAt !== undefined,
        subscriptionExpiresAt: expiresAt,
      });
    }

    console.log('Subscription cancelled for userId:', userId);
    return { handled: true, eventType: event.type, userId };
  }

  private async handleExpiration(event: RevenueCatEvent): Promise<WebhookResult> {
    const userId = event.app_user_id;

    if (this.isFamilyProduct(event.product_id)) {
      await SubscriptionRepository.cancelFamilyAddon(userId);
    } else {
      await SubscriptionRepository.expireSubscription(userId);
    }

    console.log('Subscription expired for userId:', userId);
    return { handled: true, eventType: event.type, userId };
  }
}
