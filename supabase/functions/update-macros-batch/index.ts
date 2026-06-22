import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';

const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY');

async function fetchMacros(title: string, ingredients: any[]): Promise<{calories: number, proteinG: number, carbsG: number, fatG: number}> {
  if (!GEMINI_KEY) {
    console.error('No GEMINI_API_KEY');
    return { calories: 0, proteinG: 0, carbsG: 0, fatG: 0 };
  }
  
  const ingredientsList = ingredients
    .map((i: any) => `${i.name || ''} ${i.amount || ''}`.trim())
    .filter(s => s.length > 0)
    .join(', ');

  console.log(`Fetching macros for: ${title}, ingredients: ${ingredientsList.substring(0, 100)}`);

  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_KEY}`;
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 10000);

  try {
    const response = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        contents: [{ parts: [{ text: `Estimate macros per serving for recipe "${title}" with ingredients: ${ingredientsList}. Assume 4 servings. Return ONLY JSON: {"calories": number, "proteinG": number, "carbsG": number, "fatG": number}` }] }],
        generationConfig: { temperature: 0.1, maxOutputTokens: 150 }
      }),
      signal: controller.signal
    });
    clearTimeout(timeoutId);
    
    if (!response.ok) {
      const errText = await response.text();
      console.error(`Gemini error for ${title}:`, errText);
      return { calories: 0, proteinG: 0, carbsG: 0, fatG: 0 };
    }
    
    const data = await response.json();
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
    console.log(`Gemini response for ${title}:`, text);
    
    if (!text) return { calories: 0, proteinG: 0, carbsG: 0, fatG: 0 };
    
    const cleaned = text.replace(/```json/g, '').replace(/```/g, '').trim();
    const parsed = JSON.parse(cleaned);
    console.log(`Parsed macros for ${title}:`, JSON.stringify(parsed));
    return parsed;
  } catch (e) {
    clearTimeout(timeoutId);
    console.error(`Error fetching macros for ${title}:`, e);
    return { calories: 0, proteinG: 0, carbsG: 0, fatG: 0 };
  }
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
      // Pauza żeby nie przekroczyć limitu Gemini
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
