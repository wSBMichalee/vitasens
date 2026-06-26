import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId, getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { ProfileRepository } from '../calculate-daily-macros/ProfileRepository.ts';
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
    let res;

    switch (action) {
      case 'search':
      case 'search_fast': {
        const ingredientNames: string[] = (data.pantryIngredients ?? []).map(
          (i: { name?: string } | string) => typeof i === 'string' ? i : (i.name ?? '')
        ).filter((n: string) => n.length > 0);

        const profile = await ProfileRepository.getById(userId);

        const supabase = getSupabaseAdmin();

        let query = supabase
          .from('recipes')
          .select('id, title, description, image_url, photo_url, meal_type, cuisine_type, diet_tags, calories, protein_g, carbs_g, fat_g, cook_time_minutes, prep_time_minutes, difficulty_level, servings, ingredients, source, source_id, steps')
          .eq('is_public', true)
          .limit(50);

        const { data: allRecipes, error: dbError } = await query;
        if (dbError) throw new Error(dbError.message);

        let recipes = allRecipes || [];

        // Filtruj i score po stronie serwera
        if (ingredientNames.length > 0) {
          const lowerIngredients = ingredientNames.map(n => n.toLowerCase());
          
          recipes = recipes
            .map(recipe => {
              const recipeIngredientNames: string[] = (recipe.ingredients || [])
                .map((ing: { name: string }) => ing.name?.toLowerCase() || '');
              
              const usedCount = lowerIngredients.filter(pantryIng =>
                recipeIngredientNames.some(recipeIng => recipeIng.includes(pantryIng) || pantryIng.includes(recipeIng))
              ).length;
              
              const matchPercent = Math.round((usedCount / Math.max(recipeIngredientNames.length, 1)) * 100);
              
              return { ...recipe, matchPercent, usedCount };
            })
            .filter(r => r.usedCount > 0)
            .sort((a, b) => b.matchPercent - a.matchPercent)
            .slice(0, 20);
        } else {
          // Brak składników — zwróć losowe przepisy
          recipes = recipes.sort(() => Math.random() - 0.5).slice(0, 20);
        }

        // Pobierz składniki z pantry użytkownika
        let pantryIngredientNames: string[] = [];
        try {
          const { data: pantryData } = await supabase
            .from('pantries')
            .select('id')
            .eq('owner_id', userId)
            .maybeSingle();
          
          if (pantryData?.id) {
            const { data: pantryItems } = await supabase
              .from('ingredients')
              .select('name')
              .eq('pantry_id', pantryData.id);
            pantryIngredientNames = (pantryItems || []).map((i: any) => i.name.toLowerCase());
          }
        } catch (e) {
          console.log('Could not fetch pantry:', e);
        }

        // Mapuj do formatu zgodnego z RecipeModel (camelCase)
        const mappedRecipes = recipes.map(r => ({
          id: r.id,
          title: r.title,
          description: r.description,
          imageUrl: r.image_url || r.photo_url,
          mealType: r.meal_type,
          cuisineType: r.cuisine_type,
          dietTags: r.diet_tags || [],
          calories: r.calories || 0,
          proteinG: r.protein_g || 0,
          carbsG: r.carbs_g || 0,
          fatG: r.fat_g || 0,
          cookTimeMinutes: r.cook_time_minutes || 30,
          prepTimeMinutes: r.prep_time_minutes || 15,
          difficultyLevel: r.difficulty_level || 'medium',
          servings: r.servings || 4,
          ingredients: r.ingredients || [],
          source: r.source,
          sourceId: r.source_id,
          steps: r.steps || [],
          matchPercent: (r as any).matchPercent || 0,
          usedIngredients: (r.ingredients || []).filter((ing: any) => {
            const name = (ing.name || '').toLowerCase();
            return pantryIngredientNames.some(p => name.includes(p) || p.includes(name));
          }).map((ing: any) => ({ name: ing.name, amount: ing.amount || '' })),
          missedIngredients: (r.ingredients || []).filter((ing: any) => {
            const name = (ing.name || '').toLowerCase();
            return !pantryIngredientNames.some(p => name.includes(p) || p.includes(name));
          }).map((ing: any) => ({ name: ing.name, amount: ing.amount || '' }))
        }));

        // Gemini personalizacja
        const recipesForGemini = mappedRecipes.map(r => ({
          id: r.id,
          title: r.title,
          calories: r.calories,
          proteinG: r.proteinG,
          carbsG: r.carbsG,
          fatG: r.fatG,
          dietTags: r.dietTags || [],
          matchPercent: r.matchPercent
        }));

        const ranked = await GeminiPersonalizer.rankRecipes(recipesForGemini, profile).catch(e => {
          console.error('GeminiPersonalizer error:', e);
          return recipesForGemini.map(r => ({ id: r.id, reason: '' }));
        });

        const finalRecipes = [];
        for (const rnk of ranked) {
          const rec = mappedRecipes.find(r => r.id === rnk.id);
          if (rec) finalRecipes.push({ ...rec, geminiReason: rnk.reason || undefined });
        }
        for (const rec of mappedRecipes) {
          if (!finalRecipes.find(f => f.id === rec.id)) finalRecipes.push(rec);
        }

        res = { recipes: finalRecipes, totalFound: finalRecipes.length, geminiPersonalized: true };
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
