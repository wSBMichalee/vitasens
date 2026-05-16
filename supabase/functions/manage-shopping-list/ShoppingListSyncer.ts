import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';
import { ShoppingListRepository, ShoppingItem } from './ShoppingListRepository.ts';
import { PantryRepository, Ingredient } from '../manage-pantry/PantryRepository.ts';

export interface SyncResult {
  added: string[];
  skipped: string[];
  total: number;
}

export class ShoppingListSyncer {
  static async syncLowStock(pantryId: string, userId: string, familyId?: string): Promise<SyncResult> {
    console.log(`Syncing low stock for pantry: ${pantryId}`);
    const supabase = getSupabaseAdmin();
    const result: SyncResult = { added: [], skipped: [], total: 0 };

    const { data: ingredients, error } = await supabase
      .from('ingredients')
      .select('name, quantity, unit, minimum_quantity')
      .eq('pantry_id', pantryId)
      .gt('minimum_quantity', 0);

    if (error) throw new Error(`Failed to fetch ingredients: ${error.message}`);
    
    const lowStockItems = (ingredients || []).filter(i => i.quantity <= i.minimum_quantity);
    result.total = lowStockItems.length;

    for (const item of lowStockItems) {
      const alreadyExists = await ShoppingListRepository.existsUnpurchased(item.name, userId, familyId);
      if (!alreadyExists) {
        await ShoppingListRepository.add({
          userId,
          familyId,
          ingredientName: item.name,
          quantityNeeded: item.minimum_quantity,
          unit: item.unit,
          addedAutomatically: true,
          source: 'low_stock'
        });
        result.added.push(item.name);
      } else {
        result.skipped.push(item.name);
      }
    }

    return result;
  }

  static async syncExpired(pantryId: string, userId: string, familyId?: string): Promise<SyncResult> {
    console.log(`Syncing expired items for pantry: ${pantryId}`);
    const supabase = getSupabaseAdmin();
    const result: SyncResult = { added: [], skipped: [], total: 0 };

    const { data: ingredients, error } = await supabase
      .from('ingredients')
      .select('name, quantity, unit')
      .eq('pantry_id', pantryId)
      .lt('expiry_date', new Date().toISOString().split('T')[0]);

    if (error) throw new Error(`Failed to fetch expired ingredients: ${error.message}`);
    
    result.total = (ingredients || []).length;

    for (const item of ingredients || []) {
      const alreadyExists = await ShoppingListRepository.existsUnpurchased(item.name, userId, familyId);
      if (!alreadyExists) {
        await ShoppingListRepository.add({
          userId,
          familyId,
          ingredientName: item.name,
          quantityNeeded: item.quantity,
          unit: item.unit,
          addedAutomatically: true,
          source: 'expired'
        });
        result.added.push(item.name);
      } else {
        result.skipped.push(item.name);
      }
    }

    return result;
  }

  static async syncAll(pantryId: string, userId: string, familyId?: string) {
    const [lowStock, expired] = await Promise.all([
      this.syncLowStock(pantryId, userId, familyId),
      this.syncExpired(pantryId, userId, familyId)
    ]);
    return { lowStock, expired };
  }

  static async deduplicateList(userId: string, familyId?: string): Promise<number> {
    console.log('Deduplicating shopping list');
    const supabase = getSupabaseAdmin();
    
    let query = supabase
      .from('shopping_list')
      .select('id, ingredient_name, created_at')
      .eq('is_purchased', false);

    if (familyId) {
      query = query.eq('family_id', familyId);
    } else {
      query = query.eq('user_id', userId).is('family_id', null);
    }

    const { data, error } = await query;
    if (error) throw new Error(`Failed to fetch items for deduplication: ${error.message}`);

    const itemsByName: Record<string, any[]> = {};
    data?.forEach(item => {
      if (!itemsByName[item.ingredient_name]) itemsByName[item.ingredient_name] = [];
      itemsByName[item.ingredient_name].push(item);
    });

    let removedCount = 0;
    for (const name in itemsByName) {
      const versions = itemsByName[name];
      if (versions.length > 1) {
        // Sort by created_at descending to keep the newest
        versions.sort((a, b) => new Date(b.created_at).getTime() - new Date(a.created_at).getTime());
        const toDelete = versions.slice(1).map(v => v.id);
        
        const { error: delError } = await supabase
          .from('shopping_list')
          .delete()
          .in('id', toDelete);
          
        if (delError) console.error(`Failed to delete duplicates for ${name}:`, delError);
        else removedCount += toDelete.length;
      }
    }

    return removedCount;
  }

  static async moveToPantry(
    itemId: string,
    userId: string,
    quantity: number,
    unit: string,
    familyId?: string
  ): Promise<{ shoppingItem: ShoppingItem, ingredient: Ingredient }> {
    console.log('Moving item to pantry:', itemId);

    const shoppingItem = await ShoppingListRepository.markAsPurchasedAndGetItem(itemId);

    const pantryId = familyId 
      ? await PantryRepository.getPantryIdForFamily(familyId)
      : await PantryRepository.getPantryIdForUser(userId);

    const ingredient = await PantryRepository.addFromShoppingList({
      pantryId,
      ingredientName: shoppingItem.ingredientName,
      quantity,
      unit,
      addedBy: userId
    });

    console.log('Moved to pantry:', shoppingItem.ingredientName);
    return { shoppingItem, ingredient };
  }
}
