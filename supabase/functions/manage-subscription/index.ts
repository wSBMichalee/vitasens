import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { SubscriptionRepository } from './SubscriptionRepository.ts';
import { RevenueCatClient } from './RevenueCatClient.ts';
import { RevenueCatWebhookHandler } from './RevenueCatWebhookHandler.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const { action } = await req.json() as { action: string };
    let res: unknown;

    switch (action) {
      case 'status': {
        const userId = await getUserId(req.headers.get('Authorization') ?? '');
        res = await SubscriptionRepository.getStatus(userId);
        break;
      }

      case 'verify_purchase': {
        const userId = await getUserId(req.headers.get('Authorization') ?? '');
        const client = new RevenueCatClient();
        res = await client.getSubscriberInfo(userId);
        break;
      }

      case 'sync': {
        const userId = await getUserId(req.headers.get('Authorization') ?? '');
        const client = new RevenueCatClient();
        const info = await client.getSubscriberInfo(userId);
        if (info.isActive) {
          await SubscriptionRepository.activate({
            userId,
            plan: (info.planType ?? 'monthly').includes('yearly') ? 'yearly' : 'monthly',
            stripeCustomerId: info.store ?? '',
            stripeSubscriptionId: info.planType ?? '',
            subscriptionExpiresAt: info.expiresAt ?? new Date(Date.now() + 30 * 86_400_000).toISOString(),
          });
        }
        if (info.isFamilyAddon) {
          await SubscriptionRepository.activateFamilyAddon({
            userId,
            stripeFamilySubscriptionId: 'family_addon',
            familyAddonExpiresAt: info.familyAddonExpiresAt ?? new Date(Date.now() + 30 * 86_400_000).toISOString(),
          });
        }
        res = { synced: true };
        break;
      }

      case 'webhook': {
        const rawBody = await req.text();
        const authHeader = req.headers.get('Authorization') ?? '';
        const handler = new RevenueCatWebhookHandler();
        res = await handler.handle(rawBody, authHeader);
        break;
      }

      case 'cancel': {
        const userId = await getUserId(req.headers.get('Authorization') ?? '');
        await SubscriptionGuard.checkAccess(userId);
        const status = await SubscriptionRepository.getStatus(userId);
        await SubscriptionRepository.cancel({
          userId,
          cancelAtPeriodEnd: true,
          subscriptionExpiresAt: status.subscriptionExpiresAt ?? undefined,
        });
        res = { canceled: true, message: 'Subskrypcja zostanie anulowana po zakończeniu okresu' };
        break;
      }

      case 'cancel_family': {
        const userId = await getUserId(req.headers.get('Authorization') ?? '');
        await SubscriptionGuard.checkFamilyAccess(userId);
        await SubscriptionRepository.cancelFamilyAddon(userId);
        res = { canceled: true };
        break;
      }

      default:
        throw new ValidationError('Nieznana akcja');
    }

    return new Response(
      JSON.stringify({ success: true, data: res }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) { return handleError(e); }
});
