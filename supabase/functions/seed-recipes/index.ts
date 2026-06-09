import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';

const SPOONACULAR_KEY = Deno.env.get('SPOONACULAR_API_KEY') ?? '';
const BASE = 'https://api.spoonacular.com';

const mapCuisine = (cuisines: string[]): string => {
  if (!cuisines?.length) return 'other';
  const c = cuisines[0].toLowerCase();
  if (c.includes('italian')) return 'italian';
  if (c.includes('asian') || c.includes('chinese') || c.includes('japanese') || c.includes('korean') || c.includes('thai') || c.includes('vietnamese')) return 'asian';
  if (c.includes('mexican') || c.includes('latin')) return 'mexican';
  if (c.includes('mediterranean') || c.includes('greek') || c.includes('middle eastern')) return 'mediterranean';
  if (c.includes('indian')) return 'indian';
  if (c.includes('american') || c.includes('southern')) return 'american';
  if (c.includes('french')) return 'french';
  if (c.includes('spanish')) return 'spanish';
  if (c.includes('german') || c.includes('european')) return 'european';
  return cuisines[0].toLowerCase().replace(/\s+/g, '-');
};

const mapMealType = (dishTypes: string[]): string => {
  if (!dishTypes?.length) return 'dinner';
  const t = dishTypes.map((x: string) => x.toLowerCase());
  if (t.some((x: string) => x.includes('breakfast') || x.includes('brunch') || x.includes('morning meal'))) return 'breakfast';
  if (t.some((x: string) => x.includes('lunch') || x.includes('salad') || x.includes('soup') || x.includes('sandwich'))) return 'lunch';
  if (t.some((x: string) => x.includes('snack') || x.includes('appetizer') || x.includes('antipasto') || x.includes('fingerfood') || x.includes('starter'))) return 'snack';
  if (t.some((x: string) => x.includes('dessert') || x.includes('sweet') || x.includes('cake') || x.includes('cookie') || x.includes('pastry') || x.includes('ice cream'))) return 'dessert';
  if (t.some((x: string) => x.includes('drink') || x.includes('beverage') || x.includes('cocktail') || x.includes('juice'))) return 'drink';
  return 'dinner';
};

const mapDietTags = (diets: string[], proteinG: number, carbsG: number, fatG: number, calories: number): string[] => {
  const tags: string[] = [];
  if (diets?.some((d: string) => d.toLowerCase().includes('vegetarian'))) tags.push('vegetarian');
  if (diets?.some((d: string) => d.toLowerCase().includes('vegan'))) tags.push('vegan');
  if (diets?.some((d: string) => d.toLowerCase().includes('gluten'))) tags.push('gluten-free');
  if (diets?.some((d: string) => d.toLowerCase().includes('ketogenic') || d.toLowerCase().includes('keto'))) tags.push('keto');
  if (diets?.some((d: string) => d.toLowerCase().includes('paleo'))) tags.push('paleo');
  if (diets?.some((d: string) => d.toLowerCase().includes('dairy'))) tags.push('dairy-free');
  if (proteinG >= 25) tags.push('high-protein');
  if (carbsG <= 20) tags.push('low-carb');
  if (calories <= 400) tags.push('low-calorie');
  if (fatG <= 10) tags.push('low-fat');
  return [...new Set(tags)];
};

