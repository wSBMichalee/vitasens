import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { ExternalAPIError, NotFoundError } from '../_shared/errorHandler.ts';

export interface RecipeStep {
  number: number;
  instruction: string;
}

export interface RecipeIngredient {
  name: string;
  amount: number;
  unit: string;
}

export interface EstimatedMacros {
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
}

export interface CreateRecipeDTO {
  title: string;
  description?: string;
  cuisineType: string;
  spiceLevel: number;
  difficultyLevel: 'easy' | 'medium' | 'hard';
  prepTimeMinutes: number;
  cookTimeMinutes: number;
  servings: number;
  dietTags: string[];
  mealType: string;
  ingredients: RecipeIngredient[];
  steps: RecipeStep[];
  isPublic: boolean;
  photoUrl?: string;
  estimatedMacros: EstimatedMacros;
}

export interface UserRecipe {
  id: string;
  title: string;
  description?: string;
  cuisineType: string;
  spiceLevel: number;
  difficultyLevel: string;
  prepTimeMinutes: number;
  cookTimeMinutes: number;
  servings: number;
  dietTags: string[];
  mealType: string;
  ingredients: RecipeIngredient[];
  steps: RecipeStep[];
  isPublic: boolean;
  photoUrl?: string;
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
  likesCount: number;
  createdBy: string;
  sourceUrl?: string;
  sourcePlatform?: string;
  createdAt: string;
}

