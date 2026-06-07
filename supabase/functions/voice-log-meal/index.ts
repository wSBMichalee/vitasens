import { serve } from 'https://deno.land/std@0.224.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { SpoonacularClient } from '../search-recipes/SpoonacularClient.ts';
import { SpeechParser } from './SpeechParser.ts';
import { VoiceMealExtractor } from './VoiceMealExtractor.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') ?? '');
    await SubscriptionGuard.checkAccess(userId);

    const { rawText, mealTime, mealDate } = await req.json() as {
      rawText: string;
      mealTime: string;
      mealDate: string;
    };

    if (!rawText) throw new ValidationError('Brak tekstu');

    const parser = new SpeechParser();
    const parsed = parser.parse(rawText);

    if (parsed.confidence < 30) throw new ValidationError('Nie rozumiem - spróbuj ponownie');

    const extractor = new VoiceMealExtractor();
    const result = await extractor.extract(parsed);

    if (result.foodItems.length === 0) throw new ValidationError('Nie wykryto jedzenia');

    const spoonacular = new SpoonacularClient();
    const nutritionData = await Promise.all(
      result.foodItems.map((item) =>
        spoonacular.parseIngredientNutrition(item.name, item.quantity, item.unit)
          .then((n) => ({ name: item.name, ...n }))
      ),
    );

    const logged = await extractor.logToDatabase(result, userId, mealTime, mealDate, nutritionData);

    return new Response(
      JSON.stringify({
        success: true,
        data: {
          logged,
          detectedItems: result.foodItems,
          rawText: parsed.rawText,
          message: `Zapisano: ${logged.foodName}`,
        },
      }),
      { headers: { ...corsHeaders, 'Content-Type': 'application/json' } },
    );
  } catch (e) { return handleError(e); }
});
