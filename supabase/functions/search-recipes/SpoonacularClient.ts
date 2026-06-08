import { ExternalAPIError } from '../_shared/errorHandler.ts';

export interface SpoonacularRecipe {
  id: number;
  title: string;
  image: string;
  usedIngredientCount: number;
  missedIngredientCount: number;
  missedIngredients: SpoonacularIngredient[];
  usedIngredients: SpoonacularIngredient[];
}

export interface SpoonacularIngredient {
  id: number;
  name: string;
  amount: number;
  unit: string;
  image: string;
}

export interface SpoonacularRecipeDetail {
  id: number;
  title: string;
  image: string;
  readyInMinutes: number;
  servings: number;
  cuisines?: string[];
  dishTypes?: string[];
  diets?: string[];
  nutrition?: {
    nutrients: Array<{
      name: string;
      amount: number;
      unit: string;
    }>;
  };
}

export class SpoonacularClient {
  private apiKey: string;
  private baseUrl: string = 'https://api.spoonacular.com';

  constructor() {
    const key = Deno.env.get('SPOONACULAR_API_KEY');
    if (!key) {
      throw new ExternalAPIError('Brak klucza API Spoonacular (SPOONACULAR_API_KEY).');
    }
    this.apiKey = key;
  }

  async findByIngredients(ingredients: string[], number: number = 20): Promise<SpoonacularRecipe[]> {
    console.log('Searching recipes for:', ingredients.length, 'ingredients');
    return this.fetch<SpoonacularRecipe[]>('/recipes/findByIngredients', {
      ingredients: ingredients.join(','),
      number: number.toString(),
      ranking: '1',
      ignorePantry: 'true'
    });
  }

  async getRecipesBulk(ids: number[]): Promise<SpoonacularRecipeDetail[]> {
    return this.fetch<SpoonacularRecipeDetail[]>('/recipes/informationBulk', {
      ids: ids.join(','),
      includeNutrition: 'true'
    });
  }

  async parseIngredientNutrition(ingredientName: string, amount: number = 100, unit: string = 'g'): Promise<{ proteinG: number, carbsG: number, fatG: number, calories: number }> {
    const response = await this.fetch<any[]>('/recipes/parseIngredients', {
      includeNutrition: 'true'
    }, {
      method: 'POST',
      headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
      body: new URLSearchParams({
        ingredientList: `${amount}${unit} ${ingredientName}`
      }).toString()
    });

    const ingredient = response[0];
    if (!ingredient || !ingredient.nutrition) {
      throw new ExternalAPIError('Nie udało się pobrać makr dla składnika.');
    }

    const findNutrient = (name: string) => 
      ingredient.nutrition.nutrients.find((n: any) => n.name === name)?.amount || 0;

    return {
      proteinG: findNutrient('Protein'),
      carbsG: findNutrient('Carbohydrates'),
      fatG: findNutrient('Fat'),
      calories: findNutrient('Calories')
    };
  }

  private async fetch<T>(endpoint: string, params: Record<string, string>, options: RequestInit = {}): Promise<T> {
    const url = new URL(this.baseUrl + endpoint);
    url.searchParams.append('apiKey', this.apiKey);
    Object.entries(params).forEach(([key, value]) => url.searchParams.append(key, value));

    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 10000);

    try {
      const response = await fetch(url.toString(), {
        ...options,
        signal: controller.signal
      });
      clearTimeout(timeoutId);

      if (!response.ok) {
        if (response.status === 429) throw new ExternalAPIError('Spoonacular rate limit exceeded.');
        if (response.status === 401) throw new ExternalAPIError('Invalid Spoonacular API key.');
        throw new ExternalAPIError(`Spoonacular API error: ${response.statusText}`);
      }

      return await response.json();
    } catch (error) {
      if (error instanceof ExternalAPIError) throw error;
      throw new ExternalAPIError(`Spoonacular request failed: ${error instanceof Error ? error.message : String(error)}`);
    }
  }
}
