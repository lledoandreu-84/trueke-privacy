-- =========================================================================
-- BLINDAJE DE SEGURIDAD NATIVA PARA SALAS DE CHAT (chat_rooms)
-- =========================================================================
ALTER TABLE chat_rooms ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir acceso a salas propias" 
ON chat_rooms FOR SELECT 
TO authenticated 
USING (auth.uid()::text = buyer_id OR auth.uid()::text = seller_id);

CREATE POLICY "Permitir creación de salas a participantes" 
ON chat_rooms FOR INSERT 
TO authenticated 
WITH CHECK (auth.uid()::text = buyer_id OR auth.uid()::text = seller_id);

-- =========================================================================
-- BLINDAJE DE SEGURIDAD NATIVA PARA MENSAJES (chat_messages)
-- =========================================================================
ALTER TABLE chat_messages ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir lectura de mensajes si eres miembro de la sala" 
ON chat_messages FOR SELECT 
TO authenticated 
USING (
  EXISTS (
    SELECT 1 FROM chat_rooms 
    WHERE chat_rooms.id = chat_messages.chat_room_id 
    AND (chat_rooms.buyer_id = auth.uid()::text OR chat_rooms.seller_id = auth.uid()::text)
  )
);

CREATE POLICY "Permitir inserción de mensajes si eres miembro de la sala" 
ON chat_messages FOR INSERT 
TO authenticated 
WITH CHECK (
  EXISTS (
    SELECT 1 FROM chat_rooms 
    WHERE chat_rooms.id = chat_messages.chat_room_id 
    AND (chat_rooms.buyer_id = auth.uid()::text OR chat_rooms.seller_id = auth.uid()::text)
  )
);

-- =========================================================================
-- BLINDAJE DE BORRADO PARA CONVERSACIONES (conversations)
-- =========================================================================
ALTER TABLE conversations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Permitir borrado de conversaciones a participantes"
ON conversations FOR DELETE
TO authenticated
USING (auth.uid() = buyer_id OR auth.uid() = seller_id);
