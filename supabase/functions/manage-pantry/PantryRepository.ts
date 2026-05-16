import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { NotFoundError } from '../_shared/errorHandler.ts';

export interface Ingredient {
  id: string;
  pantryId: string;
  name: string;
  quantity: number;
  unit: string;
  category: string;
  minimumQuantity: number;
  expiryDate: string | null;
  addedBy: string | null;
  createdAt: string;
  updatedAt: string;
}

export interface AddIngredientDTO {
  pantryId: string;
  name: string;
  quantity: number;
  unit: string;
  category: string;
  minimumQuantity?: number;
  expiryDate?: string;
}

export interface UpdateIngredientDTO {
  id: string;
  quantity?: number;
  unit?: string;
  minimumQuantity?: number;
  expiryDate?: string;
}

export class PantryRepository {
  static async add(data: AddIngredientDTO): Promise<Ingredient> {
    console.log('Adding ingredient:', data.name);
    const supabase = getSupabaseAdmin();
    
    const { data: result, error } = await supabase
      .from('ingredients')
      .insert({
        pantry_id: data.pantryId,
        name: data.name,
        quantity: data.quantity,
        unit: data.unit,
        category: data.category,
        minimum_quantity: data.minimumQuantity ?? 0,
        expiry_date: data.expiryDate ?? null,
      })
      .select()
      .single();

    if (error || !result) {
      throw new Error(`Failed to add ingredient: ${error?.message}`);
    }

    return this.mapToEntity(result);
  }

  static async update(data: UpdateIngredientDTO): Promise<Ingredient> {
    console.log('Updating ingredient:', data.id);
    const supabase = getSupabaseAdmin();
    
    const updatePayload: Record<string, any> = {
      updated_at: new Date().toISOString()
    };
    
    if (data.quantity !== undefined) updatePayload.quantity = data.quantity;
    if (data.unit !== undefined) updatePayload.unit = data.unit;
    if (data.minimumQuantity !== undefined) updatePayload.minimum_quantity = data.minimumQuantity;
    if (data.expiryDate !== undefined) updatePayload.expiry_date = data.expiryDate;

    const { data: result, error } = await supabase
      .from('ingredients')
      .update(updatePayload)
      .eq('id', data.id)
      .select()
      .single();

    if (error || !result) {
      throw new NotFoundError('Nie znaleziono składnika do aktualizacji.');
    }

    return this.mapToEntity(result);
  }

  static async delete(id: string): Promise<void> {
    console.log('Deleting ingredient:', id);
    const supabase = getSupabaseAdmin();
    
    const { error, count } = await supabase
      .from('ingredients')
      .delete({ count: 'exact' })
      .eq('id', id);

    if (error) {
      throw new Error(`Failed to delete ingredient: ${error.message}`);
    }
    
    if (count === 0) {
      throw new NotFoundError('Nie znaleziono składnika do usunięcia.');
    }
  }

  static async list(pantryId: string): Promise<Ingredient[]> {
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase
      .from('ingredients')
      .select('*')
      .eq('pantry_id', pantryId)
      .order('category', { ascending: true })
      .order('name', { ascending: true });

    if (error || !data) {
      throw new Error(`Failed to list ingredients: ${error?.message}`);
    }

    return data.map(this.mapToEntity);
  }

  static async findById(id: string): Promise<Ingredient> {
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase
      .from('ingredients')
      .select('*')
      .eq('id', id)
      .single();

    if (error || !data) {
      throw new NotFoundError('Nie znaleziono składnika.');
    }

    return this.mapToEntity(data);
  }

  static async findByName(pantryId: string, name: string): Promise<Ingredient | null> {
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase
      .from('ingredients')
      .select('*')
      .eq('pantry_id', pantryId)
      .ilike('name', name)
      .maybeSingle();

    if (error || !data) {
      return null;
    }

    return this.mapToEntity(data);
  }

  static async getPantryIdForUser(userId: string): Promise<string> {
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase
      .from('pantries')
      .select('id')
      .eq('owner_id', userId)
      .single();

    if (error || !data) {
      throw new NotFoundError('Nie znaleziono spiżarni użytkownika.');
    }

    return data.id;
  }

  static async getPantryIdForFamily(familyId: string): Promise<string> {
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase
      .from('pantries')
      .select('id')
      .eq('family_id', familyId)
      .single();

    if (error || !data) {
      throw new NotFoundError('Nie znaleziono spiżarni rodziny.');
    }

    return data.id;
  }

  static async addFromShoppingList(data: {
    pantryId: string,
    ingredientName: string,
    quantity: number,
    unit: string,
    addedBy: string
  }): Promise<Ingredient> {
    console.log('Adding from shopping list:', data.ingredientName);
    const supabase = getSupabaseAdmin();

    const { data: existing } = await supabase
      .from('ingredients')
      .select('*')
      .eq('pantry_id', data.pantryId)
      .ilike('name', data.ingredientName)
      .maybeSingle();

    if (existing) {
      const { data: updated, error } = await supabase
        .from('ingredients')
        .update({
          quantity: Number(existing.quantity) + data.quantity,
          updated_at: new Date().toISOString()
        })
        .eq('id', existing.id)
        .select()
        .single();

      if (error || !updated) throw new Error(`Failed to update existing ingredient: ${error?.message}`);
      return this.mapToEntity(updated);
    }

    const { data: inserted, error } = await supabase
      .from('ingredients')
      .insert({
        pantry_id: data.pantryId,
        name: data.ingredientName,
        quantity: data.quantity,
        unit: data.unit,
        category: 'other',
        added_by: data.addedBy
      })
      .select()
      .single();

    if (error || !inserted) throw new Error(`Failed to add new ingredient from list: ${error?.message}`);
    return this.mapToEntity(inserted);
  }

  private static mapToEntity(row: any): Ingredient {
    return {
      id: row.id,
      pantryId: row.pantry_id,
      name: row.name,
      quantity: row.quantity,
      unit: row.unit,
      category: row.category,
      minimumQuantity: row.minimum_quantity,
      expiryDate: row.expiry_date,
      addedBy: row.added_by,
      createdAt: row.created_at,
      updatedAt: row.updated_at
    };
  }
}
