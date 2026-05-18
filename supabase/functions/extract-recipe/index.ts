import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { HealthPromptBuilder, HealthCondition } from '../_shared/HealthPromptBuilder.ts';
import { ProfileRepository } from '../calculate-daily-macros/ProfileRepository.ts';
import { UrlValidator } from './UrlValidator.ts';
import { TranscriptFetcher } from './TranscriptFetcher.ts';
import { RecipeExtractor } from './RecipeExtractor.ts';
import { RecipeParser } from './RecipeParser.ts';
import { RecipeRepository } from '../search-recipes/RecipeRepository.ts';
import { PantryRepository } from '../manage-pantry/PantryRepository.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') ?? '');
    await SubscriptionGuard.checkAccess(userId);

    const { url } = await req.json() as { url: string };
    if (!url) throw new ValidationError('Brak URL.');

    const profile = await ProfileRepository.getById(userId);

    const validator = new UrlValidator();
    const platform = validator.validate(url);
    const videoId = validator.extractVideoId(url, platform);
    const transcript = await new TranscriptFetcher().fetch(url, platform, videoId);

    const { recipe: extracted, warnings: extractionWarnings } = await new RecipeExtractor().extract(
      transcript.text,
      url,
      platform,
      {
        conditions: (profile.healthConditions ?? []) as HealthCondition[],
        goalType: profile.goalType,
        dailyProteinTarget: profile.dailyProteinTarget,
        dailyCarbsTarget: profile.dailyCarbsTarget,
        dailyFatTarget: profile.dailyFatTarget,
      },
    );

    const parser = new RecipeParser();
    const parsed = parser.parse(extracted);
    const saved = await RecipeRepository.upsert(parser.toRecipeDTO(parsed));
    const pantryId = await PantryRepository.getPantryIdForUser(userId);
    const pantryNames = (await PantryRepository.list(pantryId)).map((i) => i.name);
    const comparison = parser.compareWithPantry(parsed.ingredients, pantryNames);

    const builder = new HealthPromptBuilder();
    const conditionWarnings = (profile.healthConditions ?? [] as HealthCondition[])
      .flatMap((c) => builder.getWarningsForCondition(c as HealthCondition));
    const healthWarnings = [...new Set([...extractionWarnings, ...conditionWarnings])];

    return new Response(JSON.stringify({
      success: true,
      data: {
        recipe: saved,
        extracted: {
          title: parsed.title, cookTimeMinutes: parsed.cookTimeMinutes,
          servings: parsed.servings, steps: parsed.steps,
          estimatedMacros: parsed.estimatedMacros,
          sourceUrl: parsed.sourceUrl, sourcePlatform: parsed.sourcePlatform,
        },
        pantryComparison: comparison,
        healthWarnings,
      },
    }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) { return handleError(e); }
});
