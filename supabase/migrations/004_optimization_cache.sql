-- ============================================================
-- MIGRACJA 004: Optymalizacja kosztów AI
-- Cache wykrywania jedzenia, rate limiting, cache przepisów
-- ============================================================

-- Cache wykrywania jedzenia (detect-food)
-- Oszczędza koszt Google Vision API dla powtarzających się zdjęć (30 dni TTL)
CREATE TABLE IF NOT EXISTS food_detection_cache (
  id          UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  image_hash  TEXT        UNIQUE NOT NULL,
  result      JSONB       NOT NULL,
  created_at  TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_food_detection_cache_hash
  ON food_detection_cache(image_hash);

CREATE INDEX IF NOT EXISTS idx_food_detection_cache_created_at
  ON food_detection_cache(created_at);

-- Rate limiting użycia AI per user/dzień
-- Darmowy plan: max 10 wywołań/24h; Pro: unlimited
CREATE TABLE IF NOT EXISTS daily_usage (
  id            UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id       UUID        REFERENCES profiles(id) ON DELETE CASCADE,
  function_name TEXT        NOT NULL,
  created_at    TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_daily_usage_user_function_date
  ON daily_usage(user_id, function_name, created_at);

-- Cache wyników Spoonacular (search-recipes)
-- TTL = 7 dni — przepisy się nie zmieniają często
CREATE TABLE IF NOT EXISTS recipe_cache (
  id         UUID        PRIMARY KEY DEFAULT gen_random_uuid(),
  cache_key  TEXT        UNIQUE NOT NULL,
  result     JSONB       NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_recipe_cache_key
  ON recipe_cache(cache_key);

CREATE INDEX IF NOT EXISTS idx_recipe_cache_created_at
  ON recipe_cache(created_at);
