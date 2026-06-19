import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { ProfileRepository } from '../calculate-daily-macros/ProfileRepository.ts';
import { SpoonacularClient } from './SpoonacularClient.ts';
import { IngredientMatcher } from './IngredientMatcher.ts';
import { RecipeRepository } from './RecipeRepository.ts';
import { GeminiPersonalizer } from './GeminiPersonalizer.ts';

// Pomocnicze funkcje mapowania
const mapCuisine = (cuisines: string[]): string => {
  if (!cuisines || cuisines.length === 0) return 'other';
  const c = cuisines[0].toLowerCase();
  if (c.includes('italian')) return 'italian';
  if (c.includes('asian') || c.includes('chinese') || c.includes('japanese') || c.includes('korean') || c.includes('thai')) return 'asian';
  if (c.includes('mexican') || c.includes('latin')) return 'mexican';
  if (c.includes('mediterranean') || c.includes('greek')) return 'mediterranean';
  if (c.includes('indian')) return 'indian';
  if (c.includes('american')) return 'american';
  if (c.includes('french')) return 'french';
  return cuisines[0].toLowerCase();
};

const mapMealType = (dishTypes: string[]): string => {
  if (!dishTypes || dishTypes.length === 0) return 'dinner';
  const types = dishTypes.map(t => t.toLowerCase());
  if (types.some(t => t.includes('breakfast') || t.includes('morning'))) return 'breakfast';
  if (types.some(t => t.includes('lunch') || t.includes('salad') || t.includes('soup'))) return 'lunch';
  if (types.some(t => t.includes('snack') || t.includes('appetizer') || t.includes('fingerfood'))) return 'snack';
  if (types.some(t => t.includes('dessert') || t.includes('sweet') || t.includes('cake') || t.includes('cookie'))) return 'dessert';
  return 'dinner';
};

const mapDietTags = (diets: string[], proteinG: number, carbsG: number, fatG: number, calories: number): string[] => {
  const tags: string[] = [];
  if (diets) {
    if (diets.some(d => d.toLowerCase().includes('vegetarian'))) tags.push('vegetarian');
    if (diets.some(d => d.toLowerCase().includes('vegan'))) tags.push('vegan');
    if (diets.some(d => d.toLowerCase().includes('gluten'))) tags.push('gluten-free');
    if (diets.some(d => d.toLowerCase().includes('ketogenic') || d.toLowerCase().includes('keto'))) tags.push('keto');
    if (diets.some(d => d.toLowerCase().includes('paleo'))) tags.push('paleo');
  }
  // Auto-tag na podstawie makr
  if (proteinG >= 25) tags.push('high-protein');
  if (carbsG <= 20) tags.push('low-carb');
  if (calories <= 400) tags.push('low-calorie');
  return [...new Set(tags)];
};

// ─── HANDLER ──────────────────────────────────────────────────────────────────

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
        const ingredientNames: string[] = (data.pantryIngredients ?? []).map(
          (i: { name?: string } | string) => typeof i === 'string' ? i : (i.name ?? '')
        );

        // OPTYMALIZACJA 1: Parallel fetch
        const [sr, profile] = await Promise.all([
          spoon.findByIngredients(ingredientNames),
          ProfileRepository.getById(userId)
        ]);
        const matches = IngredientMatcher
          .sortByBestMatch(IngredientMatcher.buildMatchResults(sr))
          .slice(0, 20);

        if (matches.length === 0) {
          res = { recipes: [], totalFound: 0, geminiPersonalized: true };
          break;
        }

        const details = await spoon.getRecipesBulk(matches.map(m => m.recipeId));

        const mappedForUpsert = details.map(d => {
          const s = sr.find(x => x.id === d.id)!;
          const nut = (n: string) => d.nutrition?.nutrients.find((x: { name: string; amount: number }) => x.name === n)?.amount || 0;
          return {
            title: d.title, source: 'spoonacular' as const, sourceId: d.id.toString(),
            ingredients: [...(s.usedIngredients || []), ...(s.missedIngredients || [])].map(i => ({ name: i.name, amount: i.amount, unit: i.unit })),
            proteinG: Math.round(nut('Protein') * 10) / 10,
            carbsG: Math.round(nut('Carbohydrates') * 10) / 10,
            fatG: Math.round(nut('Fat') * 10) / 10,
            calories: Math.round(nut('Calories')),
            cookTimeMinutes: d.readyInMinutes, servings: d.servings, imageUrl: d.image,
            cuisineType: mapCuisine(d.cuisines ?? []),
            mealType: mapMealType(d.dishTypes ?? []),
            dietTags: mapDietTags(d.diets ?? [], Math.round(nut('Protein') * 10) / 10, Math.round(nut('Carbohydrates') * 10) / 10, Math.round(nut('Fat') * 10) / 10, Math.round(nut('Calories'))),
          };
        });

        // OPTYMALIZACJA 3: Ogranicz payload do Gemini i użyj sourceId jako klucz
        const recipesForGemini = mappedForUpsert.map(r => {
          const match = matches.find(m => m.recipeId.toString() === r.sourceId);
          return {
            id: r.sourceId,
            title: r.title,
            calories: r.calories,
            proteinG: r.proteinG,
            carbsG: r.carbsG,
            fatG: r.fatG,
            dietTags: r.dietTags,
            matchPercent: match?.matchPercent || 0
          };
        });

        // OPTYMALIZACJA 2: Upsert i Gemini równolegle
        const [savedRecipes, ranked] = await Promise.all([
          RecipeRepository.upsertMany(mappedForUpsert),
          GeminiPersonalizer.rankRecipes(recipesForGemini, profile).catch(e => {
            console.error('GeminiPersonalizer error:', e);
            return recipesForGemini.map(r => ({ id: r.id, reason: '' }));
          })
        ]);
        
        const recipesWithMatches = savedRecipes.map(r => {
          const match = matches.find(m => m.recipeId.toString() === r.sourceId);
          const s = sr.find(x => x.id.toString() === r.sourceId);
          return { 
            ...r, 
            matchPercent: match?.matchPercent || 0,
            usedIngredients: s?.usedIngredients || [],
            missedIngredients: s?.missedIngredients || []
          };
        });

        const finalRecipes = [];
        for (const rnk of ranked) {
          const rec = recipesWithMatches.find(r => r.sourceId === rnk.id);
          if (rec) {
            finalRecipes.push({
              ...rec,
              geminiReason: rnk.reason || undefined
            });
          }
        }
        
        // Fallback: dodaj te, które Gemini mogło pominąć
        for (const rec of recipesWithMatches) {
          if (!finalRecipes.find(f => f.id === rec.id)) {
            finalRecipes.push(rec);
          }
        }

        res = {
          recipes: finalRecipes,
          totalFound: finalRecipes.length,
          geminiPersonalized: true
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
