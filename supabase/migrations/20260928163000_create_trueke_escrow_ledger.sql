-- Crear tipo enumerado para el flujo financiero del depósito colateral
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'escrow_ledger_status') THEN
        CREATE TYPE escrow_ledger_status AS ENUM ('held', 'released', 'refunded');
    END IF;
END $$;

-- Tabla para el control atómico de fondos en garantía
CREATE TABLE IF NOT EXISTS public.trueke_escrow_ledger (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    trueke_id UUID REFERENCES public.truekes(id) ON DELETE RESTRICT NOT NULL,
    amount NUMERIC(10, 2) NOT NULL CHECK (amount >= 0),
    status escrow_ledger_status DEFAULT 'held'::escrow_ledger_status NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar Seguridad a Nivel de Fila (RLS)
ALTER TABLE public.trueke_escrow_ledger ENABLE ROW LEVEL SECURITY;

-- Políticas de aislamiento para asegurar la transparencia financiera de las partes
CREATE POLICY "Usuarios pueden auditar los depósitos de sus truekes" 
    ON public.trueke_escrow_ledger FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.truekes t
            WHERE t.id = trueke_escrow_ledger.trueke_id 
            AND (auth.uid() = t.sender_id OR auth.uid() = t.receiver_id)
        )
    );
