import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { NotFoundError, ExternalAPIError } from '../_shared/errorHandler.ts';

export interface SaveDetectedMealDTO {
  userId: string;
  mealDate: string;
  mealTime: 'breakfast' | 'lunch' | 'dinner' | 'snack';
  foodName: string;
  photoUrl?: string;
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
  confidence: number;
  detectedFoods: string[];
}

export interface SavedMeal {
  id: string;
  userId: string;
  mealDate: string;
  mealTime: string;
  foodName: string;
  photoUrl?: string;
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
  source: 'ai_detection';
  confidence: number;
  createdAt: string;
}

export interface PhotoUploadResult {
  path: string;
  publicUrl: string;
}

export class MealRepository {
  static async saveDetectedMeal(data: SaveDetectedMealDTO): Promise<SavedMeal> {
    console.log('Saving detected meal:', data.foodName);
    const supabase = getSupabaseAdmin();
    
    const { data: result, error } = await supabase
      .from('meals')
      .insert({
        user_id: data.userId,
        meal_date: data.mealDate,
        meal_time: data.mealTime,
        food_name: data.foodName,
        photo_url: data.photoUrl,
        protein_g: data.proteinG,
        carbs_g: data.carbsG,
        fat_g: data.fatG,
        calories: data.calories,
        source: 'ai_detection',
        confidence: data.confidence
      })
      .select()
      .single();

    if (error || !result) throw new Error(`Failed to save meal: ${error?.message}`);
    return this.mapToEntity(result);
  }

  static async uploadPhoto(
    userId: string,
    photoBase64: string,
    mealTime: string
  ): Promise<PhotoUploadResult> {
    console.log('Uploading meal photo for:', userId);
    const supabase = getSupabaseAdmin();
    
    // atob is available in Deno
    const binaryString = atob(photoBase64);
    const bytes = Uint8Array.from(binaryString, c => c.charCodeAt(0));
    
    const fileName = `${userId}/${mealTime}_${Date.now()}.jpg`;
    
    const { data, error } = await supabase.storage
      .from('meal-photos')
      .upload(fileName, bytes, {
        contentType: 'image/jpeg',
        upsert: false
      });

    if (error) {
      throw new ExternalAPIError(`Failed to upload photo: ${error.message}`);
    }

    const { data: { publicUrl } } = supabase.storage
      .from('meal-photos')
      .getPublicUrl(fileName);

    return {
      path: data.path,
      publicUrl: publicUrl
    };
  }

  static async getRecentMeals(userId: string, limit: number = 10): Promise<SavedMeal[]> {
    const supabase = getSupabaseAdmin();
    const { data, error } = await supabase
      .from('meals')
      .select('*')
      .eq('user_id', userId)
      .eq('source', 'ai_detection')
      .order('created_at', { ascending: false })
      .limit(limit);

    if (error) throw new Error(`Failed to get recent meals: ${error.message}`);
    return (data || []).map(this.mapToEntity);
  }

  static async updateMacros(
    mealId: string,
    userId: string,
    data: {
      proteinG?: number;
      carbsG?: number;
      fatG?: number;
      calories?: number;
      foodName?: string;
    }
  ): Promise<SavedMeal> {
    console.log('Updating meal macros:', mealId);
    const supabase = getSupabaseAdmin();
    
    const updatePayload: Record<string, any> = {
      updated_at: new Date().toISOString()
    };
    
    if (data.proteinG !== undefined) updatePayload.protein_g = data.proteinG;
    if (data.carbsG !== undefined) updatePayload.carbs_g = data.carbsG;
    if (data.fatG !== undefined) updatePayload.fat_g = data.fatG;
    if (data.calories !== undefined) updatePayload.calories = data.calories;
    if (data.foodName !== undefined) updatePayload.food_name = data.foodName;

    const { data: result, error } = await supabase
      .from('meals')
      .update(updatePayload)
      .eq('id', mealId)
      .eq('user_id', userId)
      .select()
      .single();

    if (error || !result) throw new NotFoundError('Nie znaleziono posiłku do aktualizacji.');
    return this.mapToEntity(result);
  }

  private static mapToEntity(row: any): SavedMeal {
    return {
      id: row.id,
      userId: row.user_id,
      mealDate: row.meal_date,
      mealTime: row.meal_time,
      foodName: row.food_name,
      photoUrl: row.photo_url,
      proteinG: Number(row.protein_g),
      carbsG: Number(row.carbs_g),
      fatG: Number(row.fat_g),
      calories: Number(row.calories),
      source: row.source,
      confidence: row.confidence,
      createdAt: row.created_at
    };
  }
}
