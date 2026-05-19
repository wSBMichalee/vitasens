import type { BarcodeProduct } from './BarcodeNutritionFetcher.ts';

export interface ScaledMacros {
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
}

export interface MealInsertPayload {
  user_id: string;
  meal_date: string;
  meal_time: string;
  food_name: string;
  protein_g: number;
  carbs_g: number;
  fat_g: number;
  calories: number;
  source: 'manual';
  log_source: 'barcode';
}

export interface IngredientInsertPayload {
  pantry_id: string;
  name: string;
  quantity: number;
  unit: string;
  category: string;
  barcode: string;
  brand: string;
}

export class BarcodeProductMapper {
  scaleMacros(product: BarcodeProduct, servingG: number): ScaledMacros {
    const ratio = servingG / 100;
    return {
      proteinG: Math.round(product.per100g.proteinG * ratio * 10) / 10,
      carbsG:   Math.round(product.per100g.carbsG   * ratio * 10) / 10,
      fatG:     Math.round(product.per100g.fatG      * ratio * 10) / 10,
      calories: Math.round(product.per100g.calories  * ratio),
    };
  }

  toMealPayload(
    product: BarcodeProduct,
    servingG: number,
    userId: string,
    mealTime: string,
    mealDate: string,
  ): MealInsertPayload {
    const macros = this.scaleMacros(product, servingG);
    const label = product.brand ? `${product.brand} – ${product.name}` : product.name;
    return {
      user_id:    userId,
      meal_date:  mealDate,
      meal_time:  mealTime,
      food_name:  label,
      protein_g:  macros.proteinG,
      carbs_g:    macros.carbsG,
      fat_g:      macros.fatG,
      calories:   macros.calories,
      source:     'manual',
      log_source: 'barcode',
    };
  }

  toIngredientPayload(
    product: BarcodeProduct,
    pantryId: string,
    quantity: number,
    unit: string,
  ): IngredientInsertPayload {
    return {
      pantry_id: pantryId,
      name:      product.name,
      quantity,
      unit,
      category:  'other',
      barcode:   product.barcode,
      brand:     product.brand,
    };
  }
}
