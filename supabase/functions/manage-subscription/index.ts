import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId, getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { StripeClient } from './StripeClient.ts';
import { SubscriptionRepository } from './SubscriptionRepository.ts';
import { WebhookHandler } from './WebhookHandler.ts';

const PRICE_MONTHLY = Deno.env.get('STRIPE_PRICE_MONTHLY');
const PRICE_YEARLY = Deno.env.get('STRIPE_PRICE_YEARLY');
const ADDON_PRICE_MONTHLY = Deno.env.get('STRIPE_ADDON_PRICE_MONTHLY');
const ADDON_PRICE_YEARLY = Deno.env.get('STRIPE_ADDON_PRICE_YEARLY');

if (!PRICE_MONTHLY || !PRICE_YEARLY) throw new Error('Brak konfiguracji Stripe Price IDs');
if (!ADDON_PRICE_MONTHLY || !ADDON_PRICE_YEARLY) throw new Error('Brak konfiguracji Stripe Addon Price IDs');

const P_M = PRICE_MONTHLY, P_Y = PRICE_YEARLY;
const A_M = ADDON_PRICE_MONTHLY, A_Y = ADDON_PRICE_YEARLY;

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    if (req.headers.get('stripe-signature')) return new Response(JSON.stringify({ success: true, data: await new WebhookHandler().handle(await req.text(), req.headers.get('stripe-signature')!) }), { headers: corsHeaders });
    const userId = await getUserId(req.headers.get('Authorization') || ''), { action, ...data } = await req.json(), stripe = new StripeClient();
    let res;
    switch (action) {
      case 'status': res = await SubscriptionRepository.getStatus(userId); break;
      case 'checkout': { const s = await SubscriptionRepository.getStatus(userId); let cid = s.stripeCustomerId; if (!cid) cid = (await stripe.createCustomer(userId, (await getSupabaseAdmin().auth.admin.getUserById(userId)).data.user!.email!)).id; res = await stripe.createCheckoutSession(cid, data.plan === 'yearly' ? P_Y : P_M, data.successUrl, data.cancelUrl); break; }
      case 'add_family': { await SubscriptionGuard.checkAccess(userId); const cid = (await SubscriptionRepository.getStatus(userId)).stripeCustomerId; res = await stripe.createFamilyAddonSession(cid!, data.plan === 'yearly' ? A_Y : A_M, data.successUrl, data.cancelUrl); break; }
      case 'cancel': { await SubscriptionGuard.checkAccess(userId); const sid = (await getSupabaseAdmin().from('profiles').select('stripe_subscription_id').eq('id', userId).single()).data!.stripe_subscription_id; await stripe.cancelSubscription(sid); await SubscriptionRepository.cancel({ userId, cancelAtPeriodEnd: true }); res = { canceled: true }; break; }
      case 'cancel_family': { await SubscriptionGuard.checkFamilyAccess(userId); const sid = (await getSupabaseAdmin().from('profiles').select('stripe_family_subscription_id').eq('id', userId).single()).data!.stripe_family_subscription_id; await stripe.cancelSubscription(sid); await SubscriptionRepository.cancelFamilyAddon(userId); res = { canceled: true }; break; }
      default: throw new ValidationError('Nieznana akcja');
    }
    return new Response(JSON.stringify({ success: true, data: res }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) { return handleError(e); }
});
