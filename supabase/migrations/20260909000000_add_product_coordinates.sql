-- Añadir soporte numérico para geolocalización tradicional en la tabla de productos de forma segura
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='products' AND column_name='latitude') THEN
        ALTER TABLE public.products ADD COLUMN latitude double precision NULL;
    END IF;

    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='products' AND column_name='longitude') THEN
        ALTER TABLE public.products ADD COLUMN longitude double precision NULL;
    END IF;
END $$;
