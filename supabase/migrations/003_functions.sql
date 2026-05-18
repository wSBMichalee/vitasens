-- === ROZSZERZENIA ===
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- === HELPER FUNKCJE SQL ===

-- 1. Sprawdza aktywną subskrypcję
CREATE OR REPLACE FUNCTION has_active_subscription(user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  has_access BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = user_id
    AND (
      (subscription_status = 'trialing' AND trial_expires_at > now())
      OR (subscription_status = 'active' AND subscription_expires_at > now())
    )
  ) INTO has_access;
  
  RETURN has_access;
END;
$$;

-- 2. Sprawdza family add-on
CREATE OR REPLACE FUNCTION has_family_addon(user_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  has_addon BOOLEAN;
BEGIN
  IF NOT has_active_subscription(user_id) THEN
    RETURN FALSE;
  END IF;

  SELECT EXISTS (
    SELECT 1 FROM profiles
    WHERE id = user_id
    AND family_addon = true
    AND family_addon_expires_at > now()
  ) INTO has_addon;

  RETURN has_addon;
END;
$$;

-- 3. Zwraca liczbę dni do końca trialu
CREATE OR REPLACE FUNCTION get_trial_days_remaining(user_id UUID)
RETURNS INTEGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  days_remaining INTEGER;
BEGIN
  SELECT GREATEST(0, CEIL(EXTRACT(EPOCH FROM (trial_expires_at - now())) / 86400))
  INTO days_remaining
  FROM profiles
  WHERE id = user_id;
  
  RETURN COALESCE(days_remaining, 0);
END;
$$;

-- 4. Pobiera dzienne makro
CREATE OR REPLACE FUNCTION get_daily_macros(p_user_id UUID, p_date DATE)
RETURNS TABLE(
  total_protein NUMERIC,
  total_carbs NUMERIC,
  total_fat NUMERIC,
  total_calories INTEGER,
  meals_count INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT 
    COALESCE(SUM(protein_g), 0),
    COALESCE(SUM(carbs_g), 0),
    COALESCE(SUM(fat_g), 0),
    COALESCE(SUM(calories), 0)::INTEGER,
    COUNT(*)::INTEGER
  FROM meals
  WHERE user_id = p_user_id AND meal_date = p_date;
END;
$$;

-- 5. Zwraca przeterminowane produkty
CREATE OR REPLACE FUNCTION get_expiring_ingredients(p_pantry_id UUID, p_days INTEGER)
RETURNS TABLE(
  id UUID,
  name TEXT,
  quantity NUMERIC,
  unit TEXT,
  expiry_date DATE,
  days_until_expiry INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT i.id, i.name, i.quantity, i.unit, i.expiry_date,
    (i.expiry_date - CURRENT_DATE)::INTEGER as days_until_expiry
  FROM ingredients i
  WHERE i.pantry_id = p_pantry_id
  AND i.expiry_date IS NOT NULL
  AND i.expiry_date <= CURRENT_DATE + p_days
  ORDER BY i.expiry_date ASC;
END;
$$;

-- 6. Sprawdza czy użytkownik jest właścicielem rodziny
CREATE OR REPLACE FUNCTION is_family_owner(p_user_id UUID, p_family_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  is_owner BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM families
    WHERE id = p_family_id AND owner_id = p_user_id
  ) INTO is_owner;
  
  RETURN is_owner;
END;
$$;

-- 7. Sprawdza czy użytkownik jest członkiem rodziny
CREATE OR REPLACE FUNCTION is_family_member(p_user_id UUID, p_family_id UUID)
RETURNS BOOLEAN
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  is_member BOOLEAN;
BEGIN
  SELECT EXISTS (
    SELECT 1 FROM family_members
    WHERE family_id = p_family_id AND user_id = p_user_id
  ) INTO is_member;
  
  RETURN is_member;
END;
$$;


-- === TRIGGERY NA SHOPPING LIST ===

-- 8. Dodaje do listy po obniżeniu zapasów
CREATE OR REPLACE FUNCTION fn_add_to_shopping_list_on_low_stock()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owner_id UUID;
  v_family_id UUID;
  v_exists BOOLEAN;
BEGIN
  IF NEW.minimum_quantity > 0 AND NEW.quantity <= NEW.minimum_quantity AND OLD.quantity > OLD.minimum_quantity THEN
    
    SELECT owner_id, family_id INTO v_owner_id, v_family_id
    FROM pantries
    WHERE id = NEW.pantry_id;

    SELECT EXISTS (
      SELECT 1 FROM shopping_list
      WHERE ingredient_name = NEW.name
      AND is_purchased = false
      AND (user_id = v_owner_id OR family_id = v_family_id)
    ) INTO v_exists;

    IF NOT v_exists THEN
      INSERT INTO shopping_list (
        user_id, family_id, ingredient_name, quantity_needed, unit,
        added_automatically, source
      ) VALUES (
        v_owner_id, v_family_id, NEW.name, NEW.minimum_quantity, NEW.unit,
        true, 'low_stock'
      );
    END IF;
  END IF;
  
  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_low_stock
AFTER UPDATE ON ingredients
FOR EACH ROW EXECUTE FUNCTION fn_add_to_shopping_list_on_low_stock();

-- 9. Dodaje do listy po usunięciu
CREATE OR REPLACE FUNCTION fn_add_to_shopping_list_on_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owner_id UUID;
  v_family_id UUID;
  v_exists BOOLEAN;
BEGIN
  SELECT owner_id, family_id INTO v_owner_id, v_family_id
  FROM pantries
  WHERE id = OLD.pantry_id;

  SELECT EXISTS (
    SELECT 1 FROM shopping_list
    WHERE ingredient_name = OLD.name
    AND is_purchased = false
    AND (user_id = v_owner_id OR family_id = v_family_id)
  ) INTO v_exists;

  IF NOT v_exists THEN
    INSERT INTO shopping_list (
      user_id, family_id, ingredient_name, quantity_needed, unit,
      added_automatically, source
    ) VALUES (
      v_owner_id, v_family_id, OLD.name, COALESCE(OLD.minimum_quantity, 1), OLD.unit,
      true, 'low_stock'
    );
  END IF;

  RETURN OLD;
END;
$$;

CREATE TRIGGER trg_ingredient_deleted
AFTER DELETE ON ingredients
FOR EACH ROW EXECUTE FUNCTION fn_add_to_shopping_list_on_delete();

-- 10. Dodaje przeterminowane do listy
CREATE OR REPLACE FUNCTION fn_add_expired_to_shopping_list()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
DECLARE
  v_owner_id UUID;
  v_family_id UUID;
  v_exists BOOLEAN;
BEGIN
  IF NEW.expiry_date IS NOT NULL AND NEW.expiry_date < CURRENT_DATE AND OLD.expiry_date >= CURRENT_DATE THEN
    SELECT owner_id, family_id INTO v_owner_id, v_family_id
    FROM pantries
    WHERE id = NEW.pantry_id;

    SELECT EXISTS (
      SELECT 1 FROM shopping_list
      WHERE ingredient_name = NEW.name
      AND is_purchased = false
      AND (user_id = v_owner_id OR family_id = v_family_id)
    ) INTO v_exists;

    IF NOT v_exists THEN
      INSERT INTO shopping_list (
        user_id, family_id, ingredient_name, quantity_needed, unit,
        added_automatically, source
      ) VALUES (
        v_owner_id, v_family_id, NEW.name, COALESCE(NEW.minimum_quantity, 1), NEW.unit,
        true, 'expired'
      );
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

CREATE TRIGGER trg_ingredient_expired
AFTER UPDATE ON ingredients
FOR EACH ROW EXECUTE FUNCTION fn_add_expired_to_shopping_list();


-- === CRON JOB (pg_cron) ===

-- 11. Scheduled job — codziennie o 8:00 rano
SELECT cron.schedule(
  'check-expired-ingredients',
  '0 8 * * *',
  $$
    INSERT INTO shopping_list (
      user_id, family_id, ingredient_name,
      quantity_needed, unit,
      added_automatically, source
    )
    SELECT 
      p.owner_id,
      p.family_id,
      i.name,
      i.quantity,
      i.unit,
      true,
      'expired'
    FROM ingredients i
    JOIN pantries p ON i.pantry_id = p.id
    WHERE i.expiry_date < CURRENT_DATE
    AND NOT EXISTS (
      SELECT 1 FROM shopping_list sl
      WHERE sl.ingredient_name = i.name
      AND sl.is_purchased = false
      AND (sl.user_id = p.owner_id OR sl.family_id = p.family_id)
    )
  $$
);

-- ============================================================
-- manage-user-recipes: likes counter triggers
-- ============================================================

CREATE OR REPLACE FUNCTION increment_recipe_likes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE recipes
  SET likes_count = likes_count + 1
  WHERE id = NEW.recipe_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE OR REPLACE FUNCTION decrement_recipe_likes()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE recipes
  SET likes_count = GREATEST(0, likes_count - 1)
  WHERE id = OLD.recipe_id;
  RETURN OLD;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trg_increment_likes
  AFTER INSERT ON recipe_likes
  FOR EACH ROW EXECUTE FUNCTION increment_recipe_likes();

CREATE TRIGGER trg_decrement_likes
  AFTER DELETE ON recipe_likes
  FOR EACH ROW EXECUTE FUNCTION decrement_recipe_likes();
