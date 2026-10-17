CREATE OR REPLACE FUNCTION public.handle_dispute_reputation_penalty()
RETURNS TRIGGER AS $$
BEGIN
    -- Verificar si la disputa se cierra de forma punitiva contra el causante
    IF (NEW.status = 'closed'::dispute_status AND OLD.status IS DISTINCT FROM NEW.status) THEN
        UPDATE public.profiles
        SET reputation = GREATEST(1.0, COALESCE(reputation, 5.0) - 1.0)
        WHERE id = NEW.raised_by;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enlazar el disparador atómico a la tabla de disputas
DROP TRIGGER IF EXISTS on_dispute_punitive_close ON public.trueke_disputes;
CREATE TRIGGER on_dispute_punitive_close
    AFTER UPDATE ON public.trueke_disputes
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_dispute_reputation_penalty();
