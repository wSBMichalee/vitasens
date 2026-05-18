import { UserRecipe, UserRecipeRepository } from '../manage-user-recipes/UserRecipeRepository.ts';
import { RecipeFilters } from './RecipeFilters.ts';
import { NotFoundError } from '../_shared/errorHandler.ts';
import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';

type FiltersType = RecipeFilters;

export interface BrowseResult {
  recipes: UserRecipe[];
  total: number;
  hasMore: boolean;
  offset: number;
  limit: number;
}

export interface AuthorProfile {
  id: string;
  name: string;
  avatarUrl?: string;
  recipesCount: number;
  totalLikes: number;
}

export class RecipeBrowser {
  private filters: RecipeFilters;

  constructor() {
    this.filters = new RecipeFilters();
  }

  async browse(rawFilters: FiltersType): Promise<BrowseResult> {
    try {
      console.log('Browsing recipes, filters:', rawFilters);
      const f = RecipeFilters.validateFilters(rawFilters);
      const supabase = getSupabaseAdmin();
      const limit = f.limit ?? 20;
      const offset = f.offset ?? 0;

      let dataQ = supabase.from('recipes').select('*').eq('is_public', true);
      let countQ = supabase.from('recipes').select('*', { count: 'exact', head: true }).eq('is_public', true);

      if (f.cuisineType) { dataQ = dataQ.eq('cuisine_type', f.cuisineType); countQ = countQ.eq('cuisine_type', f.cuisineType); }
      if (f.spiceLevel !== undefined) { dataQ = dataQ.eq('spice_level', f.spiceLevel); countQ = countQ.eq('spice_level', f.spiceLevel); }
      if (f.difficultyLevel) { dataQ = dataQ.eq('difficulty_level', f.difficultyLevel); countQ = countQ.eq('difficulty_level', f.difficultyLevel); }
      if (f.maxPrepTime !== undefined) { dataQ = dataQ.lte('prep_time_minutes', f.maxPrepTime); countQ = countQ.lte('prep_time_minutes', f.maxPrepTime); }
      if (f.mealType) { dataQ = dataQ.eq('meal_type', f.mealType); countQ = countQ.eq('meal_type', f.mealType); }
      if (f.maxCalories !== undefined) { dataQ = dataQ.lte('calories', f.maxCalories); countQ = countQ.lte('calories', f.maxCalories); }
      if (f.minProtein !== undefined) { dataQ = dataQ.gte('protein_g', f.minProtein); countQ = countQ.gte('protein_g', f.minProtein); }
      if (f.searchQuery) { dataQ = dataQ.ilike('title', `%${f.searchQuery}%`); countQ = countQ.ilike('title', `%${f.searchQuery}%`); }
      if (f.dietTags?.length) { dataQ = dataQ.contains('diet_tags', [f.dietTags[0]]); countQ = countQ.contains('diet_tags', [f.dietTags[0]]); }

      const orderCol = f.sortBy === 'most_liked' ? 'likes_count' : f.sortBy === 'quickest' ? 'prep_time_minutes' : f.sortBy === 'highest_protein' ? 'protein_g' : 'created_at';
      dataQ = dataQ.order(orderCol, { ascending: f.sortBy === 'quickest' }).range(offset, offset + limit - 1);

      const [{ data, error }, { count, error: countError }] = await Promise.all([dataQ, countQ]);
      if (error) throw new Error(error.message);
      if (countError) throw new Error(countError.message);

      const recipes = (data ?? []).map((row: Record<string, unknown>) => UserRecipeRepository.mapToEntity(row));
      const total = count ?? 0;
      return { recipes, total, hasMore: offset + recipes.length < total, offset, limit };
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas przeglądania przepisów: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  async getById(recipeId: string, userId?: string): Promise<UserRecipe & { isLiked: boolean }> {
    try {
      const supabase = getSupabaseAdmin();
      const { data, error } = await supabase.from('recipes').select('*').eq('id', recipeId).eq('is_public', true).single();
      if (error || !data) throw new NotFoundError('Przepis nie istnieje lub jest prywatny.');
      const recipe = UserRecipeRepository.mapToEntity(data as Record<string, unknown>);
      let isLiked = false;
      if (userId) {
        const { count } = await supabase.from('recipe_likes').select('*', { count: 'exact', head: true }).eq('recipe_id', recipeId).eq('user_id', userId);
        isLiked = (count ?? 0) > 0;
      }
      return { ...recipe, isLiked };
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas pobierania przepisu: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  async getFeatured(limit = 10): Promise<UserRecipe[]> {
    try {
      console.log('Getting featured recipes, limit:', limit);
      const supabase = getSupabaseAdmin();
      const { data, error } = await supabase.from('recipes').select('*').eq('is_public', true).order('likes_count', { ascending: false }).limit(limit);
      if (error) throw new Error(error.message);
      return (data ?? []).map((row: Record<string, unknown>) => UserRecipeRepository.mapToEntity(row));
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas pobierania polecanych: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  async getByAuthor(authorId: string, limit = 20): Promise<{ recipes: UserRecipe[]; author: AuthorProfile }> {
    try {
      const supabase = getSupabaseAdmin();
      const [recipesResult, profileResult] = await Promise.all([
        supabase.from('recipes').select('*').eq('created_by', authorId).eq('is_public', true).order('created_at', { ascending: false }).limit(limit),
        supabase.from('profiles').select('id, name, avatar_url').eq('id', authorId).single(),
      ]);
      if (profileResult.error || !profileResult.data) throw new NotFoundError('Nie znaleziono autora.');
      if (recipesResult.error) throw new Error(recipesResult.error.message);

      const recipes = (recipesResult.data ?? []).map((row: Record<string, unknown>) => UserRecipeRepository.mapToEntity(row));
      const { count: totalCount } = await supabase.from('recipes').select('*', { count: 'exact', head: true }).eq('created_by', authorId).eq('is_public', true);
      const p = profileResult.data as Record<string, unknown>;

      return {
        recipes,
        author: {
          id: p['id'] as string,
          name: p['name'] as string,
          avatarUrl: p['avatar_url'] as string | undefined,
          recipesCount: totalCount ?? recipes.length,
          totalLikes: recipes.reduce((sum, r) => sum + r.likesCount, 0),
        },
      };
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas pobierania przepisów autora: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  async search(query: string, limit = 20): Promise<UserRecipe[]> {
    try {
      console.log('Searching recipes:', query);
      const supabase = getSupabaseAdmin();
      const { data, error } = await supabase.from('recipes').select('*').eq('is_public', true).or(`title.ilike.%${query}%,description.ilike.%${query}%`).order('likes_count', { ascending: false }).limit(limit);
      if (error) throw new Error(error.message);
      return (data ?? []).map((row: Record<string, unknown>) => UserRecipeRepository.mapToEntity(row));
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas wyszukiwania: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  async getSimilar(recipeId: string, limit = 5): Promise<UserRecipe[]> {
    try {
      const supabase = getSupabaseAdmin();
      const { data: src, error: srcErr } = await supabase.from('recipes').select('cuisine_type, meal_type').eq('id', recipeId).single();
      if (srcErr || !src) throw new NotFoundError('Nie znaleziono przepisu.');
      const cuisine = (src as Record<string, unknown>)['cuisine_type'] as string;
      const mealType = (src as Record<string, unknown>)['meal_type'] as string;
      const { data, error } = await supabase.from('recipes').select('*').eq('is_public', true).neq('id', recipeId).or(`cuisine_type.eq.${cuisine},meal_type.eq.${mealType}`).order('likes_count', { ascending: false }).limit(limit);
      if (error) throw new Error(error.message);
      return (data ?? []).map((row: Record<string, unknown>) => UserRecipeRepository.mapToEntity(row));
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new NotFoundError(`Błąd podczas pobierania podobnych: ${err instanceof Error ? err.message : String(err)}`);
    }
  }
}
