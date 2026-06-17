import { SpoonacularRecipe } from './SpoonacularClient.ts';

export interface MatchResult {
  recipeId: number;
  title: string;
  matchPercent: number;
  usedIngredients: string[];
  missingIngredients: string[];
  missingCount: number;
}

export class IngredientMatcher {
  static calculateMatchPercent(
    _userIngredients: string[],
    recipeUsed: string[],
    recipeMissed: string[]
  ): number {
    const total = recipeUsed.length + recipeMissed.length;
    if (total === 0) return 0;
    const match = (recipeUsed.length / total) * 100;
    return Math.round(match);
  }

  static normalizeIngredientName(name: string): string {
    let normalized = name.toLowerCase().trim();
    
    // Usuwa liczby i jednostki na początku (uproszczone)
    normalized = normalized.replace(/^\d+(\/\d+)?\s*(g|kg|ml|l|oz|lb|cups?|tbsps?|tsps?|cloves?|pieces?|cloves?|cans?|jars?|packets?|packages?)\s+/, '');
    normalized = normalized.replace(/^\d+\s+/, '');

    const stopWords = [
      "fresh", "dried", "chopped", "sliced", "diced", "minced", 
      "large", "small", "medium", "whole", "frozen", "organic",
      "shredded", "grated", "peeled", "crushed"
    ];

    stopWords.forEach(word => {
      const regex = new RegExp(`\\b${word}\\b`, 'g');
      normalized = normalized.replace(regex, '');
    });

    return normalized.replace(/\s+/g, ' ').trim();
  }

  static filterByMinMatch(
    recipes: MatchResult[],
    minPercent: number = 0
  ): MatchResult[] {
    return recipes
      .filter(r => r.matchPercent >= minPercent)
      .sort((a, b) => b.matchPercent - a.matchPercent);
  }

  static buildMatchResults(
    spoonacularRecipes: SpoonacularRecipe[]
  ): MatchResult[] {
    return spoonacularRecipes.map(recipe => {
      const usedNames = recipe.usedIngredients.map(i => i.name);
      const missedNames = recipe.missedIngredients.map(i => i.name);
      
      const matchPercent = this.calculateMatchPercent([], usedNames, missedNames);

      return {
        recipeId: recipe.id,
        title: recipe.title,
        matchPercent,
        usedIngredients: usedNames,
        missingIngredients: missedNames,
        missingCount: missedNames.length
      };
    });
  }

  static sortByBestMatch(results: MatchResult[]): MatchResult[] {
    return [...results].sort((a, b) => {
      if (b.matchPercent !== a.matchPercent) {
        return b.matchPercent - a.matchPercent;
      }
      return a.missingCount - b.missingCount;
    });
  }
}
