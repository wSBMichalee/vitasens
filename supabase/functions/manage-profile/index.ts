import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { ProfileRepository } from './ProfileRepository.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    const { action, ...data } = await req.json();
    let res;
    switch (action) {
      case 'get_profile':
        res = await ProfileRepository.getProfile(userId);
        break;
      case 'update_profile':
        res = await ProfileRepository.updateProfile(userId, data);
        break;
      case 'calculate_targets':
        res = await ProfileRepository.calculateAndSaveTargets(userId);
        break;
      case 'complete_onboarding':
        await ProfileRepository.completeOnboarding(userId);
        res = { completed: true };
        break;
      default:
        throw new ValidationError('Nieznana akcja');
    }
    return new Response(
      JSON.stringify({ success: true, data: res }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) { return handleError(e); }
});
