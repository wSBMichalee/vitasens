-- === ENUMS ===
CREATE TYPE goal_type AS ENUM (
  'weight_loss', 'muscle_gain', 'general_health',
  'diabetes_friendly', 'thyroid_friendly', 'keto', 'post_surgery'
);

CREATE TYPE subscription_plan AS ENUM ('monthly', 'yearly');

CREATE TYPE subscription_status AS ENUM (
  'trialing', 'active', 'expired', 'canceled'
);

CREATE TYPE family_role AS ENUM ('owner', 'member');

CREATE TYPE meal_time AS ENUM (
  'breakfast', 'lunch', 'dinner', 'snack'
);

CREATE TYPE meal_source AS ENUM ('ai_detection', 'manual');

CREATE TYPE recipe_source AS ENUM ('spoonacular', 'manual');

CREATE TYPE shopping_source AS ENUM (
  'low_stock', 'expired', 'manual'
);


-- === TABELE ===

CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  avatar_url TEXT,
  goal_type goal_type DEFAULT 'general_health',
  daily_protein_target INTEGER DEFAULT 120,
  daily_carbs_target INTEGER DEFAULT 200,
  daily_fat_target INTEGER DEFAULT 65,
  health_conditions JSONB DEFAULT '[]',
  subscription_plan subscription_plan,
  subscription_status subscription_status DEFAULT 'trialing',
  trial_expires_at TIMESTAMPTZ DEFAULT now() + INTERVAL '3 days',
  subscription_expires_at TIMESTAMPTZ,
  family_addon BOOLEAN DEFAULT false,
  family_addon_expires_at TIMESTAMPTZ,
  stripe_customer_id TEXT,
  stripe_subscription_id TEXT,
  stripe_family_subscription_id TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE families (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  invite_code TEXT UNIQUE DEFAULT substring(gen_random_uuid()::text, 1, 8),
  max_members INTEGER DEFAULT 6,
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE family_members (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id UUID REFERENCES families(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  role family_role DEFAULT 'member',
  joined_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(family_id, user_id)
);

CREATE TABLE pantries (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  family_id UUID REFERENCES families(id) ON DELETE CASCADE,
  owner_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  CHECK (family_id IS NOT NULL OR owner_id IS NOT NULL)
);

CREATE TABLE ingredients (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pantry_id UUID REFERENCES pantries(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  quantity NUMERIC NOT NULL CHECK (quantity >= 0),
  unit TEXT NOT NULL,
  category TEXT DEFAULT 'other',
  minimum_quantity NUMERIC DEFAULT 0,
  expiry_date DATE,
  added_by UUID REFERENCES profiles(id) ON DELETE SET NULL,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE meals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  meal_date DATE NOT NULL DEFAULT CURRENT_DATE,
  meal_time meal_time NOT NULL,
  food_name TEXT NOT NULL,
  photo_url TEXT,
  protein_g NUMERIC DEFAULT 0,
  carbs_g NUMERIC DEFAULT 0,
  fat_g NUMERIC DEFAULT 0,
  calories INTEGER DEFAULT 0,
  source meal_source DEFAULT 'manual',
  confidence INTEGER CHECK (confidence BETWEEN 0 AND 100),
  created_at TIMESTAMPTZ DEFAULT now()
);

CREATE TABLE recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  title TEXT NOT NULL,
  description TEXT,
  source recipe_source DEFAULT 'spoonacular',
  source_id TEXT,
  ingredients JSONB NOT NULL DEFAULT '[]',
  protein_g NUMERIC DEFAULT 0,
  carbs_g NUMERIC DEFAULT 0,
  fat_g NUMERIC DEFAULT 0,
  calories INTEGER DEFAULT 0,
  cook_time_minutes INTEGER,
  servings INTEGER DEFAULT 4,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(source, source_id)
);

CREATE TABLE favorite_recipes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  recipe_id UUID REFERENCES recipes(id) ON DELETE CASCADE,
  saved_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, recipe_id)
);

CREATE TABLE shopping_list (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  family_id UUID REFERENCES families(id) ON DELETE CASCADE,
  ingredient_name TEXT NOT NULL,
  quantity_needed NUMERIC DEFAULT 1,
  unit TEXT DEFAULT 'pieces',
  is_purchased BOOLEAN DEFAULT false,
  purchased_at TIMESTAMPTZ,
  added_automatically BOOLEAN DEFAULT false,
  source shopping_source DEFAULT 'manual',
  created_at TIMESTAMPTZ DEFAULT now()
);


-- === INDEKSY ===
CREATE INDEX idx_ingredients_pantry_id ON ingredients(pantry_id);
CREATE INDEX idx_ingredients_expiry_date ON ingredients(expiry_date);
CREATE INDEX idx_ingredients_pantry_id_name ON ingredients(pantry_id, name);
CREATE INDEX idx_meals_user_id_meal_date ON meals(user_id, meal_date);
CREATE INDEX idx_meals_user_id ON meals(user_id);
CREATE INDEX idx_shopping_list_user_id_is_purchased ON shopping_list(user_id, is_purchased);
CREATE INDEX idx_shopping_list_family_id_is_purchased ON shopping_list(family_id, is_purchased);
CREATE INDEX idx_favorite_recipes_user_id ON favorite_recipes(user_id);
CREATE INDEX idx_family_members_user_id ON family_members(user_id);
CREATE INDEX idx_family_members_family_id ON family_members(family_id);


-- === TRIGGERS ===

-- 1. update_updated_at_column
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_profiles_updated_at
BEFORE UPDATE ON profiles
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_ingredients_updated_at
BEFORE UPDATE ON ingredients
FOR EACH ROW
EXECUTE FUNCTION update_updated_at_column();

-- 2. auto create profile
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.profiles (id, name)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'name', 'User'));
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
AFTER INSERT ON auth.users
FOR EACH ROW
EXECUTE FUNCTION handle_new_user();

-- 3. auto create personal pantry
CREATE OR REPLACE FUNCTION handle_new_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.pantries (owner_id)
  VALUES (NEW.id);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER on_profile_created
AFTER INSERT ON public.profiles
FOR EACH ROW
EXECUTE FUNCTION handle_new_profile();
