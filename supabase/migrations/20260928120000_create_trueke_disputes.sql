-- Crear tipo enumerado para los estados de la mediación si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'dispute_status') THEN
        CREATE TYPE dispute_status AS ENUM ('opened', 'under_review', 'resolved', 'closed');
    END IF;
END $$;

-- Crear tabla de control de disputas financieras y operativas
CREATE TABLE IF NOT EXISTS public.trueke_disputes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    trueke_id UUID REFERENCES public.truekes(id) ON DELETE CASCADE NOT NULL,
    raised_by UUID REFERENCES auth.users(id) ON DELETE RESTRICT NOT NULL,
    reason TEXT NOT NULL,
    status dispute_status DEFAULT 'opened'::dispute_status NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar Seguridad a Nivel de Fila (RLS)
ALTER TABLE public.trueke_disputes ENABLE ROW LEVEL SECURITY;

-- Crear políticas de aislamiento estricto
CREATE POLICY "Usuarios pueden ver disputas de sus propios truekes" 
    ON public.trueke_disputes FOR SELECT 
    USING (
        EXISTS (
            SELECT 1 FROM public.truekes t
            WHERE t.id = trueke_disputes.trueke_id 
            AND (auth.uid() = t.sender_id OR auth.uid() = t.receiver_id)
        )
    );

CREATE POLICY "Usuarios involucrados pueden iniciar una disputa" 
    ON public.trueke_disputes FOR INSERT 
    WITH CHECK (
        auth.uid() = raised_by 
        AND EXISTS (
            SELECT 1 FROM public.truekes t
            WHERE t.id = trueke_disputes.trueke_id 
            AND (auth.uid() = t.sender_id OR auth.uid() = t.receiver_id)
        )
    );
