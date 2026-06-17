import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { CookingProcessor } from './CookingProcessor.ts';
import { RecipeRepository } from '../search-recipes/RecipeRepository.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    await SubscriptionGuard.checkAccess(userId);
    const data = await req.json();
    let recipe;
    try {
      recipe = await RecipeRepository.findById(data.recipeId);
    } catch (err: any) {
      console.error('Recipe not found in DB:', data.recipeId);
      return new Response(JSON.stringify({ 
        success: false, 
        error: "RECIPE_NOT_FOUND", 
        message: "Przepis nie istnieje w bazie. Odśwież listę przepisów." 
      }), { 
        status: 404, 
        headers: { ...corsHeaders, 'Content-Type': 'application/json' } 
      });
    }
    const res = await CookingProcessor.process(data.recipeId, data.familyId, userId, data.servingsCooked, recipe);
    return new Response(JSON.stringify({ success: true, data: res }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) { return handleError(e); }
});
