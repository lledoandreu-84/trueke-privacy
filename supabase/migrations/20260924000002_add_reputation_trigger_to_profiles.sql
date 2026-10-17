-- Reparar y definir función PL/pgSQL para recalcular la reputación de forma automatizada
CREATE OR REPLACE FUNCTION public.handle_recalculate_user_reputation()
RETURNS TRIGGER AS $$
BEGIN
    -- Lógica para recalcular la reputación promedio del perfil afectado
    UPDATE public.profiles
    SET reputation = (
        SELECT COALESCE(AVG(rating), 5.0)
        FROM public.user_reviews
        WHERE reviewed_user_id = NEW.reviewed_user_id
    )
    WHERE id = NEW.reviewed_user_id;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Recrear el trigger de forma segura asegurando consistencia catastral
DROP TRIGGER IF EXISTS on_review_inserted ON public.user_reviews;
CREATE TRIGGER on_review_inserted
    AFTER INSERT OR UPDATE ON public.user_reviews
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_recalculate_user_reputation();
