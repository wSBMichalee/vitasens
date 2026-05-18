export interface RecipeFilters {
  cuisineType?: string;
  spiceLevel?: number;
  difficultyLevel?: 'easy' | 'medium' | 'hard';
  maxPrepTime?: number;
  dietTags?: string[];
  mealType?: string;
  maxCalories?: number;
  minProtein?: number;
  searchQuery?: string;
  sortBy?: 'newest' | 'most_liked' | 'quickest' | 'highest_protein';
  limit?: number;
  offset?: number;
}

export interface QueryResult {
  query: string;
  params: unknown[];
}

export class RecipeFilters {
  static buildQuery(filters: RecipeFilters): QueryResult {
    const normalized = this.validateFilters(filters);
    const { conditions, params } = this.buildConditions(normalized);

    const where = conditions.length > 0
      ? `WHERE is_public = true AND ${conditions.join(' AND ')}`
      : 'WHERE is_public = true';

    const orderBy = this.buildOrderBy(normalized.sortBy);
    const paramCount = params.length;
    params.push(normalized.limit ?? 20, normalized.offset ?? 0);

    const query = `SELECT * FROM recipes ${where} ${orderBy} LIMIT $${paramCount + 1} OFFSET $${paramCount + 2}`;
    return { query, params };
  }

  static buildCountQuery(filters: RecipeFilters): QueryResult {
    const normalized = this.validateFilters(filters);
    const { conditions, params } = this.buildConditions(normalized);

    const where = conditions.length > 0
      ? `WHERE is_public = true AND ${conditions.join(' AND ')}`
      : 'WHERE is_public = true';

    const query = `SELECT COUNT(*) FROM recipes ${where}`;
    return { query, params };
  }

  static validateFilters(filters: RecipeFilters): RecipeFilters {
    return {
      ...filters,
      limit: Math.min(Math.max(filters.limit ?? 20, 1), 50),
      offset: Math.max(filters.offset ?? 0, 0),
      spiceLevel: filters.spiceLevel !== undefined
        ? Math.min(Math.max(filters.spiceLevel, 0), 5)
        : undefined,
    };
  }

  static getCuisineOptions(): Array<{ code: string; name: string; flag: string }> {
    return [
      { code: 'polish', name: 'Polska', flag: '🇵🇱' },
      { code: 'italian', name: 'Włoska', flag: '🇮🇹' },
      { code: 'japanese', name: 'Japońska', flag: '🇯🇵' },
      { code: 'chinese', name: 'Chińska', flag: '🇨🇳' },
      { code: 'mexican', name: 'Meksykańska', flag: '🇲🇽' },
      { code: 'indian', name: 'Indyjska', flag: '🇮🇳' },
      { code: 'french', name: 'Francuska', flag: '🇫🇷' },
      { code: 'greek', name: 'Grecka', flag: '🇬🇷' },
      { code: 'thai', name: 'Tajska', flag: '🇹🇭' },
      { code: 'american', name: 'Amerykańska', flag: '🇺🇸' },
      { code: 'spanish', name: 'Hiszpańska', flag: '🇪🇸' },
      { code: 'middle_eastern', name: 'Bliskowschodnia', flag: '🇱🇧' },
      { code: 'mediterranean', name: 'Śródziemnomorska', flag: '🌊' },
      { code: 'other', name: 'Inne', flag: '🌍' },
    ];
  }

  static getDietTagOptions(): Array<{ code: string; name: string; emoji: string }> {
    return [
      { code: 'vegetarian', name: 'Wegetariańska', emoji: '🥬' },
      { code: 'vegan', name: 'Wegańska', emoji: '🌱' },
      { code: 'keto', name: 'Keto', emoji: '🥑' },
      { code: 'gluten_free', name: 'Bezglutenowa', emoji: '🌾' },
      { code: 'high_protein', name: 'Wysokobiałkowe', emoji: '💪' },
      { code: 'low_carb', name: 'Niskowęglowodanowa', emoji: '📉' },
      { code: 'dairy_free', name: 'Bez nabiału', emoji: '🥛' },
      { code: 'paleo', name: 'Paleo', emoji: '🦴' },
    ];
  }

  private static buildConditions(
    filters: RecipeFilters,
  ): { conditions: string[]; params: unknown[] } {
    const conditions: string[] = [];
    const params: unknown[] = [];

    const add = (condition: string, value: unknown) => {
      params.push(value);
      conditions.push(condition.replace('$n', `$${params.length}`));
    };

    if (filters.cuisineType) add('cuisine_type = $n', filters.cuisineType);
    if (filters.spiceLevel !== undefined) add('spice_level = $n', filters.spiceLevel);
    if (filters.difficultyLevel) add('difficulty_level = $n', filters.difficultyLevel);
    if (filters.maxPrepTime !== undefined) {
      add('(prep_time_minutes + cook_time_minutes) <= $n', filters.maxPrepTime);
    }
    if (filters.dietTags && filters.dietTags.length > 0) {
      add('$n = ANY(diet_tags)', filters.dietTags[0]);
    }
    if (filters.mealType) add('meal_type = $n', filters.mealType);
    if (filters.maxCalories !== undefined) add('calories <= $n', filters.maxCalories);
    if (filters.minProtein !== undefined) add('protein_g >= $n', filters.minProtein);
    if (filters.searchQuery) add('title ILIKE $n', `%${filters.searchQuery}%`);

    return { conditions, params };
  }

  private static buildOrderBy(
    sortBy: RecipeFilters['sortBy'],
  ): string {
    switch (sortBy) {
      case 'most_liked': return 'ORDER BY likes_count DESC';
      case 'quickest': return 'ORDER BY (prep_time_minutes + cook_time_minutes) ASC';
      case 'highest_protein': return 'ORDER BY protein_g DESC';
      case 'newest':
      default: return 'ORDER BY created_at DESC';
    }
  }
}
