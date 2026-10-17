-- Crear la función PL/pgSQL que invoca el webhook del backend de forma segura
CREATE OR REPLACE FUNCTION public.notify_trueke_status_change()
RETURNS TRIGGER AS $$
BEGIN
    IF (OLD.status IS DISTINCT FROM NEW.status) THEN
        PERFORM net.http_post(
            url := CONCAT(current_setting('app.settings.supabase_url', true), '/functions/v1/process-trueke'),
            headers := jsonb_build_object(
                'Content-Type', 'application/json',
                'Authorization', CONCAT('Bearer ', current_setting('app.settings.jwt_secret', true))
            ),
            body := jsonb_build_object(
                'trueke_id', NEW.id,
                'sender_id', NEW.sender_id,
                'receiver_id', NEW.receiver_id,
                'action', 'STATUS_CHANGED',
                'new_status', NEW.status
            )::text,
            timeout_milliseconds := 5000
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enlazar el disparador atómico a la tabla de intercambios financieros
DROP TRIGGER IF EXISTS on_trueke_status_update ON public.truekes;
CREATE TRIGGER on_trueke_status_update
    AFTER UPDATE ON public.truekes
    FOR EACH ROW
    EXECUTE FUNCTION public.notify_trueke_status_change();
