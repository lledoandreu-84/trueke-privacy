-- Nueva política quirúrgica para permitir cancelaciones y reembolsos controlados desde el cliente
CREATE POLICY "Usuarios participantes pueden cancelar y reembolsar el escrow" 
ON public.escrow_transactions 
FOR UPDATE 
TO authenticated
USING (
    (auth.uid() = buyer_id OR auth.uid() = seller_id) 
    AND (status = 'pending_deposit' OR status = 'held_in_escrow')
)
WITH CHECK (
    (auth.uid() = buyer_id OR auth.uid() = seller_id)
    AND status = 'refunded'
    AND id = id
    AND trade_offer_id = trade_offer_id
    AND buyer_id = buyer_id
    AND seller_id = seller_id
    AND amount = amount
    AND currency = currency
    AND stripe_payment_intent_id = stripe_payment_intent_id
);
