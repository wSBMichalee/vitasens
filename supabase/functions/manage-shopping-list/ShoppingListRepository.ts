import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { NotFoundError } from '../_shared/errorHandler.ts';

export interface ShoppingItem {
  id: string;
  userId: string;
  familyId?: string;
  ingredientName: string;
  quantityNeeded: number;
  unit: string;
  isPurchased: boolean;
  purchasedAt?: string;
  addedAutomatically: boolean;
  source: 'low_stock' | 'expired' | 'manual';
  createdAt: string;
}

export interface AddShoppingItemDTO {
  userId: string;
  familyId?: string;
  ingredientName: string;
  quantityNeeded: number;
  unit: string;
  addedAutomatically?: boolean;
  source?: 'low_stock' | 'expired' | 'manual';
}

export class ShoppingListRepository {
  static async add(data: AddShoppingItemDTO): Promise<ShoppingItem> {
    console.log('Adding to shopping list:', data.ingredientName);
    const supabase = getSupabaseAdmin();
    
    const { data: result, error } = await supabase
      .from('shopping_list')
      .insert({
        user_id: data.userId,
        family_id: data.familyId ?? null,
        ingredient_name: data.ingredientName,
        quantity_needed: data.quantityNeeded,
        unit: data.unit,
        added_automatically: data.addedAutomatically ?? false,
        source: data.source ?? 'manual',
      })
      .select()
      .single();

    if (error || !result) {
      throw new Error(`Failed to add to shopping list: ${error?.message}`);
    }

    return this.mapToEntity(result);
  }

  static async markAsPurchased(itemId: string): Promise<ShoppingItem> {
    const supabase = getSupabaseAdmin();
    
    const { data: result, error } = await supabase
      .from('shopping_list')
      .update({
        is_purchased: true,
        purchased_at: new Date().toISOString()
      })
      .eq('id', itemId)
      .select()
      .single();

    if (error || !result) {
      throw new NotFoundError('Nie znaleziono produktu na liście zakupów.');
    }

    return this.mapToEntity(result);
  }

  static async delete(itemId: string): Promise<void> {
    const supabase = getSupabaseAdmin();
    
    const { error, count } = await supabase
      .from('shopping_list')
      .delete({ count: 'exact' })
      .eq('id', itemId);

    if (error) {
      throw new Error(`Failed to delete item: ${error.message}`);
    }
    
    if (count === 0) {
      throw new NotFoundError('Nie znaleziono produktu do usunięcia.');
    }
  }

  static async listForUser(userId: string): Promise<ShoppingItem[]> {
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase
      .from('shopping_list')
      .select('*')
      .eq('user_id', userId)
      .is('family_id', null)
      .order('is_purchased', { ascending: true })
      .order('created_at', { ascending: false });

    if (error || !data) {
      throw new Error(`Failed to list user items: ${error?.message}`);
    }

    return data.map(this.mapToEntity);
  }

  static async listForFamily(familyId: string): Promise<ShoppingItem[]> {
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase
      .from('shopping_list')
      .select('*')
      .eq('family_id', familyId)
      .order('is_purchased', { ascending: true })
      .order('created_at', { ascending: false });

    if (error || !data) {
      throw new Error(`Failed to list family items: ${error?.message}`);
    }

    return data.map(this.mapToEntity);
  }

  static async clearPurchased(userId: string, familyId?: string): Promise<void> {
    console.log('Clearing purchased items');
    const supabase = getSupabaseAdmin();
    
    let query = supabase
      .from('shopping_list')
      .delete()
      .eq('is_purchased', true);

    if (familyId) {
      query = query.or(`user_id.eq.${userId},family_id.eq.${familyId}`);
    } else {
      query = query.eq('user_id', userId);
    }

    const { error } = await query;

    if (error) {
      throw new Error(`Failed to clear purchased items: ${error.message}`);
    }
  }

  static async existsUnpurchased(name: string, userId: string, familyId?: string): Promise<boolean> {
    const supabase = getSupabaseAdmin();
    
    let query = supabase
      .from('shopping_list')
      .select('id', { count: 'exact', head: true })
      .ilike('ingredient_name', name)
      .eq('is_purchased', false);

    if (familyId) {
      query = query.or(`user_id.eq.${userId},family_id.eq.${familyId}`);
    } else {
      query = query.eq('user_id', userId);
    }

    const { count, error } = await query;

    if (error) {
      throw new Error(`Failed to check existence: ${error.message}`);
    }

    return (count || 0) > 0;
  }

  static async markAsPurchasedAndGetItem(itemId: string): Promise<ShoppingItem> {
    console.log('Marking as purchased:', itemId);
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase
      .from('shopping_list')
      .update({
        is_purchased: true,
        purchased_at: new Date().toISOString()
      })
      .eq('id', itemId)
      .select()
      .single();

    if (error || !data) throw new NotFoundError('Nie znaleziono produktu na liście zakupów.');
    return this.mapToEntity(data);
  }

  private static mapToEntity(row: any): ShoppingItem {
    return {
      id: row.id,
      userId: row.user_id,
      familyId: row.family_id,
      ingredientName: row.ingredient_name,
      quantityNeeded: row.quantity_needed,
      unit: row.unit,
      isPurchased: row.is_purchased,
      purchasedAt: row.purchased_at,
      addedAutomatically: row.added_automatically,
      source: row.source,
      createdAt: row.created_at
    };
  }
}
