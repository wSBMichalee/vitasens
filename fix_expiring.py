import re

# 1. MIGRATION FILE
mig_path = 'supabase/migrations/20260614183336_add_category_to_expiring_ingredients.sql'
sql = """CREATE OR REPLACE FUNCTION get_expiring_ingredients(p_pantry_id UUID, p_days INTEGER)
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
"""
with open(mig_path, 'w') as f:
    f.write(sql)

# 2. ExpiryChecker.ts
ec_path = 'supabase/functions/manage-pantry/ExpiryChecker.ts'
with open(ec_path, 'r') as f:
    ec = f.read()

ec = ec.replace('  unit: string;\n  expiryDate: string;', '  unit: string;\n  category: string;\n  imageUrl?: string;\n  minimumQuantity?: number;\n  expiryDate: string;')
ec = ec.replace('      unit: row.unit,\n      expiryDate: row.expiry_date,', '      unit: row.unit,\n      category: row.category,\n      imageUrl: row.image_url,\n      minimumQuantity: row.minimum_quantity,\n      expiryDate: row.expiry_date,')

with open(ec_path, 'w') as f:
    f.write(ec)

# 3. pantry_screen.dart (Remove Debug)
ps_path = 'lib/features/pantry/presentation/screens/pantry_screen.dart'
with open(ps_path, 'r') as f:
    ps = f.read()

debug_widget = """        Container(
          color: Colors.red.withValues(alpha: 0.1),
          padding: EdgeInsets.all(8.r),
          child: Text(
            'DEBUG: storage=$_selectedStorage | expiringSoon=${state.expiringSoon.map((i) => "${i.name}:${i.category}").join(", ")} | ingredients=${state.ingredients.map((i) => "${i.name}:${i.category}").join(", ")}',
            style: TextStyle(fontSize: 10.sp, color: Colors.red),
          ),
        ),
"""
ps = ps.replace(debug_widget, '')

with open(ps_path, 'w') as f:
    f.write(ps)

print("Python script completed.")
