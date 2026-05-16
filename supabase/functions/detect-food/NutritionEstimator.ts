import { SpoonacularClient } from '../search-recipes/SpoonacularClient.ts';
import { FoodItem } from './FoodFilter.ts';
import { MacrosCalculator } from '../calculate-daily-macros/MacrosCalculator.ts';

export interface NutritionEstimate {
  foodName: string;
  proteinG: number;
  carbsG: number;
  fatG: number;
  calories: number;
  confidence: number;
  portionSize: 'small' | 'medium' | 'large';
}

export interface CombinedNutrition {
  totalProteinG: number;
  totalCarbsG: number;
  totalFatG: number;
  totalCalories: number;
  detectedFoods: string[];
  averageConfidence: number;
}

export class NutritionEstimator {
  private spoonacularClient: SpoonacularClient;

  constructor() {
    this.spoonacularClient = new SpoonacularClient();
  }

  async estimateForFood(foodItem: FoodItem): Promise<NutritionEstimate> {
    console.log('Estimating nutrition for:', foodItem.name);
    try {
      const macros = await this.spoonacularClient.parseIngredientNutrition(foodItem.name, 100, 'g');
      return {
        foodName: foodItem.name,
        proteinG: macros.proteinG,
        carbsG: macros.carbsG,
        fatG: macros.fatG,
        calories: macros.calories,
        confidence: foodItem.confidence,
        portionSize: 'medium'
      };
    } catch (error) {
      console.error(`Graceful degradation: Failed to estimate nutrition for ${foodItem.name}`, error);
      return {
        foodName: foodItem.name,
        proteinG: 0,
        carbsG: 0,
        fatG: 0,
        calories: 0,
        confidence: 0,
        portionSize: 'medium'
      };
    }
  }

  async estimateForMeal(foodItems: FoodItem[]): Promise<CombinedNutrition> {
    const items = foodItems.slice(0, 5);
    const estimates = await Promise.all(items.map(item => this.estimateForFood(item)));
    
    let totalProteinG = 0;
    let totalCarbsG = 0;
    let totalFatG = 0;
    let totalCalories = 0;
    let totalConfidence = 0;

    estimates.forEach(e => {
      totalProteinG += e.proteinG;
      totalCarbsG += e.carbsG;
      totalFatG += e.fatG;
      totalCalories += e.calories;
      totalConfidence += e.confidence;
    });

    if (totalCalories === 0 && (totalProteinG > 0 || totalCarbsG > 0 || totalFatG > 0)) {
      totalCalories = MacrosCalculator.calculateCaloriesFromMacros(totalProteinG, totalCarbsG, totalFatG);
    }

    const averageConfidence = estimates.length > 0 ? Math.round(totalConfidence / estimates.length) : 0;

    console.log('Combined nutrition estimate ready');
    
    return this.roundMacros({
      totalProteinG,
      totalCarbsG,
      totalFatG,
      totalCalories,
      detectedFoods: foodItems.map(f => f.name),
      averageConfidence
    });
  }

  applyPortionMultiplier(
    nutrition: NutritionEstimate,
    portionSize: 'small' | 'medium' | 'large'
  ): NutritionEstimate {
    const multipliers = { small: 0.7, medium: 1.0, large: 1.4 };
    const multiplier = multipliers[portionSize];

    return {
      ...nutrition,
      portionSize,
      proteinG: Math.round(nutrition.proteinG * multiplier),
      carbsG: Math.round(nutrition.carbsG * multiplier),
      fatG: Math.round(nutrition.fatG * multiplier),
      calories: Math.round(nutrition.calories * multiplier)
    };
  }

  roundMacros(nutrition: CombinedNutrition): CombinedNutrition {
    return {
      ...nutrition,
      totalProteinG: Math.round(nutrition.totalProteinG),
      totalCarbsG: Math.round(nutrition.totalCarbsG),
      totalFatG: Math.round(nutrition.totalFatG),
      totalCalories: Math.round(nutrition.totalCalories)
    };
  }
}
