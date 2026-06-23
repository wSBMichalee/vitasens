import { serve } from "https://deno.land/std@0.224.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { getUserId, getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    await SubscriptionGuard.checkAccess(userId);
    
    const { mealType, excludeIds = [] } = await req.json();
    const supabase = getSupabaseAdmin();

    // Pobierz profil użytkownika
    const { data: profile } = await supabase
      .from('profiles')
      .select('allergies, dietary_preferences, health_conditions, daily_calorie_target, daily_protein_target, daily_carbs_target, daily_fat_target')
      .eq('id', userId)
      .single();

    // Pobierz składniki z pantry użytkownika
    const { data: pantryData } = await supabase
      .from('pantries')
      .select('id')
      .eq('user_id', userId)
      .single();

    let pantryIngredients: string[] = [];
    if (pantryData?.id) {
      const { data: ingredients } = await supabase
        .from('ingredients')
        .select('name')
        .eq('pantry_id', pantryData.id);
      pantryIngredients = (ingredients || []).map((i: any) => i.name.toLowerCase());
    }

    // Pobierz przepisy z bazy dopasowane do meal_type
    let query = supabase
      .from('recipes')
      .select('id, title, description, image_url, photo_url, meal_type, calories, protein_g, carbs_g, fat_g, cook_time_minutes, prep_time_minutes, ingredients, diet_tags, cuisine_type, servings')
      .eq('is_public', true);

    if (mealType && mealType !== 'all') {
      // Mapuj meal_type na dopuszczalne kategorie z bazy
      const mealTypeMap: Record<string, string[]> = {
        'breakfast': ['breakfast'],
        'lunch': ['lunch', 'dinner'],
        'dinner': ['dinner', 'lunch'],
        'snack': ['snack', 'dessert'],
      };
      const allowedTypes = mealTypeMap[mealType] || [mealType];
      query = query.in('meal_type', allowedTypes);
    }

    if (excludeIds.length > 0) {
      query = query.not('id', 'in', `(${excludeIds.join(',')})`);
    }

    query = query.limit(100);

    const { data: allRecipes, error } = await query;
    if (error) throw new Error(error.message);

    let recipes = allRecipes || [];

    // Filtruj po alergiach
    const allergies: string[] = profile?.allergies || [];
    if (allergies.length > 0) {
      recipes = recipes.filter(recipe => {
        const ingredientNames = (recipe.ingredients || [])
          .map((i: any) => (i.name || '').toLowerCase());
        return !allergies.some(allergy =>
          ingredientNames.some((ing: string) => ing.includes(allergy.toLowerCase()))
        );
      });
    }

    // Score po składnikach z pantry
    if (pantryIngredients.length > 0) {
      recipes = recipes.map(recipe => {
        const recipeIngredients = (recipe.ingredients || [])
          .map((i: any) => (i.name || '').toLowerCase());
        const matchCount = pantryIngredients.filter(pantryIng =>
          recipeIngredients.some((ri: string) => ri.includes(pantryIng) || pantryIng.includes(ri))
        ).length;
        return { ...recipe, matchScore: matchCount };
      }).sort((a: any, b: any) => b.matchScore - a.matchScore);
    } else {
      // Brak pantry — losuj
      recipes = recipes.sort(() => Math.random() - 0.5);
    }

    // Weź top 5
    const suggested = recipes.slice(0, 5).map(r => ({
      id: r.id,
      title: r.title,
      description: r.description,
      imageUrl: r.image_url || r.photo_url,
      mealType: r.meal_type,
      calories: r.calories || 0,
      proteinG: r.protein_g || 0,
      carbsG: r.carbs_g || 0,
      fatG: r.fat_g || 0,
      cookTimeMinutes: r.cook_time_minutes || 30,
      prepTimeMinutes: r.prep_time_minutes || 15,
      ingredients: r.ingredients || [],
      dietTags: r.diet_tags || [],
      cuisineType: r.cuisine_type,
      servings: r.servings || 4,
    }));

    return new Response(JSON.stringify({ success: true, data: { recipes: suggested } }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 200,
    });

  } catch (e: any) {
    return new Response(JSON.stringify({ error: e.message }), {
      headers: { ...corsHeaders, 'Content-Type': 'application/json' },
      status: 500,
    });
  }
});
