import { z } from 'https://deno.land/x/zod@v3.22.4/mod.ts';

// --- manage-pantry ---
export const AddIngredientSchema = z.object({
  pantryId: z.string().uuid(),
  name: z.string().min(1),
  quantity: z.number().positive(),
  unit: z.string().min(1),
  category: z.string().min(1),
  minimumQuantity: z.number().min(0).default(0),
  expiryDate: z.string().datetime().optional()
});

export const UpdateIngredientSchema = z.object({
  id: z.string().uuid(),
  quantity: z.number().positive().optional(),
  unit: z.string().min(1).optional(),
  minimumQuantity: z.number().min(0).optional(),
  expiryDate: z.string().datetime().optional()
});

export const DeleteIngredientSchema = z.object({
  id: z.string().uuid()
});

export const ListPantrySchema = z.object({
  pantryId: z.string().uuid()
});

export const GetExpiringSchema = z.object({
  pantryId: z.string().uuid(),
  daysThreshold: z.number().positive()
});

// --- manage-shopping-list ---
export const AddShoppingItemSchema = z.object({
  userId: z.string().uuid(),
  familyId: z.string().uuid().optional(),
  ingredientName: z.string().min(1),
  quantityNeeded: z.number().positive(),
  unit: z.string().min(1)
});

export const MarkPurchasedSchema = z.object({
  itemId: z.string().uuid()
});

export const DeleteShoppingItemSchema = z.object({
  itemId: z.string().uuid()
});

export const ListShoppingSchema = z.object({
  userId: z.string().uuid(),
  familyId: z.string().uuid().optional()
});

export const ClearPurchasedSchema = z.object({
  userId: z.string().uuid(),
  familyId: z.string().uuid().optional()
});

export const MoveToPantrySchema = z.object({
  action: z.literal('move_to_pantry'),
  itemId: z.string().uuid(),
  quantity: z.number().positive(),
  unit: z.string().min(1),
  familyId: z.string().uuid().optional()
});

// --- calculate-daily-macros ---
export const DailyMacrosSchema = z.object({
  userId: z.string().uuid(),
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Date must be YYYY-MM-DD")
});

export const WeeklyMacrosSchema = z.object({
  startDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/),
  endDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/)
});

// --- family-invite ---
export const JoinFamilySchema = z.object({
  userId: z.string().uuid(),
  inviteCode: z.string().min(1)
});

export const GetMembersSchema = z.object({
  familyId: z.string().uuid()
});

export const LeaveFamilySchema = z.object({
  userId: z.string().uuid(),
  familyId: z.string().uuid()
});

export const CreateFamilySchema = z.object({
  userId: z.string().uuid(),
  name: z.string().min(1)
});

// --- search-recipes ---
export const SearchRecipesSchema = z.object({
  userId: z.string().uuid(),
  pantryIngredients: z.array(z.string()).min(1)
});

// --- cook-recipe ---
export const CookRecipeSchema = z.object({
  familyId: z.string().uuid(),
  recipeId: z.string().uuid(),
  servingsCooked: z.number().positive()
});

// --- detect-food ---
export const DetectFoodSchema = z.object({
  userId: z.string().uuid(),
  photoBase64: z.string().min(1),
  mealTime: z.enum(['breakfast', 'lunch', 'dinner', 'snack']),
  mealDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, "Date must be YYYY-MM-DD")
});

// --- manage-user-recipes ---
export const CreateRecipeSchema = z.object({
  title: z.string().min(3).max(100),
  description: z.string().max(500).optional(),
  cuisineType: z.string().default('other'),
  spiceLevel: z.number().int().min(0).max(5).default(0),
  difficultyLevel: z.enum(['easy', 'medium', 'hard']).default('medium'),
  prepTimeMinutes: z.number().int().min(0).max(480).default(0),
  cookTimeMinutes: z.number().int().min(0).max(480).default(0),
  servings: z.number().int().min(1).max(20).default(2),
  dietTags: z.array(z.string()).default([]),
  mealType: z.enum([
    'breakfast', 'lunch', 'dinner', 'snack', 'dessert',
  ]).default('dinner'),
  ingredients: z.array(z.object({
    name: z.string().min(1),
    amount: z.number().positive(),
    unit: z.string().min(1),
  })).min(1),
  steps: z.array(z.object({
    number: z.number().int().positive(),
    instruction: z.string().min(5),
  })).min(1),
  isPublic: z.boolean().default(false),
  photoUrl: z.string().url().optional(),
  estimatedMacros: z.object({
    proteinG: z.number().min(0),
    carbsG: z.number().min(0),
    fatG: z.number().min(0),
    calories: z.number().min(0),
  }),
});

// --- browse-recipes ---
export const RecipeFiltersSchema = z.object({
  cuisineType: z.string().optional(),
  spiceLevel: z.number().int().min(0).max(5).optional(),
  difficultyLevel: z.enum(['easy', 'medium', 'hard']).optional(),
  maxPrepTime: z.number().int().positive().optional(),
  dietTags: z.array(z.string()).optional(),
  mealType: z.enum([
    'breakfast', 'lunch', 'dinner', 'snack', 'dessert',
  ]).optional(),
  maxCalories: z.number().positive().optional(),
  minProtein: z.number().positive().optional(),
  searchQuery: z.string().max(100).optional(),
  sortBy: z.enum([
    'newest', 'most_liked', 'quickest', 'highest_protein',
  ]).default('newest'),
  limit: z.number().int().min(1).max(50).default(20),
  offset: z.number().int().min(0).default(0),
});
