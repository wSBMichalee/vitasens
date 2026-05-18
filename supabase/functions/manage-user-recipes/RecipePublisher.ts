import { UserRecipe, UserRecipeRepository } from './UserRecipeRepository.ts';
import { NotFoundError, ValidationError } from '../_shared/errorHandler.ts';
import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';

export class RecipePublisher {
  static async publish(recipeId: string, userId: string): Promise<UserRecipe> {
    try {
      console.log('Publishing recipe:', recipeId);
      const supabase = getSupabaseAdmin();

      const { data: row, error: findError } = await supabase
        .from('recipes')
        .select('*')
        .eq('id', recipeId)
        .eq('created_by', userId)
        .single();

      if (findError || !row) throw new NotFoundError('Nie znaleziono przepisu lub brak uprawnień.');

      const recipe = UserRecipeRepository.mapToEntity(row as Record<string, unknown>);

      if (!recipe.title || recipe.title.length < 3) {
        throw new ValidationError('Przepis musi mieć tytuł.');
      }
      if (recipe.ingredients.length < 3) {
        throw new ValidationError('Przepis musi mieć minimum 3 składniki.');
      }
      if (recipe.steps.length < 2) {
        throw new ValidationError('Przepis musi mieć minimum 2 kroki.');
      }

      const { data: updated, error: updateError } = await supabase
        .from('recipes')
        .update({ is_public: true })
        .eq('id', recipeId)
        .eq('created_by', userId)
        .select()
        .single();

      if (updateError || !updated) throw new NotFoundError('Nie znaleziono przepisu lub brak uprawnień.');
      return UserRecipeRepository.mapToEntity(updated as Record<string, unknown>);
    } catch (err) {
      if (err instanceof NotFoundError || err instanceof ValidationError) throw err;
      throw new NotFoundError('Błąd podczas publikowania przepisu.');
    }
  }

  static async unpublish(recipeId: string, userId: string): Promise<UserRecipe> {
    try {
      console.log('Unpublishing recipe:', recipeId);
      const supabase = getSupabaseAdmin();

      const { data: updated, error } = await supabase
        .from('recipes')
        .update({ is_public: false })
        .eq('id', recipeId)
        .eq('created_by', userId)
        .select()
        .single();

      if (error || !updated) throw new NotFoundError('Nie znaleziono przepisu lub brak uprawnień.');
      return UserRecipeRepository.mapToEntity(updated as Record<string, unknown>);
    } catch (err) {
      if (err instanceof NotFoundError || err instanceof ValidationError) throw err;
      throw new NotFoundError('Błąd podczas cofania publikacji przepisu.');
    }
  }

  static async getPublicRecipesByUser(userId: string): Promise<UserRecipe[]> {
    try {
      const supabase = getSupabaseAdmin();

      const { data, error } = await supabase
        .from('recipes')
        .select('*')
        .eq('created_by', userId)
        .eq('is_public', true)
        .order('likes_count', { ascending: false });

      if (error) throw new Error(error.message);
      return (data ?? []).map((row) =>
        UserRecipeRepository.mapToEntity(row as Record<string, unknown>)
      );
    } catch (err) {
      if (err instanceof NotFoundError || err instanceof ValidationError) throw err;
      throw new NotFoundError('Błąd podczas pobierania publicznych przepisów.');
    }
  }

  static async getRecipeStats(
    recipeId: string,
  ): Promise<{ likesCount: number; isPublic: boolean; createdAt: string }> {
    try {
      const supabase = getSupabaseAdmin();

      const { data, error } = await supabase
        .from('recipes')
        .select('likes_count, is_public, created_at')
        .eq('id', recipeId)
        .single();

      if (error || !data) throw new NotFoundError('Nie znaleziono przepisu.');

      return {
        likesCount: Number(data['likes_count'] ?? 0),
        isPublic: Boolean(data['is_public']),
        createdAt: data['created_at'] as string,
      };
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError('Błąd podczas pobierania statystyk przepisu.');
    }
  }
}
