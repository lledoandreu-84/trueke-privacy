-- 1. Crear tipo enumerado para los estados del depósito seguro si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'escrow_status') THEN
        CREATE TYPE escrow_status AS ENUM (
            'pending_deposit', 
            'held_in_escrow', 
            'shipped', 
            'delivered', 
            'released', 
            'refunded'
        );
    END IF;
END $$;

-- 2. Crear la tabla de transacciones de custodia
CREATE TABLE IF NOT EXISTS public.escrow_transactions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trade_offer_id UUID NOT NULL, -- Relación directa con la oferta de trueque (tabla intermedia)
    buyer_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    seller_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE RESTRICT,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    currency VARCHAR(3) NOT NULL DEFAULT 'EUR',
    status escrow_status NOT NULL DEFAULT 'pending_deposit',
    stripe_payment_intent_id VARCHAR(255) NOT NULL,
    stripe_transfer_id VARCHAR(255),
    tracking_number VARCHAR(100),
    carrier VARCHAR(100),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT TIMEZONE('utc'::text, NOW()) NOT NULL
);

-- 3. Habilitar la seguridad de fila (RLS) de forma mandatoria
ALTER TABLE public.escrow_transactions ENABLE ROW LEVEL SECURITY;

-- 4. Definir políticas de acceso restrictivas (Solo comprador y vendedor implicados pueden leer)
CREATE POLICY "Usuarios pueden visualizar sus propias transacciones de custodia" 
ON public.escrow_transactions 
FOR SELECT 
USING (auth.uid() = buyer_id OR auth.uid() = seller_id);

CREATE POLICY "Solo los compradores implicados pueden inicializar la transacción" 
ON public.escrow_transactions 
FOR INSERT 
WITH CHECK (auth.uid() = buyer_id);

CREATE POLICY "Comprador o vendedor pueden actualizar parámetros según su rol" 
ON public.escrow_transactions 
FOR UPDATE 
USING (auth.uid() = buyer_id OR auth.uid() = seller_id);
