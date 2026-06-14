import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { AddIngredientSchema, UpdateIngredientSchema, DeleteIngredientSchema, ListPantrySchema } from '../_shared/validators.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { PantryRepository } from './PantryRepository.ts';
import { ExpiryChecker } from './ExpiryChecker.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    // await SubscriptionGuard.checkAccess(userId);
    const { action, ...data } = await req.json();
    let result;
    switch (action) {
      case 'add': {
        let pantryId = data.pantryId || data.pantry_id;
        if (!pantryId || pantryId === 'default') {
          pantryId = await PantryRepository.getPantryIdForUser(userId);
        }
        const expiryDate = data.expiryDate || data.expiry_date;
        const imageUrl = data.imageUrl || data.image_url;
        const parsedData = AddIngredientSchema.parse({ 
          ...data, 
          pantryId,
          ...(expiryDate && { expiryDate }),
          ...(imageUrl && { imageUrl }),
        });
        result = await PantryRepository.add(parsedData);
        break;
      }
      case 'update': {
        result = await PantryRepository.update(UpdateIngredientSchema.parse(data));
        break;
      }
      case 'delete': {
        await PantryRepository.delete(DeleteIngredientSchema.parse(data).id);
        result = { success: true };
        break;
      }
      case 'list': {
        let pantryId = data.pantryId || data.pantry_id;
        if (!pantryId || pantryId === 'default') {
          pantryId = await PantryRepository.getPantryIdForUser(userId);
        }
        result = await PantryRepository.list(pantryId);
        break;
      }
      case 'expiring': {
        let pantryId = data.pantryId || data.pantry_id;
        if (!pantryId || pantryId === 'default') {
          pantryId = await PantryRepository.getPantryIdForUser(userId);
        }
        result = await ExpiryChecker.getSummary(pantryId);
        break;
      }
      default:
        throw new ValidationError('Nieznana akcja');
    }
    return new Response(JSON.stringify({ success: true, data: result }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (error) {
    return handleError(error);
  }
});
