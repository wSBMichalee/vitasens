import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';

const USDA_KEY = Deno.env.get('USDA_API_KEY');

async function searchUSDA(ingredientName: string): Promise<{calories: number, proteinG: number, carbsG: number, fatG: number} | null> {
  try {
    const url = `https://api.nal.usda.gov/fdc/v1/foods/search?query=${encodeURIComponent(ingredientName)}&pageSize=1&api_key=${USDA_KEY}`;
    const res = await fetch(url);
    if (!res.ok) return null;
    const data = await res.json();
    const food = data.foods?.[0];
    if (!food) return null;

    const getNutrient = (id: number) => {
      const n = food.foodNutrients?.find((n: any) => n.nutrientId === id);
      return n?.value ?? 0;
    };

    // USDA nutrient IDs: 1008=Energy(kcal), 1003=Protein, 1005=Carbs, 1004=Fat
    return {
      calories: getNutrient(1008),
      proteinG: getNutrient(1003),
      carbsG: getNutrient(1005),
      fatG: getNutrient(1004),
    };
  } catch {
    return null;
  }
}

async function fetchMacros(title: string, ingredients: any[]): Promise<{calories: number, proteinG: number, carbsG: number, fatG: number}> {
  if (!USDA_KEY) {
    console.error('No USDA_API_KEY');
    return { calories: 0, proteinG: 0, carbsG: 0, fatG: 0 };
  }

  let totalCalories = 0, totalProtein = 0, totalCarbs = 0, totalFat = 0;
  let ingredientsFound = 0;

  for (const ing of ingredients) {
    const name = (ing.name || '').trim();
    if (!name) continue;

    const macros = await searchUSDA(name);
    if (!macros) continue;

    // Szacuj ilość - jeśli brak to zakładaj 100g
    const amountStr = (ing.amount || ing.measure || '').toString().toLowerCase();
    let grams = 100; // default
    const match = amountStr.match(/(\d+\.?\d*)\s*(g|gram|grams)/);
    if (match) grams = parseFloat(match[1]);
    else if (amountStr.includes('cup')) grams = 240;
    else if (amountStr.includes('tbsp') || amountStr.includes('tablespoon')) grams = 15;
    else if (amountStr.includes('tsp') || amountStr.includes('teaspoon')) grams = 5;
    else if (amountStr.includes('oz')) grams = 28;
    else if (amountStr.includes('lb')) grams = 454;

    const factor = grams / 100;
    totalCalories += macros.calories * factor;
    totalProtein += macros.proteinG * factor;
    totalCarbs += macros.carbsG * factor;
    totalFat += macros.fatG * factor;
    ingredientsFound++;
  }

  if (ingredientsFound === 0) {
    // Fallback — szacuj po nazwie przepisu
    const titleMacros = await searchUSDA(title);
    if (titleMacros) return titleMacros;
    return { calories: 0, proteinG: 0, carbsG: 0, fatG: 0 };
  }

  // Podziel przez liczbę porcji (zakładamy 4)
  const servings = 4;
  return {
    calories: Math.round(totalCalories / servings),
    proteinG: Math.round(totalProtein / servings * 10) / 10,
    carbsG: Math.round(totalCarbs / servings * 10) / 10,
    fatG: Math.round(totalFat / servings * 10) / 10,
  };
}
serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });

  try {
    const supabase = getSupabaseAdmin();

    // Pobierz 20 przepisów z calories = 0
    const { data: recipes, error } = await supabase
      .from('recipes')
      .select('id, title, ingredients')
      .eq('calories', 0)
      .limit(20);

    if (error) throw new Error(error.message);
    if (!recipes || recipes.length === 0) {
      return new Response(JSON.stringify({ success: true, updated: 0, message: 'All recipes have macros!' }), {
        headers: { ...corsHeaders, 'Content-Type': 'application/json' }
      });
    }

    let updated = 0;
    for (const recipe of recipes) {
      const macros = await fetchMacros(recipe.title, recipe.ingredients || []);
      if (macros.calories > 0) {
        await supabase.from('recipes').update({
          calories: macros.calories,
          protein_g: macros.proteinG,
          carbs_g: macros.carbsG,
          fat_g: macros.fatG,
        }).eq('id', recipe.id);
        updated++;
      }
      // Pauza żeby nie przekroczyć limitu USDA
      await new Promise(resolve => setTimeout(resolve, 500));
    }

    return new Response(JSON.stringify({ success: true, updated, remaining: recipes.length - updated }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' }
    });

  } catch (e: any) {
    return new Response(JSON.stringify({ error: e.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500
    });
  }
});