const nut = (recipe: Record<string, unknown>, name: string): number => {
  const nutrients = (recipe.nutrition as Record<string, unknown>)?.nutrients as Array<Record<string, unknown>> | undefined;
  const n = nutrients?.find((x) => (x.name as string) === name);
  return Math.round(((n?.amount as number) ?? 0) * 10) / 10;
};

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  const supabase = getSupabaseAdmin();
  let total = 0;
  let errors = 0;

  // Search queries to get diverse recipes
  const searchQueries = [
    { cuisine: 'italian', type: '' },
    { cuisine: 'asian', type: '' },
    { cuisine: 'mexican', type: '' },
    { cuisine: 'mediterranean', type: '' },
    { cuisine: 'indian', type: '' },
    { cuisine: 'american', type: '' },
    { cuisine: 'french', type: '' },
    { cuisine: '', type: 'breakfast' },
    { cuisine: '', type: 'dessert' },
    { cuisine: '', type: 'snack' },
    { cuisine: '', type: 'soup' },
    { cuisine: '', type: 'salad' },
    { cuisine: '', type: 'main course' },
    { cuisine: '', type: 'side dish' },
    { cuisine: '', type: 'appetizer' },
    { cuisine: 'chinese', type: '' },
    { cuisine: 'japanese', type: '' },
    { cuisine: 'thai', type: '' },
    { cuisine: 'greek', type: '' },
    { cuisine: 'spanish', type: '' },
  ];

  for (const query of searchQueries) {
    try {
      const url = new URL(`${BASE}/recipes/complexSearch`);
      url.searchParams.set('apiKey', SPOONACULAR_KEY);
      url.searchParams.set('number', '15');
      url.searchParams.set('addRecipeNutrition', 'true');
      url.searchParams.set('addRecipeInformation', 'true');
      url.searchParams.set('fillIngredients', 'true');
      url.searchParams.set('sort', 'popularity');
      if (query.cuisine) url.searchParams.set('cuisine', query.cuisine);
      if (query.type) url.searchParams.set('type', query.type);

      const res = await fetch(url.toString());
      if (!res.ok) { errors++; continue; }
      const data = await res.json() as { results: Record<string, unknown>[] };
      const recipes = data.results ?? [];

      for (const r of recipes) {
        try {
          const proteinG = nut(r, 'Protein');
          const carbsG = nut(r, 'Carbohydrates');
          const fatG = nut(r, 'Fat');
          const calories = Math.round(nut(r, 'Calories'));
          const cuisines = (r.cuisines as string[]) ?? [];
          const dishTypes = (r.dishTypes as string[]) ?? [];
          const diets = (r.diets as string[]) ?? [];
          const analyzedInstructions = (r.analyzedInstructions as Array<{ steps: Array<{ number: number; step: string }> }>) ?? [];

          const steps = analyzedInstructions.flatMap((instruction) =>
            (instruction.steps ?? []).map((step) => ({
              number: step.number,
              step: step.step,
            }))
          );

          const extendedIngredients = (r.extendedIngredients as Array<Record<string, unknown>>) ?? [];
          const ingredients = extendedIngredients.map((i) => ({
            name: (i.name as string) ?? '',
            amount: (i.amount as number) ?? 1,
            unit: (i.unit as string) ?? '',
          }));

          const description = ((r.summary as string) ?? '')
            .replace(/<[^>]*>/g, '')
            .slice(0, 500);

          await supabase.from('recipes').upsert({
            title: r.title as string,
            source: 'spoonacular',
            source_id: String(r.id),
            image_url: r.image as string ?? '',
            cook_time_minutes: (r.readyInMinutes as number) ?? 30,
            servings: (r.servings as number) ?? 2,
            protein_g: proteinG,
            carbs_g: carbsG,
            fat_g: fatG,
            calories,
            cuisine_type: mapCuisine(cuisines),
            meal_type: mapMealType(dishTypes),
            diet_tags: mapDietTags(diets, proteinG, carbsG, fatG, calories),
            ingredients: ingredients.length > 0 ? ingredients : [{ name: 'See recipe', amount: 1, unit: '' }],
            steps: steps.length > 0 ? steps : [],
            description,
            is_public: true,
          }, { onConflict: 'source,source_id' });

          total++;
        } catch (_) { errors++; }
      }

      // Respect Spoonacular rate limit
      await new Promise((resolve) => setTimeout(resolve, 500));
    } catch (_) { errors++; }
  }

  return new Response(
    JSON.stringify({ success: true, seeded: total, errors }),
    { headers: { ...corsHeaders, 'Content-Type': 'application/json' } }
  );
});
