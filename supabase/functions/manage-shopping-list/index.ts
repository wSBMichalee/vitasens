import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { AddShoppingItemSchema, MarkPurchasedSchema, DeleteShoppingItemSchema, MoveToPantrySchema } from '../_shared/validators.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { ShoppingListRepository } from './ShoppingListRepository.ts';
import { ShoppingListSyncer } from './ShoppingListSyncer.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    await SubscriptionGuard.checkAccess(userId);
    const { action, ...data } = await req.json();
    let result;
    switch (action) {
      case 'list': result = data.familyId ? await ShoppingListRepository.listForFamily(data.familyId) : await ShoppingListRepository.listForUser(userId); break;
      case 'add': result = await ShoppingListRepository.add(AddShoppingItemSchema.parse({ ...data, userId })); break;
      case 'add_batch': {
        const items = data.items as Array<{ingredientName: string, quantityNeeded: number, unit: string}>;
        if (!items || !Array.isArray(items)) throw new ValidationError('items array required');
        
        const results = [];
        for (const item of items) {
          const result = await ShoppingListRepository.add({
            userId,
            ingredientName: item.ingredientName,
            quantityNeeded: item.quantityNeeded || 1,
            unit: item.unit || 'szt',
            source: 'manual',
          });
          results.push(result);
        }
        result = { added: results.length, items: results };
        break;
      }
      case 'purchased': result = await ShoppingListRepository.markAsPurchased(MarkPurchasedSchema.parse(data).itemId); break;
      case 'delete': await ShoppingListRepository.delete(DeleteShoppingItemSchema.parse(data).itemId); result = { success: true }; break;
      case 'clear_purchased': await ShoppingListRepository.clearPurchased(userId, data.familyId); result = { success: true }; break;
      case 'sync': result = await ShoppingListSyncer.syncAll(data.pantryId, userId, data.familyId); break;
      case 'deduplicate': result = await ShoppingListSyncer.deduplicateList(userId, data.familyId); break;
      case 'move_to_pantry': {
        const v = MoveToPantrySchema.parse({ action, ...data });
        const { shoppingItem, ingredient } = await ShoppingListSyncer.moveToPantry(v.itemId, userId, v.quantity, v.unit, v.familyId);
        result = { shoppingItem, ingredient, message: "Produkt dodany do spiżarni" };
        break;
      }
      default: throw new ValidationError('Nieznana akcja');
    }
    return new Response(JSON.stringify({ success: true, data: result }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (error) { return handleError(error); }
});
