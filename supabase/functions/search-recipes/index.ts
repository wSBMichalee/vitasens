import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { HealthPromptBuilder, HealthCondition } from '../_shared/HealthPromptBuilder.ts';
import { ProfileRepository } from '../calculate-daily-macros/ProfileRepository.ts';
import { SpoonacularClient } from './SpoonacularClient.ts';
import { IngredientMatcher } from './IngredientMatcher.ts';
import { RecipeRepository } from './RecipeRepository.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    await SubscriptionGuard.checkAccess(userId);
    const { action, ...data } = await req.json();
    const spoon = new SpoonacularClient();
    let res;
    switch (action) {
      case 'search': {
        const sr = await spoon.findByIngredients(data.pantryIngredients);
        const matches = IngredientMatcher.sortByBestMatch(IngredientMatcher.filterByMinMatch(IngredientMatcher.buildMatchResults(sr))).slice(0, 10);
        const details = await spoon.getRecipesBulk(matches.map(m => m.recipeId));
        const upserted = await RecipeRepository.upsertMany(details.map(d => {
          const s = sr.find(x => x.id === d.id)!;
          const nut = (n: string) => d.nutrition?.nutrients.find(x => x.name === n)?.amount || 0;
          return {
            title: d.title, source: 'spoonacular', sourceId: d.id.toString(),
            ingredients: [...s.usedIngredients, ...s.missedIngredients].map(i => ({ name: i.name, amount: i.amount, unit: i.unit })),
            proteinG: nut('Protein'), carbsG: nut('Carbohydrates'), fatG: nut('Fat'), calories: nut('Calories'),
            cookTimeMinutes: d.readyInMinutes, servings: d.servings, imageUrl: d.image
          };
        }));
        const recipes = upserted.map(r => ({ ...r, matchPercent: matches.find(m => m.recipeId.toString() === r.sourceId)?.matchPercent }));

        const profile = await ProfileRepository.getById(userId);
        const builder = new HealthPromptBuilder();
        const conditions = (profile.healthConditions ?? []) as HealthCondition[];
        const forbidden = builder.getForbiddenIngredients(conditions);
        const warnings = conditions.flatMap((c) => builder.getWarningsForCondition(c));

        const filtered = forbidden.length === 0
          ? recipes
          : recipes.filter((recipe) => {
            const names = (recipe.ingredients as Array<{ name: string }>)
              .map((i) => i.name.toLowerCase());
            return !forbidden.some((f) => names.some((n) => n.includes(f.toLowerCase())));
          });

        res = {
          recipes: filtered,
          totalFound: recipes.length,
          filteredOut: recipes.length - filtered.length,
          healthWarnings: warnings,
        };
        break;
      }
      case 'favorites': res = await RecipeRepository.getFavorites(userId); break;
      case 'add_favorite': await RecipeRepository.addToFavorites(userId, data.recipeId); res = { saved: true }; break;
      case 'remove_favorite': await RecipeRepository.removeFromFavorites(userId, data.recipeId); res = { removed: true }; break;
      case 'is_favorite': res = { isFavorite: await RecipeRepository.isFavorite(userId, data.recipeId) }; break;
      default: throw new ValidationError('Nieznana akcja');
    }
    return new Response(JSON.stringify({ success: true, data: res }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) { return handleError(e); }
});
