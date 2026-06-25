import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') ?? '');
    const { action, token, platform } = await req.json();
    const supabase = getSupabaseAdmin();

    if (action === 'register') {
      if (!token || !platform) throw new ValidationError('token i platform są wymagane');
      await supabase.from('push_tokens').upsert(
        { user_id: userId, token, platform, updated_at: new Date().toISOString() },
        { onConflict: 'user_id,token' }
      );
      return new Response(JSON.stringify({ success: true }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    if (action === 'unregister') {
      if (!token) throw new ValidationError('token jest wymagany');
      await supabase.from('push_tokens').delete()
        .eq('user_id', userId).eq('token', token);
      return new Response(JSON.stringify({ success: true }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    throw new ValidationError('Nieznana akcja');
  } catch (e) { return handleError(e); }
});
