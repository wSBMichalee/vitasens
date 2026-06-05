import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { NotFoundError } from '../_shared/errorHandler.ts';

export interface Recipe {
  id: string;
  title: string;
  description?: string;
  source: 'spoonacular' | 'manual';
  sourceId?: string;
  ingredients: RecipeIngredient[];
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
  cookTimeMinutes?: number;
  servings: number;
  imageUrl?: string;
  createdAt: string;
}

export interface RecipeIngredient {
  name: string;
  amount: number;
  unit: string;
}

export interface UpsertRecipeDTO {
  title: string;
  source: 'spoonacular' | 'manual';
  sourceId?: string;
  ingredients: RecipeIngredient[];
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
  cookTimeMinutes?: number;
  servings: number;
  imageUrl?: string;
  description?: string;
}

export class RecipeRepository {
  static async upsert(data: UpsertRecipeDTO): Promise<Recipe> {
    console.log('Upserting recipe:', data.title);
    const supabase = getSupabaseAdmin();
    
    const { data: result, error } = await supabase
      .from('recipes')
      .upsert({
        title: data.title,
        source: data.source,
        source_id: data.sourceId,
        ingredients: data.ingredients,
        protein_g: data.proteinG,
        carbs_g: data.carbsG,
        fat_g: data.fatG,
        calories: data.calories,
        cook_time_minutes: data.cookTimeMinutes,
        servings: data.servings,
        image_url: data.imageUrl,
        description: data.description
      }, {
        onConflict: 'source,source_id'
      })
      .select()
      .single();

    if (error || !result) throw new Error(`Failed to upsert recipe: ${error?.message}`);
    return this.mapToEntity(result);
  }

  static async upsertMany(recipes: UpsertRecipeDTO[]): Promise<Recipe[]> {
    console.log('Upserting', recipes.length, 'recipes');
    return Promise.all(recipes.map(r => this.upsert(r)));
  }

  static async findById(recipeId: string): Promise<Recipe> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('recipes')
      .select('*')
      .eq('id', recipeId)
      .single();

    if (error || !data) throw new NotFoundError('Nie znaleziono przepisu.');
    return this.mapToEntity(data);
  }

  static async findBySourceId(source: string, sourceId: string): Promise<Recipe | null> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('recipes')
      .select('*')
      .eq('source', source)
      .eq('source_id', sourceId)
      .maybeSingle();

    if (error || !data) return null;
    return this.mapToEntity(data);
  }

  static async addToFavorites(userId: string, recipeId: string): Promise<void> {
    console.log('Adding to favorites:', recipeId);
    const supabase = getSupabaseAdmin();
    const { error } = await supabase
      .from('favorite_recipes')
      .upsert({ user_id: userId, recipe_id: recipeId }, { onConflict: 'user_id,recipe_id' });

    if (error) throw new Error(`Failed to add favorite: ${error.message}`);
  }

  static async removeFromFavorites(userId: string, recipeId: string): Promise<void> {
    console.log('Removing from favorites:', recipeId);
    const supabase = getSupabaseAdmin();
    const { error } = await supabase
      .from('favorite_recipes')
      .delete()
      .eq('user_id', userId)
      .eq('recipe_id', recipeId);

    if (error) throw new Error(`Failed to remove favorite: ${error.message}`);
  }

  static async getFavorites(userId: string): Promise<Recipe[]> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('favorite_recipes')
      .select('recipes (*)')
      .eq('user_id', userId)
      .order('saved_at', { ascending: false });

    if (error) throw new Error(`Failed to get favorites: ${error.message}`);
    return (data || []).map((row: any) => this.mapToEntity(row.recipes));
  }

  static async isFavorite(userId: string, recipeId: string): Promise<boolean> {
    const supabase = getSupabaseAdmin();
    const { count, error } = await supabase
      .from('favorite_recipes')
      .select('*', { count: 'exact', head: true })
      .eq('user_id', userId)
      .eq('recipe_id', recipeId);

    if (error) throw new Error(`Failed to check favorite status: ${error.message}`);
    return (count || 0) > 0;
  }

  private static mapToEntity(row: any): Recipe {
    return {
      id: row.id,
      title: row.title,
      description: row.description,
      source: row.source,
      sourceId: row.source_id,
      ingredients: row.ingredients,
      proteinG: Number(row.protein_g),
      carbsG: Number(row.carbs_g),
      fatG: Number(row.fat_g),
      calories: Number(row.calories),
      cookTimeMinutes: row.cook_time_minutes,
      servings: row.servings,
      imageUrl: row.image_url,
      createdAt: row.created_at
    };
  }
}
