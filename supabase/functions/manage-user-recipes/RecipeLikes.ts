import { UserRecipe, UserRecipeRepository } from './UserRecipeRepository.ts';
import { NotFoundError } from '../_shared/errorHandler.ts';
import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';

export class RecipeLikes {
  static async like(recipeId: string, userId: string): Promise<void> {
    try {
      console.log('Liking recipe:', recipeId);
      const supabase = getSupabaseAdmin();

      const { error } = await supabase
        .from('recipe_likes')
        .upsert(
          { recipe_id: recipeId, user_id: userId },
          { onConflict: 'recipe_id,user_id', ignoreDuplicates: true },
        );

      if (error) throw new Error(error.message);
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas polubienia przepisu: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  static async unlike(recipeId: string, userId: string): Promise<void> {
    try {
      console.log('Unliking recipe:', recipeId);
      const supabase = getSupabaseAdmin();

      const { error } = await supabase
        .from('recipe_likes')
        .delete()
        .eq('recipe_id', recipeId)
        .eq('user_id', userId);

      if (error) throw new Error(error.message);
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas cofania polubienia: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  static async isLiked(recipeId: string, userId: string): Promise<boolean> {
    try {
      const supabase = getSupabaseAdmin();

      const { count, error } = await supabase
        .from('recipe_likes')
        .select('*', { count: 'exact', head: true })
        .eq('recipe_id', recipeId)
        .eq('user_id', userId);

      if (error) throw new Error(error.message);
      return (count ?? 0) > 0;
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas sprawdzania polubienia: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  static async getLikedRecipes(userId: string): Promise<UserRecipe[]> {
    try {
      const supabase = getSupabaseAdmin();

      const { data: likes, error: likesError } = await supabase
        .from('recipe_likes')
        .select('recipe_id')
        .eq('user_id', userId)
        .order('created_at', { ascending: false });

      if (likesError) throw new Error(likesError.message);
      if (!likes || likes.length === 0) return [];

      const recipeIds = likes.map((l) => l['recipe_id'] as string);

      const { data, error } = await supabase
        .from('recipes')
        .select('*')
        .in('id', recipeIds)
        .eq('is_public', true);

      if (error) throw new Error(error.message);
      return (data ?? []).map((row) =>
        UserRecipeRepository.mapToEntity(row as Record<string, unknown>)
      );
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas pobierania polubionych przepisów: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  static async getLikesCount(recipeId: string): Promise<number> {
    try {
      const supabase = getSupabaseAdmin();

      const { data, error } = await supabase
        .from('recipes')
        .select('likes_count')
        .eq('id', recipeId)
        .single();

      if (error || !data) throw new NotFoundError('Nie znaleziono przepisu.');
      return Number(data['likes_count'] ?? 0);
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas pobierania liczby polubień: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  static async getWhoLiked(
    recipeId: string,
    limit = 10,
  ): Promise<Array<{ userId: string; name: string }>> {
    try {
      const supabase = getSupabaseAdmin();

      const { data: likes, error: likesError } = await supabase
        .from('recipe_likes')
        .select('user_id')
        .eq('recipe_id', recipeId)
        .order('created_at', { ascending: false })
        .limit(limit);

      if (likesError) throw new Error(likesError.message);
      if (!likes || likes.length === 0) return [];

      const userIds = likes.map((l) => l['user_id'] as string);

      const { data: profiles, error: profilesError } = await supabase
        .from('profiles')
        .select('id, name')
        .in('id', userIds);

      if (profilesError) throw new Error(profilesError.message);

      return (profiles ?? []).map((p) => ({
        userId: p['id'] as string,
        name: p['name'] as string,
      }));
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas pobierania listy polubień: ${err instanceof Error ? err.message : String(err)}`);
    }
  }
}
