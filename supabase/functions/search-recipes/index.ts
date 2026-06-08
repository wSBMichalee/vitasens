import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId, getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { HealthPromptBuilder, HealthCondition } from '../_shared/HealthPromptBuilder.ts';
import { ProfileRepository } from '../calculate-daily-macros/ProfileRepository.ts';
import { SpoonacularClient } from './SpoonacularClient.ts';
import { IngredientMatcher } from './IngredientMatcher.ts';
import { RecipeRepository } from './RecipeRepository.ts';

// ─── STAŁE ────────────────────────────────────────────────────────────────────
const CACHE_TTL_DAYS = 7;

// ─── CACHE HELPERS ────────────────────────────────────────────────────────────

/** Generuje klucz cache z posortowanej listy składników */
async function buildCacheKey(ingredients: string[]): Promise<string> {
  const normalized = [...ingredients].sort().join(',').toLowerCase();
  const data = new TextEncoder().encode(normalized);
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 32);
}

/** Pobiera wynik z cache jeśli istnieje i nie wygasł (7 dni) */
async function getCachedRecipes(cacheKey: string): Promise<unknown[] | null> {
  const supabase = getSupabaseAdmin();
  const since = new Date(Date.now() - CACHE_TTL_DAYS * 24 * 60 * 60 * 1000).toISOString();
  const { data } = await supabase
    .from('recipe_cache')
    .select('result')
    .eq('cache_key', cacheKey)
    .gte('created_at', since)
    .maybeSingle();
  return data?.result ?? null;
}

/** Zapisuje wyniki Spoonacular do cache */
async function saveRecipesToCache(cacheKey: string, result: unknown): Promise<void> {
  const supabase = getSupabaseAdmin();
  await supabase
    .from('recipe_cache')
    .upsert({ cache_key: cacheKey, result }, { onConflict: 'cache_key' });
}

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
        // Makra pobierane BEZPOŚREDNIO z Spoonacular (nutrition.nutrients)
        // Nie używamy AI/Gemini do obliczania makr — oszczędność kosztów
        const ingredientNames: string[] = (data.pantryIngredients ?? []).map(
          (i: { name?: string } | string) => typeof i === 'string' ? i : (i.name ?? '')
        );

        // Cache lookup — klucz to hash posortowanych składników
        const cacheKey = await buildCacheKey(ingredientNames);
        const cachedRecipes = await getCachedRecipes(cacheKey);

        let upserted: unknown[];
        let fromCache = false;

        if (cachedRecipes) {
          // Cache HIT — nie płacimy za Spoonacular API
          upserted = cachedRecipes as unknown[];
          fromCache = true;
        } else {
          // Cache MISS — pobieramy ze Spoonacular i zapisujemy
          const sr = await spoon.findByIngredients(ingredientNames);
          const matches = IngredientMatcher
            .sortByBestMatch(IngredientMatcher.filterByMinMatch(IngredientMatcher.buildMatchResults(sr)))
            .slice(0, 10);
          const details = await spoon.getRecipesBulk(matches.map(m => m.recipeId));

          const mappedForUpsert = details.map(d => {
            const s = sr.find(x => x.id === d.id)!;
            // Makra z Spoonacular — bez AI (OPTYMALIZACJA 3)
            const nut = (n: string) => d.nutrition?.nutrients.find((x: { name: string; amount: number }) => x.name === n)?.amount || 0;
            return {
              title: d.title, source: 'spoonacular' as const, sourceId: d.id.toString(),
              ingredients: [...s.usedIngredients, ...s.missedIngredients].map(i => ({ name: i.name, amount: i.amount, unit: i.unit })),
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

          const savedRecipes = await RecipeRepository.upsertMany(mappedForUpsert);
          
          upserted = savedRecipes.map(r => {
            const match = matches.find(m => m.recipeId.toString() === r.sourceId);
            return { ...r, matchPercent: match?.matchPercent || 0 };
          });

          // Zapisz do cache (7 dni TTL)
          await saveRecipesToCache(cacheKey, upserted);
        }

        // Filtrowanie zdrowotne (bez AI — czysta logika)
        const profile = await ProfileRepository.getById(userId);
        const builder = new HealthPromptBuilder();
        const conditions = (profile.healthConditions ?? []) as HealthCondition[];
        const forbidden = builder.getForbiddenIngredients(conditions);
        const warnings = conditions.flatMap((c) => builder.getWarningsForCondition(c));

        const recipes = upserted as Array<{ ingredients: Array<{ name: string }> }>;
        const filtered = forbidden.length === 0
          ? recipes
          : recipes.filter((recipe) => {
            const names = recipe.ingredients.map((i) => i.name.toLowerCase());
            return !forbidden.some((f) => names.some((n) => n.includes(f.toLowerCase())));
          });

        res = {
          recipes: filtered,
          totalFound: recipes.length,
          filteredOut: recipes.length - filtered.length,
          healthWarnings: warnings,
          fromCache,
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
