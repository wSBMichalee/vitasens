import { PantryRepository } from '../manage-pantry/PantryRepository.ts';
import { ShoppingListRepository } from '../manage-shopping-list/ShoppingListRepository.ts';
import { ShoppingListSyncer } from '../manage-shopping-list/ShoppingListSyncer.ts';
import { Recipe } from '../search-recipes/RecipeRepository.ts';

export interface UpdatedIngredient {
  name: string;
  previousQuantity: number;
  consumedQuantity: number;
  remainingQuantity: number;
  unit: string;
}

export interface CookingResult {
  recipeId: string;
  servingsCooked: number;
  ingredientsUpdated: UpdatedIngredient[];
  ingredientsDeleted: string[];
  shoppingListAdded: string[];
}

export interface RecipeIngredientUsage {
  name: string;
  requiredAmount: number;
  unit: string;
}

export class CookingProcessor {
  static async process(
    recipeId: string,
    familyId: string,
    userId: string,
    servingsCooked: number,
    recipe: Recipe
  ): Promise<CookingResult> {
    console.log('Processing recipe cook:', recipeId);
    
    const pantryId = await PantryRepository.getPantryIdForFamily(familyId);
    const usage = this.calculateUsage(recipe, servingsCooked);
    const { updated, deleted, shoppingAdded } = await this.updatePantryIngredients(pantryId, usage, userId, familyId);

    return {
      recipeId,
      servingsCooked,
      ingredientsUpdated: updated,
      ingredientsDeleted: deleted,
      shoppingListAdded: shoppingAdded
    };
  }

  private static calculateUsage(recipe: Recipe, servingsCooked: number): RecipeIngredientUsage[] {
    const scale = servingsCooked / recipe.servings;
    return recipe.ingredients.map(ing => ({
      name: ing.name,
      requiredAmount: ing.amount * scale,
      unit: ing.unit
    }));
  }

  private static async updatePantryIngredients(
    pantryId: string,
    usage: RecipeIngredientUsage[],
    userId: string,
    familyId: string
  ): Promise<{
    updated: UpdatedIngredient[],
    deleted: string[],
    shoppingAdded: string[]
  }> {
    const updated: UpdatedIngredient[] = [];
    const deleted: string[] = [];
    const shoppingAdded: string[] = [];

    for (const ing of usage) {
      const found = await PantryRepository.findByName(pantryId, ing.name);
      if (!found) {
        console.warn(`Ingredient not found in pantry: ${ing.name}`);
        continue;
      }

      const previousQuantity = found.quantity;
      const consumedQuantity = ing.requiredAmount;
      const newQuantity = previousQuantity - consumedQuantity;

      if (newQuantity <= 0) {
        await PantryRepository.delete(found.id);
        deleted.push(found.name);
        
        const exists = await ShoppingListRepository.existsUnpurchased(found.name, userId, familyId);
        if (!exists) {
          await ShoppingListRepository.add({
            userId,
            familyId,
            ingredientName: found.name,
            quantityNeeded: found.minimumQuantity || 1,
            unit: found.unit,
            addedAutomatically: true,
            source: 'low_stock'
          });
          shoppingAdded.push(found.name);
        }
      } else {
        await PantryRepository.update({ id: found.id, quantity: newQuantity });
        updated.push({
          name: found.name,
          previousQuantity,
          consumedQuantity,
          remainingQuantity: newQuantity,
          unit: found.unit
        });

        if (newQuantity <= found.minimumQuantity) {
          await ShoppingListSyncer.syncLowStock(pantryId, userId, familyId);
        }
      }
    }

    return { updated, deleted, shoppingAdded };
  }
}
