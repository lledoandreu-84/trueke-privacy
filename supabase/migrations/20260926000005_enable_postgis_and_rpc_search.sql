-- Habilitar la extensión PostGIS si no está activa
CREATE EXTENSION IF NOT EXISTS postgis SCHEMA extensions;

-- Añadir la columna de geografía nativa Point de forma segura defensiva
DO $$ 
BEGIN
    IF NOT EXISTS (SELECT 1 FROM information_schema.columns WHERE table_schema='public' AND table_name='products' AND column_name='geo_location') THEN
        ALTER TABLE public.products ADD COLUMN geo_location extensions.geography(Point, 4326);
    END IF;
END $$;

-- Crear índice espacial GIST si no existe para búsquedas ultrarrápidas por proximidad
CREATE INDEX IF NOT EXISTS products_geo_location_idx ON public.products USING gist(geo_location);
