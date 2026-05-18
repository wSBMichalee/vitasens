import { ExternalAPIError, NotFoundError } from '../_shared/errorHandler.ts';

export type Platform = 'ios' | 'android';

export type SubscriptionProductId =
  | 'com.vitasense.monthly'
  | 'com.vitasense.yearly'
  | 'com.vitasense.family.monthly'
  | 'com.vitasense.family.yearly';

export interface RevenueCatEntitlement {
  productIdentifier: string;
  expiresDate: string | null;
  purchaseDate: string;
  isActive: boolean;
  willRenew: boolean;
  periodType: 'normal' | 'trial' | 'intro';
  store: 'app_store' | 'play_store' | 'promotional';
}

export interface RevenueCatSubscriberInfo {
  userId: string;
  isActive: boolean;
  planType: string | null;
  expiresAt: string | null;
  willRenew: boolean;
  isInTrial: boolean;
  trialExpiresAt: string | null;
  isFamilyAddon: boolean;
  familyAddonExpiresAt: string | null;
  store: 'app_store' | 'play_store' | 'promotional' | null;
}

interface RawEntitlement {
  expires_date: string | null;
  purchase_date: string;
  product_identifier: string;
  will_renew: boolean;
  period_type: string;
  store: string;
}

interface RawSubscriber {
  entitlements: Record<string, RawEntitlement>;
  subscriptions: Record<string, { expires_date: string | null; period_type: string }>;
}

interface RevenueCatAPIResponse {
  subscriber: RawSubscriber;
}

export class RevenueCatClient {
  private readonly apiKey: string;
  private readonly baseUrl = 'https://api.revenuecat.com/v1';

  constructor() {
    const key = Deno.env.get('REVENUECAT_API_KEY');
    if (!key) throw new ExternalAPIError('Brak REVENUECAT_API_KEY.');
    this.apiKey = key;
  }

  async getSubscriberInfo(userId: string): Promise<RevenueCatSubscriberInfo> {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10_000);

    try {
      const response = await fetch(`${this.baseUrl}/subscribers/${encodeURIComponent(userId)}`, {
        method: 'GET',
        signal: controller.signal,
        headers: {
          'Authorization': `Bearer ${this.apiKey}`,
          'Content-Type': 'application/json',
          'X-Platform': 'stripe', // RevenueCat server-side calls use this header
        },
      });

      if (response.status === 404) throw new NotFoundError('Nie znaleziono subskrybenta.');
      if (!response.ok) {
        throw new ExternalAPIError(`RevenueCat API błąd: ${response.status} ${response.statusText}`);
      }

      const data: RevenueCatAPIResponse = await response.json();
      return this.mapSubscriber(userId, data.subscriber);
    } catch (err) {
      if (err instanceof ExternalAPIError || err instanceof NotFoundError) throw err;
      throw new ExternalAPIError('Przekroczono limit czasu lub błąd połączenia z RevenueCat.');
    } finally {
      clearTimeout(timeoutId);
    }
  }

  private mapSubscriber(userId: string, sub: RawSubscriber): RevenueCatSubscriberInfo {
    const premiumEntitlement = sub.entitlements['premium'];
    const familyEntitlement = sub.entitlements['family_addon'];

    const now = new Date();

    const isEntitlementActive = (e: RawEntitlement | undefined): boolean => {
      if (!e) return false;
      if (e.expires_date === null) return true;
      return new Date(e.expires_date) > now;
    };

    const isPremiumActive = isEntitlementActive(premiumEntitlement);
    const isFamilyActive = isEntitlementActive(familyEntitlement);

    let planType: string | null = null;
    let expiresAt: string | null = null;
    let willRenew = false;
    let isInTrial = false;
    let trialExpiresAt: string | null = null;
    let store: RevenueCatSubscriberInfo['store'] = null;

    if (isPremiumActive && premiumEntitlement) {
      const productId = premiumEntitlement.product_identifier as SubscriptionProductId;
      planType = this.mapProductToPlan(productId);
      expiresAt = premiumEntitlement.expires_date;
      willRenew = premiumEntitlement.will_renew;
      isInTrial = premiumEntitlement.period_type === 'trial';
      store = premiumEntitlement.store as RevenueCatSubscriberInfo['store'];

      if (isInTrial) {
        trialExpiresAt = premiumEntitlement.expires_date;
      }
    }

    return {
      userId,
      isActive: isPremiumActive,
      planType,
      expiresAt,
      willRenew,
      isInTrial,
      trialExpiresAt,
      isFamilyAddon: isFamilyActive,
      familyAddonExpiresAt: familyEntitlement?.expires_date ?? null,
      store,
    };
  }

  private mapProductToPlan(productId: SubscriptionProductId): string {
    const map: Record<SubscriptionProductId, string> = {
      'com.vitasense.monthly': 'premium_monthly',
      'com.vitasense.yearly': 'premium_yearly',
      'com.vitasense.family.monthly': 'family_monthly',
      'com.vitasense.family.yearly': 'family_yearly',
    };
    return map[productId] ?? 'premium_monthly';
  }
}
