-- === PROFILES ===
-- Chroni dane użytkownika przed innymi
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" 
ON profiles FOR SELECT 
USING (id = auth.uid());

CREATE POLICY "Users can insert own profile" 
ON profiles FOR INSERT 
WITH CHECK (id = auth.uid());

CREATE POLICY "Users can update own profile" 
ON profiles FOR UPDATE 
USING (id = auth.uid());

CREATE POLICY "Users can delete own profile" 
ON profiles FOR DELETE 
USING (id = auth.uid());


-- === FAMILIES ===
-- Zarządzanie widocznością i dostępem do rodziny
ALTER TABLE families ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view families they are part of or own" 
ON families FOR SELECT 
USING (
  owner_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM family_members 
    WHERE family_members.family_id = families.id 
    AND family_members.user_id = auth.uid()
  )
);

CREATE POLICY "Anyone logged in can create a family" 
ON families FOR INSERT 
WITH CHECK (auth.uid() IS NOT NULL);

CREATE POLICY "Only owners can update family" 
ON families FOR UPDATE 
USING (owner_id = auth.uid());

CREATE POLICY "Only owners can delete family" 
ON families FOR DELETE 
USING (owner_id = auth.uid());


-- === FAMILY_MEMBERS ===
-- Dostęp do członków rodziny
ALTER TABLE family_members ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view members of their families" 
ON family_members FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM family_members AS fm 
    WHERE fm.family_id = family_members.family_id 
    AND fm.user_id = auth.uid()
  )
);

CREATE POLICY "Only family owners can insert members" 
ON family_members FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM families 
    WHERE families.id = family_members.family_id 
    AND families.owner_id = auth.uid()
  )
);

CREATE POLICY "Only family owners can update members" 
ON family_members FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM families 
    WHERE families.id = family_members.family_id 
    AND families.owner_id = auth.uid()
  )
);

CREATE POLICY "Owners can delete anyone, members can delete themselves" 
ON family_members FOR DELETE 
USING (
  user_id = auth.uid() OR
  EXISTS (
    SELECT 1 FROM families 
    WHERE families.id = family_members.family_id 
    AND families.owner_id = auth.uid()
  )
);


-- === PANTRIES ===
-- Dostęp do spiżarni
ALTER TABLE pantries ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view personal or family pantries" 
ON pantries FOR SELECT 
USING (
  owner_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM family_members 
    WHERE family_members.family_id = pantries.family_id 
    AND family_members.user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert personal, owners can insert family pantries" 
ON pantries FOR INSERT 
WITH CHECK (
  owner_id = auth.uid() OR
  (
    family_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM families 
      WHERE families.id = pantries.family_id 
      AND families.owner_id = auth.uid()
    )
  )
);

CREATE POLICY "Users can update personal, owners can update family pantries" 
ON pantries FOR UPDATE 
USING (
  owner_id = auth.uid() OR
  (
    family_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM families 
      WHERE families.id = pantries.family_id 
      AND families.owner_id = auth.uid()
    )
  )
);

CREATE POLICY "Users can delete personal, owners can delete family pantries" 
ON pantries FOR DELETE 
USING (
  owner_id = auth.uid() OR
  (
    family_id IS NOT NULL AND EXISTS (
      SELECT 1 FROM families 
      WHERE families.id = pantries.family_id 
      AND families.owner_id = auth.uid()
    )
  )
);


-- === INGREDIENTS ===
-- Dostęp do składników w spiżarni
ALTER TABLE ingredients ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view ingredients in accessible pantries" 
ON ingredients FOR SELECT 
USING (
  EXISTS (
    SELECT 1 FROM pantries 
    WHERE pantries.id = ingredients.pantry_id 
    AND (
      pantries.owner_id = auth.uid() OR 
      EXISTS (
        SELECT 1 FROM family_members 
        WHERE family_members.family_id = pantries.family_id 
        AND family_members.user_id = auth.uid()
      )
    )
  )
);

CREATE POLICY "Users can insert ingredients into accessible pantries" 
ON ingredients FOR INSERT 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM pantries 
    WHERE pantries.id = ingredients.pantry_id 
    AND (
      pantries.owner_id = auth.uid() OR 
      EXISTS (
        SELECT 1 FROM family_members 
        WHERE family_members.family_id = pantries.family_id 
        AND family_members.user_id = auth.uid()
      )
    )
  )
);

CREATE POLICY "Users can update ingredients in accessible pantries" 
ON ingredients FOR UPDATE 
USING (
  EXISTS (
    SELECT 1 FROM pantries 
    WHERE pantries.id = ingredients.pantry_id 
    AND (
      pantries.owner_id = auth.uid() OR 
      EXISTS (
        SELECT 1 FROM family_members 
        WHERE family_members.family_id = pantries.family_id 
        AND family_members.user_id = auth.uid()
      )
    )
  )
);

CREATE POLICY "Users can delete ingredients in accessible pantries" 
ON ingredients FOR DELETE 
USING (
  EXISTS (
    SELECT 1 FROM pantries 
    WHERE pantries.id = ingredients.pantry_id 
    AND (
      pantries.owner_id = auth.uid() OR 
      EXISTS (
        SELECT 1 FROM family_members 
        WHERE family_members.family_id = pantries.family_id 
        AND family_members.user_id = auth.uid()
      )
    )
  )
);


-- === MEALS ===
-- Posilki usera
ALTER TABLE meals ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own meals" 
ON meals FOR SELECT 
USING (user_id = auth.uid());

CREATE POLICY "Users can insert own meals" 
ON meals FOR INSERT 
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own meals" 
ON meals FOR UPDATE 
USING (user_id = auth.uid());

CREATE POLICY "Users can delete own meals" 
ON meals FOR DELETE 
USING (user_id = auth.uid());


-- === RECIPES ===
-- Publiczne przepisy
ALTER TABLE recipes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view recipes" 
ON recipes FOR SELECT 
USING (true);

-- Insert, update, delete are handled by service role which bypasses RLS


-- === FAVORITE_RECIPES ===
-- Ulubione przepisy usera
ALTER TABLE favorite_recipes ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own favorite recipes" 
ON favorite_recipes FOR SELECT 
USING (user_id = auth.uid());

CREATE POLICY "Users can insert own favorite recipes" 
ON favorite_recipes FOR INSERT 
WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own favorite recipes" 
ON favorite_recipes FOR DELETE 
USING (user_id = auth.uid());


-- === SHOPPING_LIST ===
-- Prywatne i rodzinne listy zakupów
ALTER TABLE shopping_list ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view accessible shopping list items" 
ON shopping_list FOR SELECT 
USING (
  user_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM family_members 
    WHERE family_members.family_id = shopping_list.family_id 
    AND family_members.user_id = auth.uid()
  )
);

CREATE POLICY "Users can insert accessible shopping list items" 
ON shopping_list FOR INSERT 
WITH CHECK (
  user_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM family_members 
    WHERE family_members.family_id = shopping_list.family_id 
    AND family_members.user_id = auth.uid()
  )
);

CREATE POLICY "Users can update accessible shopping list items" 
ON shopping_list FOR UPDATE 
USING (
  user_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM family_members 
    WHERE family_members.family_id = shopping_list.family_id 
    AND family_members.user_id = auth.uid()
  )
);

CREATE POLICY "Users can delete accessible shopping list items" 
ON shopping_list FOR DELETE 
USING (
  user_id = auth.uid() OR 
  EXISTS (
    SELECT 1 FROM family_members 
    WHERE family_members.family_id = shopping_list.family_id 
    AND family_members.user_id = auth.uid()
  )
);
