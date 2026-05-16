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

// --- manage-subscription ---
export const CreateCheckoutSchema = z.object({
  userId: z.string().uuid(),
  plan: z.enum(['monthly', 'yearly'])
});

export const AddFamilyAddonSchema = z.object({
  userId: z.string().uuid(),
  plan: z.enum(['monthly', 'yearly'])
});

export const CancelSubscriptionSchema = z.object({
  userId: z.string().uuid()
});

export const WebhookSchema = z.object({
  rawBody: z.string(),
  signature: z.string()
});
