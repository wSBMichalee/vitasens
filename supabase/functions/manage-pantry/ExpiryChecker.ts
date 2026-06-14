import { getSupabaseAdmin } from '../_shared/supabaseClient.ts';

export interface ExpiringIngredient {
  id: string;
  name: string;
  quantity: number;
  unit: string;
  category: string;
  imageUrl?: string;
  minimumQuantity?: number;
  expiryDate: string;
  daysUntilExpiry: number;
}

export type ExpiryStatus = 'ok' | 'expiringSoon' | 'expired';

export class ExpiryChecker {
  static async getExpiring(pantryId: string, daysThreshold: number = 3): Promise<ExpiringIngredient[]> {
    console.log('Checking expiring for pantry:', pantryId);
    const supabase = getSupabaseAdmin();
    
    const { data, error } = await supabase.rpc('get_expiring_ingredients', {
      p_pantry_id: pantryId,
      p_days: daysThreshold
    });

    if (error) {
      throw new Error(`Failed to get expiring ingredients: ${error.message}`);
    }

    const ingredients: ExpiringIngredient[] = (data || []).map((row: any) => ({
      id: row.id,
      name: row.name,
      quantity: row.quantity,
      unit: row.unit,
      category: row.category,
      imageUrl: row.image_url,
      minimumQuantity: row.minimum_quantity,
      expiryDate: row.expiry_date,
      daysUntilExpiry: row.days_until_expiry
    }));

    return ingredients.sort((a, b) => a.daysUntilExpiry - b.daysUntilExpiry);
  }

  static getExpiryStatus(daysUntilExpiry: number): ExpiryStatus {
    if (daysUntilExpiry < 0) return 'expired';
    if (daysUntilExpiry <= 3) return 'expiringSoon';
    return 'ok';
  }

  static async getSummary(pantryId: string): Promise<{
    expiredCount: number;
    expiringSoonCount: number;
    expiredItems: ExpiringIngredient[];
    expiringSoonItems: ExpiringIngredient[];
  }> {
    const allExpiring = await this.getExpiring(pantryId, 7);
    
    const expiredItems = allExpiring.filter(i => i.daysUntilExpiry < 0);
    const expiringSoonItems = allExpiring.filter(i => i.daysUntilExpiry >= 0 && i.daysUntilExpiry <= 3);

    return {
      expiredCount: expiredItems.length,
      expiringSoonCount: expiringSoonItems.length,
      expiredItems,
      expiringSoonItems
    };
  }
}
