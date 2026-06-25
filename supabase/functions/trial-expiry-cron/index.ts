import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';

const CRON_SECRET = Deno.env.get('CRON_SECRET') ?? '';

async function sendPushNotification(tokens: string[], title: string, body: string) {
  if (tokens.length === 0) return;
  const messages = tokens.map(token => ({
    to: token,
    sound: 'default',
    title,
    body,
    data: { type: 'trial_expiry' },
  }));
  await fetch('https://exp.host/--/api/v2/push/send', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', 'Accept': 'application/json' },
    body: JSON.stringify(messages),
  });
}

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  // Zabezpieczenie crona — tylko wywołania z CRON_SECRET
  const authHeader = req.headers.get('Authorization') ?? '';
  if (CRON_SECRET && authHeader !== `Bearer ${CRON_SECRET}`) {
    return new Response('Unauthorized', { status: 401 });
  }

  const supabase = getSupabaseAdmin();
  const now = new Date();
  const results = { expired: 0, notified1day: 0, notified2days: 0 };

  // 1. Wygaś triale które minęły
  const { data: expiredUsers } = await supabase
    .from('profiles')
    .update({ subscription_status: 'expired' })
    .eq('subscription_status', 'trialing')
    .lt('trial_expires_at', now.toISOString())
    .select('id');
  results.expired = expiredUsers?.length ?? 0;

  // 2. Znajdź userów z 1 dniem zostającym (expires between 20h-28h from now)
  const in1dayMin = new Date(now.getTime() + 20 * 60 * 60 * 1000).toISOString();
  const in1dayMax = new Date(now.getTime() + 28 * 60 * 60 * 1000).toISOString();
  const { data: users1day } = await supabase
    .from('profiles')
    .select('id')
    .eq('subscription_status', 'trialing')
    .gte('trial_expires_at', in1dayMin)
    .lte('trial_expires_at', in1dayMax);

  if (users1day && users1day.length > 0) {
    const ids1day = users1day.map(u => u.id);
    const { data: tokens1day } = await supabase
      .from('push_tokens')
      .select('token')
      .in('user_id', ids1day);
    const tokenList1day = tokens1day?.map(t => t.token) ?? [];
    await sendPushNotification(
      tokenList1day,
      '⏰ Zostały Ci 24 godziny!',
      'Jutro kończy się Twój darmowy trial VitaSense. Kup plan i nie trać dostępu.'
    );
    results.notified1day = tokenList1day.length;
  }

  // 3. Znajdź userów z 2 dniami zostającymi (expires between 44h-52h from now)
  const in2daysMin = new Date(now.getTime() + 44 * 60 * 60 * 1000).toISOString();
  const in2daysMax = new Date(now.getTime() + 52 * 60 * 60 * 1000).toISOString();
  const { data: users2days } = await supabase
    .from('profiles')
    .select('id')
    .eq('subscription_status', 'trialing')
    .gte('trial_expires_at', in2daysMin)
    .lte('trial_expires_at', in2daysMax);

  if (users2days && users2days.length > 0) {
    const ids2days = users2days.map(u => u.id);
    const { data: tokens2days } = await supabase
      .from('push_tokens')
      .select('token')
      .in('user_id', ids2days);
    const tokenList2days = tokens2days?.map(t => t.token) ?? [];
    await sendPushNotification(
      tokenList2days,
      '🎯 2 dni darmowego dostępu',
      'Za 2 dni kończy się Twój trial. Nie zapomnij wybrać planu!'
    );
    results.notified2days = tokenList2days.length;
  }

  console.log('[trial-expiry-cron] results:', results);
  return new Response(JSON.stringify({ success: true, ...results }), {
    headers: { ...corsHeaders, 'Content-Type': 'application/json' }
  });
});
