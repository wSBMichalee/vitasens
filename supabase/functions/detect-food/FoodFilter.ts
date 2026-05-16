import { VisionLabel } from './VisionClient.ts';
import { ValidationError } from '../_shared/errorHandler.ts';

export interface FoodItem {
  name: string;
  confidence: number;
  isMainDish: boolean;
}

export interface FilterResult {
  foodItems: FoodItem[];
  primaryFood: string;
  allFoodsLabel: string;
  averageConfidence: number;
}

export class FoodFilter {
  private static readonly FOOD_KEYWORDS: string[] = [
    'food', 'dish', 'meal', 'cuisine', 'ingredient',
    'meat', 'chicken', 'beef', 'pork', 'fish', 'seafood',
    'vegetable', 'fruit', 'bread', 'pasta', 'rice', 'soup',
    'salad', 'sandwich', 'pizza', 'burger', 'steak',
    'egg', 'cheese', 'milk', 'yogurt', 'butter',
    'potato', 'tomato', 'onion', 'garlic', 'carrot',
    'broccoli', 'spinach', 'lettuce', 'pepper', 'mushroom',
    'apple', 'banana', 'orange', 'strawberry', 'berry',
    'cake', 'cookie', 'chocolate', 'ice cream', 'dessert',
    'breakfast', 'lunch', 'dinner', 'snack',
    'bowl', 'plate', 'portion'
  ];

  private static readonly NON_FOOD_KEYWORDS: string[] = [
    'person', 'people', 'hand', 'table', 'furniture',
    'room', 'building', 'sky', 'grass', 'tree',
    'dog', 'cat', 'animal', 'car', 'phone'
  ];

  static extractFoodLabels(labels: VisionLabel[]): FoodItem[] {
    const foodItems = (labels || [])
      .filter(label => {
        const desc = label.description.toLowerCase();
        const score = label.score;
        
        if (score < 0.70) return false;
        
        const isFood = this.FOOD_KEYWORDS.some(k => desc.includes(k));
        const isNonFood = this.NON_FOOD_KEYWORDS.some(k => desc.includes(k));
        
        return isFood && !isNonFood;
      })
      .map(label => ({
        name: label.description.toLowerCase(),
        confidence: Math.round(label.score * 100),
        isMainDish: label.score >= 0.85
      }))
      .sort((a, b) => b.confidence - a.confidence);

    return foodItems.slice(0, 10);
  }

  static getFilterResult(foodItems: FoodItem[]): FilterResult {
    if (foodItems.length === 0) {
      throw new ValidationError('Nie wykryto jedzenia na zdjęciu. Spróbuj ponownie.');
    }

    const primaryFood = foodItems[0].name;
    const allFoodsLabel = foodItems
      .slice(0, 3)
      .map(f => f.name)
      .join(' + ');

    const averageConfidence = Math.round(
      foodItems.reduce((acc, f) => acc + f.confidence, 0) / foodItems.length
    );

    return {
      foodItems,
      primaryFood,
      allFoodsLabel,
      averageConfidence
    };
  }

  static isFoodRelated(label: string): boolean {
    const desc = label.toLowerCase();
    return this.FOOD_KEYWORDS.some(k => desc.includes(k));
  }

  static getMainDishes(foodItems: FoodItem[]): FoodItem[] {
    const mainDishes = foodItems.filter(f => f.isMainDish);
    return mainDishes.length > 0 ? mainDishes : foodItems;
  }
}
