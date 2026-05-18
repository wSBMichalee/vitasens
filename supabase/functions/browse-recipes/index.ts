import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { HealthPromptBuilder, HealthCondition } from '../_shared/HealthPromptBuilder.ts';
import { ProfileRepository } from '../calculate-daily-macros/ProfileRepository.ts';
import { RecipeFiltersSchema } from '../_shared/validators.ts';
import { RecipeBrowser } from './RecipeBrowser.ts';
import { RecipeFilters } from './RecipeFilters.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const { action, ...data } = await req.json() as { action: string; [key: string]: unknown };
    const browser = new RecipeBrowser();
    let res: unknown;

    if (action === 'cuisines') {
      res = RecipeFilters.getCuisineOptions();
    } else if (action === 'diet_tags') {
      res = RecipeFilters.getDietTagOptions();
    } else {
      const userId = await getUserId(req.headers.get('Authorization') ?? '');
      await SubscriptionGuard.checkAccess(userId);
      switch (action) {
        case 'browse': {
          const result = await browser.browse(RecipeFiltersSchema.parse(data));
          const profile = await ProfileRepository.getById(userId);
          const builder = new HealthPromptBuilder();
          const conditions = (profile.healthConditions ?? []) as HealthCondition[];
          const forbidden = builder.getForbiddenIngredients(conditions);
          const warnings = conditions.flatMap((c) => builder.getWarningsForCondition(c));
          const filteredRecipes = forbidden.length === 0
            ? result.recipes
            : result.recipes.filter((recipe) => {
              const names = (recipe.ingredients as Array<{ name: string }>)
                .map((i) => i.name.toLowerCase());
              return !forbidden.some((f) => names.some((n) => n.includes(f.toLowerCase())));
            });
          res = { ...result, recipes: filteredRecipes, filteredOut: result.recipes.length - filteredRecipes.length, healthWarnings: warnings };
          break;
        }
        case 'details':   res = await browser.getById(data['recipeId'] as string, userId); break;
        case 'featured':  res = await browser.getFeatured((data['limit'] as number | undefined) ?? 10); break;
        case 'by_author': res = await browser.getByAuthor(data['authorId'] as string, (data['limit'] as number | undefined) ?? 20); break;
        case 'search':
          if (!data['query']) throw new ValidationError('Brak query');
          res = await browser.search(data['query'] as string, (data['limit'] as number | undefined) ?? 20);
          break;
        case 'similar':   res = await browser.getSimilar(data['recipeId'] as string, (data['limit'] as number | undefined) ?? 5); break;
        default: throw new ValidationError('Nieznana akcja');
      }
    }

    return new Response(JSON.stringify({ success: true, data: res }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) { return handleError(e); }
});
