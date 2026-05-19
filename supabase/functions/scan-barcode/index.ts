import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId, getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { BarcodeNutritionFetcher } from './BarcodeNutritionFetcher.ts';
import { BarcodeProductMapper } from './BarcodeProductMapper.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') ?? '');
    await SubscriptionGuard.checkAccess(userId);

    const { action, barcode, servingG, mealTime, mealDate, pantryId, quantity, unit } =
      await req.json() as {
        action: string; barcode: string; servingG?: number;
        mealTime?: string; mealDate?: string;
        pantryId?: string; quantity?: number; unit?: string;
      };

    if (!barcode) throw new ValidationError('Brak kodu kreskowego');

    const fetcher = new BarcodeNutritionFetcher();
    const mapper  = new BarcodeProductMapper();
    const product = await fetcher.fetchByBarcode(barcode);
    let res: unknown;

    switch (action) {
      case 'lookup':
        res = product;
        break;

      case 'log_meal': {
        if (!mealTime || !mealDate) throw new ValidationError('Brak mealTime lub mealDate');
        const serving = servingG ?? product.servingSizeG;
        const payload = mapper.toMealPayload(product, serving, userId, mealTime, mealDate);
        const { error } = await getSupabaseAdmin().from('meals').insert(payload);
        if (error) throw new Error(error.message);
        res = { logged: true, foodName: payload.food_name, macros: mapper.scaleMacros(product, serving) };
        break;
      }

      case 'add_to_pantry': {
        if (!pantryId || !quantity || !unit) throw new ValidationError('Brak pantryId, quantity lub unit');
        const payload = mapper.toIngredientPayload(product, pantryId, quantity, unit);
        const { error } = await getSupabaseAdmin().from('ingredients').insert(payload);
        if (error) throw new Error(error.message);
        res = { added: true, name: product.name, brand: product.brand };
        break;
      }

      default:
        throw new ValidationError('Nieznana akcja. Użyj: lookup, log_meal, add_to_pantry');
    }

    return new Response(
      JSON.stringify({ success: true, data: res }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) { return handleError(e); }
});
