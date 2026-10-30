-- Añadir campos de consentimiento legal en la tabla de perfiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS terms_accepted_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS privacy_accepted_at TIMESTAMPTZ;

-- Documentación de columnas
COMMENT ON COLUMN public.profiles.terms_accepted_at IS 'Marca de tiempo de la aceptación de Términos y Condiciones';
COMMENT ON COLUMN public.profiles.privacy_accepted_at IS 'Marca de tiempo de la aceptación de la Política de Privacidad';
