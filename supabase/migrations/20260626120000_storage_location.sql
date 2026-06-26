ALTER TABLE ingredients
  ADD COLUMN IF NOT EXISTS storage_location TEXT
  CHECK (storage_location IN ('fridge', 'freezer', 'pantry'))
  DEFAULT 'fridge';

-- Ustaw domyślne wartości dla istniejących produktów na podstawie kategorii
UPDATE ingredients SET storage_location = 'pantry'
  WHERE category IN ('grains', 'other', 'cereal', 'chocolate', 'drinks', 'bread', 'condiments', 'spices');

UPDATE ingredients SET storage_location = 'freezer'
  WHERE category IN ('frozen');

-- Reszta zostaje 'fridge' (default)