export class UserRecipeRepository {
  static async create(userId: string, data: CreateRecipeDTO): Promise<UserRecipe> {
    try {
      console.log('Creating recipe:', data.title);
      const supabase = getSupabaseAdmin();

      const { data: result, error } = await supabase
        .from('recipes')
        .insert({
          title: data.title,
          description: data.description ?? null,
          cuisine_type: data.cuisineType,
          spice_level: data.spiceLevel,
          difficulty_level: data.difficultyLevel,
          prep_time_minutes: data.prepTimeMinutes,
          cook_time_minutes: data.cookTimeMinutes,
          servings: data.servings,
          diet_tags: data.dietTags,
          meal_type: data.mealType,
          ingredients: data.ingredients,
          steps: data.steps,
          is_public: data.isPublic,
          photo_url: data.photoUrl ?? null,
          protein_g: data.estimatedMacros.proteinG,
          carbs_g: data.estimatedMacros.carbsG,
          fat_g: data.estimatedMacros.fatG,
          calories: data.estimatedMacros.calories,
          source: 'manual',
          source_id: null,
          created_by: userId,
        })
        .select()
        .single();

      if (error || !result) throw new Error(error?.message);
      return this.mapToEntity(result);
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new ExternalAPIError(`Błąd podczas tworzenia przepisu: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  static async update(
    recipeId: string,
    userId: string,
    data: Partial<CreateRecipeDTO>,
  ): Promise<UserRecipe> {
    try {
      console.log('Updating recipe:', recipeId);
      const supabase = getSupabaseAdmin();

      const patch: Record<string, unknown> = {};
      if (data.title !== undefined) patch['title'] = data.title;
      if (data.description !== undefined) patch['description'] = data.description;
      if (data.cuisineType !== undefined) patch['cuisine_type'] = data.cuisineType;
      if (data.spiceLevel !== undefined) patch['spice_level'] = data.spiceLevel;
      if (data.difficultyLevel !== undefined) patch['difficulty_level'] = data.difficultyLevel;
      if (data.prepTimeMinutes !== undefined) patch['prep_time_minutes'] = data.prepTimeMinutes;
      if (data.cookTimeMinutes !== undefined) patch['cook_time_minutes'] = data.cookTimeMinutes;
      if (data.servings !== undefined) patch['servings'] = data.servings;
      if (data.dietTags !== undefined) patch['diet_tags'] = data.dietTags;
      if (data.mealType !== undefined) patch['meal_type'] = data.mealType;
      if (data.ingredients !== undefined) patch['ingredients'] = data.ingredients;
      if (data.steps !== undefined) patch['steps'] = data.steps;
      if (data.isPublic !== undefined) patch['is_public'] = data.isPublic;
      if (data.photoUrl !== undefined) patch['photo_url'] = data.photoUrl;
      if (data.estimatedMacros !== undefined) {
        patch['protein_g'] = data.estimatedMacros.proteinG;
        patch['carbs_g'] = data.estimatedMacros.carbsG;
        patch['fat_g'] = data.estimatedMacros.fatG;
        patch['calories'] = data.estimatedMacros.calories;
      }

      const { data: result, error } = await supabase
        .from('recipes')
        .update(patch)
        .eq('id', recipeId)
        .eq('created_by', userId)
        .select()
        .single();

      if (error || !result) throw new NotFoundError('Nie znaleziono przepisu lub brak uprawnień.');
      return this.mapToEntity(result);
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new ExternalAPIError(`Błąd podczas aktualizacji przepisu: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  static async delete(recipeId: string, userId: string): Promise<void> {
    try {
      console.log('Deleting recipe:', recipeId);
      const supabase = getSupabaseAdmin();

      const { count, error } = await supabase
        .from('recipes')
        .delete({ count: 'exact' })
        .eq('id', recipeId)
        .eq('created_by', userId);

      if (error) throw new Error(error.message);
      if (!count || count === 0) throw new NotFoundError('Nie znaleziono przepisu lub brak uprawnień.');
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new ExternalAPIError(`Błąd podczas usuwania przepisu: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  static async getUserRecipes(userId: string): Promise<UserRecipe[]> {
    try {
      const supabase = getSupabaseAdmin();

      const { data, error } = await supabase
        .from('recipes')
        .select('*')
        .eq('created_by', userId)
        .order('created_at', { ascending: false });

      if (error) throw new Error(error.message);
      return (data ?? []).map((row) => this.mapToEntity(row));
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new ExternalAPIError(`Błąd podczas pobierania przepisów: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  static async uploadPhoto(
    recipeId: string,
    userId: string,
    photoBase64: string,
  ): Promise<string> {
    try {
      console.log('Uploading photo for recipe:', recipeId);
      const supabase = getSupabaseAdmin();

      const { data: existing, error: findError } = await supabase
        .from('recipes')
        .select('id')
        .eq('id', recipeId)
        .eq('created_by', userId)
        .single();

      if (findError || !existing) throw new NotFoundError('Nie znaleziono przepisu lub brak uprawnień.');

      const bytes = Uint8Array.from(atob(photoBase64), (c) => c.charCodeAt(0));
      const path = `${userId}/${recipeId}.jpg`;

      const { error: uploadError } = await supabase.storage
        .from('recipe-photos')
        .upload(path, bytes, { contentType: 'image/jpeg', upsert: true });

      if (uploadError) throw new Error(uploadError.message);

      const { data: urlData } = supabase.storage.from('recipe-photos').getPublicUrl(path);
      const publicUrl = urlData.publicUrl;

      const { error: updateError } = await supabase
        .from('recipes')
        .update({ photo_url: publicUrl })
        .eq('id', recipeId);

      if (updateError) throw new Error(updateError.message);
      return publicUrl;
    } catch (err) {
      if (err instanceof NotFoundError) throw err;
      throw new ExternalAPIError(`Błąd podczas uploadu zdjęcia: ${err instanceof Error ? err.message : String(err)}`);
    }
  }

  static mapToEntity(row: Record<string, unknown>): UserRecipe {
    return {
      id: row['id'] as string,
      title: row['title'] as string,
      description: row['description'] as string | undefined,
      cuisineType: (row['cuisine_type'] as string) ?? 'other',
      spiceLevel: Number(row['spice_level'] ?? 0),
      difficultyLevel: (row['difficulty_level'] as string) ?? 'medium',
      prepTimeMinutes: Number(row['prep_time_minutes'] ?? 0),
      cookTimeMinutes: Number(row['cook_time_minutes'] ?? 0),
      servings: Number(row['servings'] ?? 1),
      dietTags: (row['diet_tags'] as string[]) ?? [],
      mealType: (row['meal_type'] as string) ?? 'dinner',
      ingredients: (row['ingredients'] as RecipeIngredient[]) ?? [],
      steps: (row['steps'] as RecipeStep[]) ?? [],
      isPublic: Boolean(row['is_public']),
      photoUrl: row['photo_url'] as string | undefined,
      proteinG: Number(row['protein_g'] ?? 0),
      carbsG: Number(row['carbs_g'] ?? 0),
      fatG: Number(row['fat_g'] ?? 0),
      calories: Number(row['calories'] ?? 0),
      likesCount: Number(row['likes_count'] ?? 0),
      createdBy: row['created_by'] as string,
      sourceUrl: row['source_url'] as string | undefined,
      sourcePlatform: row['source_platform'] as string | undefined,
      createdAt: row['created_at'] as string,
    };
  }
}
