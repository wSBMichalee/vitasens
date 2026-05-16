import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { FamilyRepository } from './FamilyRepository.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    const { action, ...data } = await req.json();
    let res;
    switch (action) {
      case 'create': await SubscriptionGuard.checkFamilyAccess(userId); res = await FamilyRepository.create({ name: data.name, ownerId: userId }); break;
      case 'join': { await SubscriptionGuard.checkFamilyAccess(userId); const f = await FamilyRepository.findByInviteCode(data.inviteCode); await FamilyRepository.addMember(f.id, userId); res = { joined: true, family: f }; break; }
      case 'leave': await FamilyRepository.removeMember(data.familyId, userId); res = { left: true }; break;
      case 'members': await SubscriptionGuard.checkFamilyAccess(userId); res = await FamilyRepository.getMembers(data.familyId); break;
      case 'delete': await SubscriptionGuard.checkFamilyAccess(userId); await FamilyRepository.delete(data.familyId, userId); res = { deleted: true }; break;
      case 'my_family': res = await FamilyRepository.getUserFamily(userId); break;
      default: throw new ValidationError('Nieznana akcja');
    }
    return new Response(JSON.stringify({ success: true, data: res }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) { return handleError(e); }
});
