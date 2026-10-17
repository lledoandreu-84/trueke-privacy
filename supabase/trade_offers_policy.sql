-- 1. Habilitar de forma explícita el sistema RLS en la tabla de ofertas
ALTER TABLE trade_offers ENABLE ROW LEVEL SECURITY;

-- 2. Eliminar política previa si existiese para evitar colisiones
DROP POLICY IF EXISTS "Los usuarios solo ven sus propios intercambios emisor/receptor" ON trade_offers;

-- 3. Crear la política con la validación exacta de IDs relacionales frente al token de autenticación
CREATE POLICY "Los usuarios solo ven sus propios intercambios emisor/receptor"
ON trade_offers
FOR SELECT
TO authenticated
USING (
  (auth.uid() = from_user_id) OR (auth.uid() = to_user_id)
);

-- 4. Eliminar política de inserción previa si existiese
DROP POLICY IF EXISTS "Los usuarios solo pueden crear intercambios siendo emisores" ON trade_offers;

-- 5. Crear la política con la validación de inserción exacta en el WITH CHECK
CREATE POLICY "Los usuarios solo pueden crear intercambios siendo emisores"
ON trade_offers
FOR INSERT
TO authenticated
WITH CHECK (
  auth.uid() = from_user_id
);
