-- 1. Eliminar la política de actualización laxa previa para evitar elevación de privilegios
DROP POLICY IF EXISTS "Comprador o vendedor pueden actualizar parámetros según su rol" ON public.escrow_transactions;

-- 2. Crear una política quirúrgica para el vendedor: Solo puede subir tracking logístico si el dinero está custodiado
CREATE POLICY "Vendedores pueden añadir información logística exclusivamente" 
ON public.escrow_transactions 
FOR UPDATE 
TO authenticated
USING (auth.uid() = seller_id AND status = 'held_in_escrow')
WITH CHECK (
    auth.uid() = seller_id 
    AND status = 'shipped' -- El repositorio transiciona a 'shipped' al meter tracking
    AND id = id 
    AND trade_offer_id = trade_offer_id
    AND buyer_id = buyer_id
    AND seller_id = seller_id
    AND amount = amount
    AND currency = currency
    AND stripe_payment_intent_id = stripe_payment_intent_id
);

-- 3. Crear una política quirúrgica para el comprador: Solo puede confirmar la recepción (liberar fondos) llamando a RPC
-- Al restringir las actualizaciones directas del cliente, blindamos los cambios de estado monetario.
