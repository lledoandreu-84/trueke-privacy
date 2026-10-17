-- Crear tipo enumerado para los estados de la orden de pago si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'payment_order_status') THEN
        CREATE TYPE payment_order_status AS ENUM ('initiated', 'processing', 'succeeded', 'failed');
    END IF;
END $$;

-- Tabla para el control atómico de intenciones de pago
CREATE TABLE IF NOT EXISTS public.trueke_payment_orders (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    trueke_id UUID REFERENCES public.truekes(id) ON DELETE CASCADE NOT NULL,
    user_id UUID REFERENCES auth.users(id) ON DELETE RESTRICT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount > 0),
    currency TEXT DEFAULT 'EUR' NOT NULL,
    status payment_order_status DEFAULT 'initiated'::payment_order_status NOT NULL,
    external_intent_id TEXT UNIQUE NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar Seguridad a Nivel de Fila (RLS)
ALTER TABLE public.trueke_payment_orders ENABLE ROW LEVEL SECURITY;

-- Políticas de aislamiento estricto para auditoría del usuario
CREATE POLICY "Usuarios pueden auditar sus propias órdenes de pago" 
    ON public.trueke_payment_orders FOR SELECT 
    USING (auth.uid() = user_id);

CREATE POLICY "Usuarios pueden registrar intenciones de pago" 
    ON public.trueke_payment_orders FOR INSERT 
    WITH CHECK (auth.uid() = user_id);
