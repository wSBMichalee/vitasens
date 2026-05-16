import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { VisionClient } from './VisionClient.ts';
import { FoodFilter } from './FoodFilter.ts';
import { NutritionEstimator } from './NutritionEstimator.ts';
import { MealRepository } from './MealRepository.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    await SubscriptionGuard.checkAccess(userId);
    const { action, ...data } = await req.json();
    let res;
    switch (action) {
      case 'detect': {
        const up = await MealRepository.uploadPhoto(userId, data.photoBase64, data.mealTime);
        const dr = await new VisionClient().detectLabels(data.photoBase64);
        const items = FoodFilter.extractFoodLabels(dr.labels);
        const fr = FoodFilter.getFilterResult(items);
        const nutr = await new NutritionEstimator().estimateForMeal(items);
        const meal = await MealRepository.saveDetectedMeal({
          userId, mealDate: data.mealDate, mealTime: data.mealTime, foodName: fr.allFoodsLabel, photoUrl: up.publicUrl,
          proteinG: nutr.totalProteinG, carbsG: nutr.totalCarbsG, fatG: nutr.totalFatG, calories: nutr.totalCalories,
          confidence: fr.averageConfidence, detectedFoods: nutr.detectedFoods
        });
        res = { meal, detectedFoods: fr.foodItems, primaryFood: fr.primaryFood }; break;
      }
      case 'update_macros': res = await MealRepository.updateMacros(data.mealId, userId, data); break;
      case 'recent': res = await MealRepository.getRecentMeals(userId, data.limit ?? 10); break;
      default: throw new ValidationError('Nieznana akcja');
    }
    return new Response(JSON.stringify({ success: true, data: res }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) { return handleError(e); }
});
