import { serve } from "https://deno.land/std@0.177.0/http/server.ts";
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId, createServiceClient } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { VisionClient } from './VisionClient.ts';
import { FoodFilter } from './FoodFilter.ts';
import { NutritionEstimator } from './NutritionEstimator.ts';
import { MealRepository } from './MealRepository.ts';

// ─── STAŁE ────────────────────────────────────────────────────────────────────
const FREE_PLAN_DAILY_LIMIT = 10;
const CACHE_TTL_DAYS = 30;

// ─── HELPERS ──────────────────────────────────────────────────────────────────

/** MD5-like hash (SHA-256 skrócony) z base64 zdjęcia */
async function hashImage(photoBase64: string): Promise<string> {
  const data = new TextEncoder().encode(photoBase64.slice(0, 2000)); // pierwsze 2KB wystarczą
  const hashBuffer = await crypto.subtle.digest('SHA-256', data);
  const hashArray = Array.from(new Uint8Array(hashBuffer));
  return hashArray.map(b => b.toString(16).padStart(2, '0')).join('').slice(0, 32);
}

/** Sprawdza limit dzienny użytkownika. Rzuca błąd jeśli limit wyczerpany. */
async function checkRateLimit(userId: string, isPro: boolean): Promise<void> {
  if (isPro) return; // Pro = unlimited

  const supabase = createServiceClient();
  const since = new Date(Date.now() - 24 * 60 * 60 * 1000).toISOString();
  const { count } = await supabase
    .from('daily_usage')
    .select('*', { count: 'exact', head: true })
    .eq('user_id', userId)
    .eq('function_name', 'detect-food')
    .gte('created_at', since);

  if ((count ?? 0) >= FREE_PLAN_DAILY_LIMIT) {
    throw new ValidationError(
      `Dzienny limit skanowania (${FREE_PLAN_DAILY_LIMIT}) wyczerpany. Ulepsz plan aby skanować bez ograniczeń.`
    );
  }
}

/** Zapisuje użycie do tabeli rate limitingu */
async function recordUsage(userId: string): Promise<void> {
  const supabase = createServiceClient();
  await supabase.from('daily_usage').insert({ user_id: userId, function_name: 'detect-food' });
}

/** Szuka wyniku w cache. Zwraca null jeśli brak lub wygasł. */
async function getCachedResult(imageHash: string): Promise<Record<string, unknown> | null> {
  const supabase = createServiceClient();
  const since = new Date(Date.now() - CACHE_TTL_DAYS * 24 * 60 * 60 * 1000).toISOString();
  const { data } = await supabase
    .from('food_detection_cache')
    .select('result')
    .eq('image_hash', imageHash)
    .gte('created_at', since)
    .maybeSingle();
  return data?.result ?? null;
}

/** Zapisuje wynik Vision API do cache */
async function saveToCache(imageHash: string, result: unknown): Promise<void> {
  const supabase = createServiceClient();
  await supabase
    .from('food_detection_cache')
    .upsert({ image_hash: imageHash, result }, { onConflict: 'image_hash' });
}

// ─── HANDLER ──────────────────────────────────────────────────────────────────

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') || '');
    const subscriptionData = await SubscriptionGuard.checkAccess(userId);
    const isPro = subscriptionData?.status === 'active';
    const { action, ...data } = await req.json();
    let res;

    switch (action) {
      case 'detect': {
        // 1. Rate limiting
        await checkRateLimit(userId, isPro);

        // 2. Cache lookup — unikamy płatnego Vision API
        const imageHash = await hashImage(data.photoBase64);
        const cached = await getCachedResult(imageHash);

        let visionResult: { labels: Array<{ description: string; score: number }> };
        let fromCache = false;

        if (cached) {
          // Cache HIT — nie płacimy za Vision API
          visionResult = cached as typeof visionResult;
          fromCache = true;
        } else {
          // Cache MISS — wywołujemy Vision API i zapisujemy wynik
          visionResult = await new VisionClient().detectLabels(data.photoBase64);
          await saveToCache(imageHash, visionResult);
        }

        // 3. Przetwarzanie wyników (bez zmian w logice)
        const up = await MealRepository.uploadPhoto(userId, data.photoBase64, data.mealTime);
        const items = FoodFilter.extractFoodLabels(visionResult.labels);
        const fr = FoodFilter.getFilterResult(items);
        const nutr = await new NutritionEstimator().estimateForMeal(items);
        const meal = await MealRepository.saveDetectedMeal({
          userId, mealDate: data.mealDate, mealTime: data.mealTime, foodName: fr.allFoodsLabel, photoUrl: up.publicUrl,
          proteinG: nutr.totalProteinG, carbsG: nutr.totalCarbsG, fatG: nutr.totalFatG, calories: nutr.totalCalories,
          confidence: fr.averageConfidence, detectedFoods: nutr.detectedFoods
        });

        // 4. Zapisz użycie (tylko przy rzeczywistym wykryciu)
        await recordUsage(userId);

        res = { meal, detectedFoods: fr.foodItems, primaryFood: fr.primaryFood, fromCache };
        break;
      }
      case 'update_macros': res = await MealRepository.updateMacros(data.mealId, userId, data); break;
      case 'recent': res = await MealRepository.getRecentMeals(userId, data.limit ?? 10); break;
      default: throw new ValidationError('Nieznana akcja');
    }
    return new Response(JSON.stringify({ success: true, data: res }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) { return handleError(e); }
});
