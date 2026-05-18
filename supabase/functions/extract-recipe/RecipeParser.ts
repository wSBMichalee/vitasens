import { ExtractedRecipe } from './RecipeExtractor.ts';
import { UpsertRecipeDTO } from '../search-recipes/RecipeRepository.ts';
import { ValidationError } from '../_shared/errorHandler.ts';

export class RecipeParser {
  parse(raw: Partial<ExtractedRecipe>): ExtractedRecipe {
    try {
      const title = raw.title?.trim();
      if (!title || title.length < 3) {
        throw new ValidationError('Przepis musi mieć tytuł (minimum 3 znaki).');
      }

      const rawIngredients = raw.ingredients ?? [];
      const ingredients = rawIngredients
        .filter((i) => i.name && i.name.trim().length > 0)
        .map((i) => ({
          name: i.name.trim().toLowerCase(),
          amount: Math.max(i.amount ?? 1, 0),
          unit: i.unit ?? 'szt',
        }));

      if (ingredients.length < 1) {
        throw new ValidationError('Przepis musi zawierać co najmniej jeden składnik.');
      }

      const cookTimeMinutes = Math.min(Math.max(raw.cookTimeMinutes ?? 30, 1), 480);
      const servings = Math.min(Math.max(raw.servings ?? 2, 1), 20);

      const steps = (raw.steps ?? []).map((s) => ({
        number: s.number,
        instruction: s.instruction,
      }));

      const proteinG = Math.max(Math.round(raw.estimatedMacros?.proteinG ?? 0), 0);
      const carbsG = Math.max(Math.round(raw.estimatedMacros?.carbsG ?? 0), 0);
      const fatG = Math.max(Math.round(raw.estimatedMacros?.fatG ?? 0), 0);
      let calories = Math.max(Math.round(raw.estimatedMacros?.calories ?? 0), 0);
      if (calories === 0) {
        calories = proteinG * 4 + carbsG * 4 + fatG * 9;
      }

      return {
        title,
        description: raw.description ?? '',
        servings,
        cookTimeMinutes,
        ingredients,
        steps,
        estimatedMacros: { proteinG, carbsG, fatG, calories },
        sourceUrl: raw.sourceUrl ?? '',
        sourcePlatform: raw.sourcePlatform ?? '',
      };
    } catch (err) {
      if (err instanceof ValidationError) throw err;
      throw new ValidationError('Błąd podczas parsowania przepisu.');
    }
  }

  toRecipeDTO(extracted: ExtractedRecipe): UpsertRecipeDTO {
    const sourceId = btoa(extracted.sourceUrl).slice(0, 20);

    return {
      title: extracted.title,
      description: extracted.description,
      source: 'manual',
      sourceId,
      ingredients: extracted.ingredients,
      proteinG: extracted.estimatedMacros.proteinG,
      carbsG: extracted.estimatedMacros.carbsG,
      fatG: extracted.estimatedMacros.fatG,
      calories: extracted.estimatedMacros.calories,
      cookTimeMinutes: extracted.cookTimeMinutes,
      servings: extracted.servings,
      imageUrl: undefined,
    };
  }

  compareWithPantry(
    ingredients: ExtractedRecipe['ingredients'],
    pantryIngredients: string[],
  ): { available: string[]; missing: string[]; matchPercent: number } {
    const pantryNormalized = pantryIngredients.map((p) => p.toLowerCase().trim());

    const available: string[] = [];
    const missing: string[] = [];

    for (const ingredient of ingredients) {
      const name = ingredient.name.toLowerCase().trim();
      const found = pantryNormalized.some(
        (p) => p.includes(name) || name.includes(p),
      );
      if (found) {
        available.push(ingredient.name);
      } else {
        missing.push(ingredient.name);
      }
    }

    const total = ingredients.length;
    const matchPercent = total > 0 ? Math.round((available.length / total) * 100) : 0;

    return { available, missing, matchPercent };
  }
}
