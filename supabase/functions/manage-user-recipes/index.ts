import { serve } from 'https://deno.land/std@0.177.0/http/server.ts';
import { corsHeaders } from '../_shared/corsHeaders.ts';
import { handleError, ValidationError } from '../_shared/errorHandler.ts';
import { getUserId } from '../_shared/supabaseClient.ts';
import { SubscriptionGuard } from '../_shared/SubscriptionGuard.ts';
import { CreateRecipeSchema } from '../_shared/validators.ts';
import { UserRecipeRepository } from './UserRecipeRepository.ts';
import { RecipePublisher } from './RecipePublisher.ts';
import { RecipeLikes } from './RecipeLikes.ts';

serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: corsHeaders });
  try {
    const userId = await getUserId(req.headers.get('Authorization') ?? '');
    await SubscriptionGuard.checkAccess(userId);
    const { action, ...data } = await req.json() as { action: string; [key: string]: unknown };
    let res: unknown;
    switch (action) {
      case 'create':       res = await UserRecipeRepository.create(userId, CreateRecipeSchema.parse(data)); break;
      case 'update':       res = await UserRecipeRepository.update(data['recipeId'] as string, userId, data); break;
      case 'delete':       await UserRecipeRepository.delete(data['recipeId'] as string, userId); res = { deleted: true }; break;
      case 'my_recipes':   res = await UserRecipeRepository.getUserRecipes(userId); break;
      case 'upload_photo': res = { photoUrl: await UserRecipeRepository.uploadPhoto(data['recipeId'] as string, userId, data['photoBase64'] as string) }; break;
      case 'publish':      res = await RecipePublisher.publish(data['recipeId'] as string, userId); break;
      case 'unpublish':    res = await RecipePublisher.unpublish(data['recipeId'] as string, userId); break;
      case 'public_by_user': res = await RecipePublisher.getPublicRecipesByUser((data['userId'] as string | undefined) ?? userId); break;
      case 'stats':        res = await RecipePublisher.getRecipeStats(data['recipeId'] as string); break;
      case 'like':         await RecipeLikes.like(data['recipeId'] as string, userId); res = { liked: true }; break;
      case 'unlike':       await RecipeLikes.unlike(data['recipeId'] as string, userId); res = { unliked: true }; break;
      case 'is_liked':     res = { isLiked: await RecipeLikes.isLiked(data['recipeId'] as string, userId) }; break;
      case 'liked_recipes': res = await RecipeLikes.getLikedRecipes(userId); break;
      case 'who_liked':    res = await RecipeLikes.getWhoLiked(data['recipeId'] as string, (data['limit'] as number | undefined) ?? 10); break;
      default: throw new ValidationError('Nieznana akcja');
    }
    return new Response(JSON.stringify({ success: true, data: res }), { headers: { ...corsHeaders, 'Content-Type': 'application/json' } });
  } catch (e) { return handleError(e); }
});
