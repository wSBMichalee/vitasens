import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { getSupabaseAdmin } from "../_shared/supabaseClient.ts";
import { corsHeaders } from "../_shared/corsHeaders.ts";

const GEMINI_KEY = Deno.env.get('GEMINI_API_KEY');
const letters = ['a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t','u','v','w','y'];

async function fetchGeminiMacros(meal: any, ingredientsList: string) {
  if (!GEMINI_KEY) {
    console.warn("GEMINI_API_KEY not set. Using fallback macros.");
    return { proteinG: 0, carbsG: 0, fatG: 0, calories: 0 };
  }

  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent?key=${GEMINI_KEY}`;
  const controller = new AbortController();
  const timeoutId = setTimeout(() => controller.abort(), 6000);

  try {
    const response = await fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        contents: [{
          parts: [{
            text: `Oszacuj makroskładniki na 1 porcję dla przepisu '${meal.strMeal}' ze składnikami: ${ingredientsList}. Zakładaj 4 porcje jeśli nie podano. Zwróć TYLKO JSON bez markdown i bez żadnego innego tekstu: {"proteinG": number, "carbsG": number, "fatG": number, "calories": number}`
          }]
        }],
        generationConfig: {
          temperature: 0.1,
          maxOutputTokens: 100
        }
      }),
      signal: controller.signal
    });

    clearTimeout(timeoutId);

    if (!response.ok) {
      console.error("Gemini API error:", await response.text());
      return { proteinG: 0, carbsG: 0, fatG: 0, calories: 0 };
    }

    const data = await response.json();
    const text = data.candidates?.[0]?.content?.parts?.[0]?.text;
    
    if (text) {
      const cleaned = text.replace(/```json/g, '').replace(/```/g, '').trim();
      return JSON.parse(cleaned);
    }
  } catch (error) {
    console.error(`Gemini fetch error for ${meal.strMeal}:`, error);
  } finally {
    clearTimeout(timeoutId);
  }

  return { proteinG: 0, carbsG: 0, fatG: 0, calories: 0 };
}

serve(async (req) => {
  if (req.method === 'OPTIONS') {
    return new Response('ok', { headers: corsHeaders });
  }

  try {
    let body = {};
    if (req.body) {
      try {
        body = await req.json();
      } catch (e) {
        // Ignoruj błąd parsowania pustego body
      }
    }
    
    const requestedLetter = (body as any).letter;
    const targetLetters = requestedLetter ? [requestedLetter.toLowerCase()] : letters;

    const supabase = getSupabaseAdmin();
    let totalImported = 0;

    for (const letter of targetLetters) {
      console.log(`Fetching meals starting with '${letter}'...`);
      const response = await fetch(`https://www.themealdb.com/api/json/v1/1/search.php?f=${letter}`);
      if (!response.ok) {
         console.error(`Failed to fetch for ${letter}`);
         continue;
      }
      
      const data = await response.json();
      if (!data.meals) continue;

      for (const meal of data.meals) {
        // Check if already imported
        const { data: existing } = await supabase
          .from('recipes')
          .select('id')
          .eq('source_id', meal.idMeal)
          .eq('source', 'themealdb')
          .maybeSingle();

        if (existing) {
          console.log(`Skipping ${meal.strMeal}, already exists.`);
          continue;
        }

        // Map Category to generic meal_type
        let mealType = meal.strCategory?.toLowerCase() || 'dinner';
        if (['chicken', 'beef', 'seafood', 'pork', 'lamb', 'pasta', 'vegetarian', 'vegan', 'miscellaneous', 'goat'].includes(mealType)) {
          mealType = 'dinner';
        } else if (['starter', 'side'].includes(mealType)) {
          mealType = 'snack';
        }

        const cuisineType = meal.strArea?.toLowerCase() || 'international';

        // Parse ingredients
        const ingredients = [];
        const ingredientsStringParts = [];
        for (let i = 1; i <= 20; i++) {
          const name = meal[`strIngredient${i}`];
          const measure = meal[`strMeasure${i}`];
          if (name && name.trim() !== '') {
            const cleanName = name.trim();
            const cleanMeasure = measure ? measure.trim() : '';
            ingredients.push({
              name: cleanName,
              amount: cleanMeasure
            });
            ingredientsStringParts.push(`${cleanName} ${cleanMeasure}`.trim());
          }
        }
        const ingredientsList = ingredientsStringParts.join(', ');

        const steps = meal.strInstructions ? meal.strInstructions.split(/\r?\n/).filter((s: string) => s.trim() !== '') : [];

        console.log(`Estimating macros for ${meal.strMeal}...`);
        const macros = await fetchGeminiMacros(meal, ingredientsList);

        const { error: insertError } = await supabase.from('recipes').insert({
          title: meal.strMeal,
          description: meal.strMeal,
          image_url: meal.strMealThumb,
          meal_type: mealType,
          cuisine_type: cuisineType,
          prep_time_minutes: 15, // Domyślne wartości
          cook_time_minutes: 30,
          difficulty_level: 'medium',
          ingredients,
          steps,
          calories: macros.calories || 0,
          protein_g: macros.proteinG || 0,
          carbs_g: macros.carbsG || 0,
          fat_g: macros.fatG || 0,
          source: 'themealdb',
          source_id: meal.idMeal,
          is_public: true
        });

        if (insertError) {
          console.error(`Error inserting ${meal.strMeal}:`, insertError);
        } else {
          console.log(`Inserted ${meal.strMeal}`);
          totalImported++;
        }
      }
    }

    return new Response(JSON.stringify({ success: true, totalImported }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (error: any) {
    console.error("Error seeding recipes:", error);
    return new Response(JSON.stringify({ error: error.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
