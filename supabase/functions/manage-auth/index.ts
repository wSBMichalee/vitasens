import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { AuthRepository } from './AuthRepository.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const body = await req.json();
    const { action, email, password, fullName, refreshToken } = body;
    const authHeader = req.headers.get('Authorization') || '';
    let res;
    switch (action) {
      case 'sign_up':
        if (!email || !password || password.length < 8 || !fullName)
          throw new ValidationError('Wymagane: email, hasło (min 8 znaków), imię.');
        res = await AuthRepository.signUp(email, password, fullName);
        break;
      case 'sign_in':
        if (!email || !password) throw new ValidationError('Wymagane: email i hasło.');
        res = await AuthRepository.signIn(email, password);
        break;
      case 'sign_out':
        await AuthRepository.signOut(await getUserId(authHeader));
        res = { signedOut: true };
        break;
      case 'reset_password':
        if (!email) throw new ValidationError('Wymagane: email.');
        await AuthRepository.resetPassword(email);
        res = { sent: true };
        break;
      case 'refresh_token':
        if (!refreshToken) throw new ValidationError('Wymagane: refreshToken.');
        res = await AuthRepository.refreshToken(refreshToken);
        break;
      case 'get_user':
        res = await AuthRepository.getUser(await getUserId(authHeader));
        break;
      default:
        throw new ValidationError('Nieznana akcja');
    }
    return new Response(JSON.stringify({ success: true, data: res }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) { return handleError(e); }
});
