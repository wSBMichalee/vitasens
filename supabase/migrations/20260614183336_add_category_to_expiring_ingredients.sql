DROP FUNCTION IF EXISTS get_expiring_ingredients(UUID, INTEGER);

CREATE OR REPLACE FUNCTION get_expiring_ingredients(p_pantry_id UUID, p_days INTEGER)
RETURNS TABLE(
  id UUID,
  name TEXT,
  quantity NUMERIC,
  unit TEXT,
  category TEXT,
  expiry_date DATE,
  image_url TEXT,
  minimum_quantity NUMERIC,
  days_until_expiry INTEGER
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public
AS $$
BEGIN
  RETURN QUERY
  SELECT i.id, i.name, i.quantity, i.unit, i.category, i.expiry_date,
    i.image_url, i.minimum_quantity,
    (i.expiry_date - CURRENT_DATE)::INTEGER as days_until_expiry
  FROM ingredients i
  WHERE i.pantry_id = p_pantry_id
  AND i.expiry_date IS NOT NULL
  AND i.expiry_date <= CURRENT_DATE + p_days
  ORDER BY i.expiry_date ASC;
END;
$$;
