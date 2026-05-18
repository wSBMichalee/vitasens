import { StripeClient } from './StripeClient.ts';
import { SubscriptionRepository } from './SubscriptionRepository.ts';
import { ExternalAPIError } from '../_shared/errorHandler.ts';

export interface StripeEvent {
  id: string;
  type: string;
  data: {
    object: any;
  };
}

export interface WebhookResult {
  handled: boolean;
  eventType: string;
  userId?: string;
}

export class WebhookHandler {
  private stripeClient = new StripeClient();
  private webhookSecret: string;

  constructor() {
    const secret = Deno.env.get('STRIPE_WEBHOOK_SECRET');
    if (!secret) throw new ExternalAPIError(
      'Brak STRIPE_WEBHOOK_SECRET — webhooki Stripe są wyłączone',
    );
    this.webhookSecret = secret;
  }

  async handle(rawBody: string, signature: string): Promise<WebhookResult> {
    
    this.stripeClient.verifyWebhookSignature(rawBody, signature, this.webhookSecret);
    const event = JSON.parse(rawBody) as StripeEvent;
    console.log('Handling Stripe webhook:', event.type);

    switch (event.type) {
      case 'checkout.session.completed':
        return await this.handleCheckoutCompleted(event);
      case 'customer.subscription.updated':
        return await this.handleSubscriptionUpdated(event);
      case 'customer.subscription.deleted':
        return await this.handleSubscriptionDeleted(event);
      case 'invoice.payment_failed':
        return await this.handlePaymentFailed(event);
      default:
        return { handled: false, eventType: event.type };
    }
  }

  private async handleCheckoutCompleted(event: StripeEvent): Promise<WebhookResult> {
    const session = event.data.object;
    const { userId } = await SubscriptionRepository.findByStripeCustomerId(session.customer);
    
    const subscription = await this.stripeClient.getSubscription(session.subscription);
    const expiresAt = new Date(subscription.currentPeriodEnd * 1000).toISOString();

    if (session.metadata?.type === 'family_addon') {
      await SubscriptionRepository.activateFamilyAddon({
        userId,
        stripeFamilySubscriptionId: session.subscription,
        familyAddonExpiresAt: expiresAt
      });
    } else {
      await SubscriptionRepository.activate({
        userId,
        plan: session.metadata?.plan || 'monthly',
        stripeCustomerId: session.customer,
        stripeSubscriptionId: session.subscription,
        subscriptionExpiresAt: expiresAt
      });
    }

    console.log('Checkout completed for userId:', userId);
    return { handled: true, eventType: event.type, userId };
  }

  private async handleSubscriptionUpdated(event: StripeEvent): Promise<WebhookResult> {
    const sub = event.data.object;
    const { userId } = await SubscriptionRepository.findByStripeSubscriptionId(sub.id);
    const expiresAt = new Date(sub.current_period_end * 1000).toISOString();

    if (sub.status === 'active') {
      if (sub.metadata?.type === 'family_addon') {
        await SubscriptionRepository.activateFamilyAddon({
          userId,
          stripeFamilySubscriptionId: sub.id,
          familyAddonExpiresAt: expiresAt
        });
      } else {
        await SubscriptionRepository.activate({
          userId,
          plan: sub.metadata?.plan || 'monthly',
          stripeCustomerId: sub.customer,
          stripeSubscriptionId: sub.id,
          subscriptionExpiresAt: expiresAt
        });
      }
    } else if (sub.status === 'canceled' || sub.cancel_at_period_end) {
      await SubscriptionRepository.cancel({ userId, cancelAtPeriodEnd: true, subscriptionExpiresAt: expiresAt });
    }

    console.log('Subscription updated:', sub.id);
    return { handled: true, eventType: event.type, userId };
  }

  private async handleSubscriptionDeleted(event: StripeEvent): Promise<WebhookResult> {
    const sub = event.data.object;
    const { userId } = await SubscriptionRepository.findByStripeSubscriptionId(sub.id);

    if (sub.metadata?.type === 'family_addon') {
      await SubscriptionRepository.cancelFamilyAddon(userId);
    } else {
      await SubscriptionRepository.cancel({ userId, cancelAtPeriodEnd: false });
    }

    console.log('Subscription deleted:', sub.id);
    return { handled: true, eventType: event.type, userId };
  }

  private async handlePaymentFailed(event: StripeEvent): Promise<WebhookResult> {
    const invoice = event.data.object;
    const { userId } = await SubscriptionRepository.findByStripeCustomerId(invoice.customer);
    await SubscriptionRepository.expireSubscription(userId);
    
    console.log('Payment failed for userId:', userId);
    return { handled: true, eventType: event.type, userId };
  }
}
