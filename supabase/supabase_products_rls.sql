-- 1. Habilitar la seguridad a nivel de fila (RLS) de forma explícita
ALTER TABLE products ENABLE ROW LEVEL SECURITY;

-- 2. Política de Lectura: Cualquiera puede ver los productos del feed
CREATE POLICY "Permitir lectura pública de productos" 
ON products FOR SELECT 
USING (true);

-- 3. Política de Inserción: Un usuario solo puede publicar productos bajo su propio ID
CREATE POLICY "Permitir inserción solo a usuarios autenticados dueños" 
ON products FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid()::text = ownerId);

-- 4. Política de Actualización: Solo el dueño original puede modificar su producto
CREATE POLICY "Permitir actualización exclusivamente al dueño" 
ON products FOR UPDATE 
TO authenticated 
USING (auth.uid()::text = ownerId)
WITH CHECK (auth.uid()::text = ownerId);

-- 5. Política de Borrado: Solo el dueño original puede eliminar su producto
CREATE POLICY "Permitir borrado exclusivamente al dueño" 
ON products FOR DELETE 
TO authenticated 
USING (auth.uid()::text = ownerId);
