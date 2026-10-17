-- Crear tipo enumerado para los estados del intercambio si no existe
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'trueke_status') THEN
        CREATE TYPE trueke_status AS ENUM ('pending', 'processing', 'completed', 'cancelled');
    END IF;
END $$;

-- Crear tabla de transacciones de Truekes
CREATE TABLE IF NOT EXISTS public.truekes (
    id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
    sender_id UUID REFERENCES auth.users(id) ON DELETE RESTRICT NOT NULL,
    receiver_id UUID REFERENCES auth.users(id) ON DELETE RESTRICT NOT NULL,
    status trueke_status DEFAULT 'pending'::trueke_status NOT NULL,
    created_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT timezone('utc'::text, now()) NOT NULL
);

-- Habilitar Seguridad a Nivel de Fila (RLS)
ALTER TABLE public.truekes ENABLE ROW LEVEL SECURITY;

-- Crear políticas de acceso seguro
CREATE POLICY "Usuarios pueden ver sus propios truekes" 
    ON public.truekes FOR SELECT 
    USING (auth.uid() = sender_id OR auth.uid() = receiver_id);

CREATE POLICY "Usuarios pueden iniciar truekes" 
    ON public.truekes FOR INSERT 
    WITH CHECK (auth.uid() = sender_id);
