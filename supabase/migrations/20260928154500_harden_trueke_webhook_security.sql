CREATE OR REPLACE FUNCTION public.notify_trueke_status_change()
RETURNS TRIGGER AS $$
DECLARE
    signing_key TEXT := 'TruekeCryptoSignatureSecureKey2026AtomicSecret';
    payload_text TEXT;
    computed_signature TEXT;
BEGIN
    IF (OLD.status IS DISTINCT FROM NEW.status) THEN
        -- Construir el cuerpo JSON exacto
        payload_text := jsonb_build_object(
            'trueke_id', NEW.id,
            'sender_id', NEW.sender_id,
            'receiver_id', NEW.receiver_id,
            'action', 'STATUS_CHANGED',
            'new_status', NEW.status
        )::text;

        -- Calcular la firma criptográfica HMAC-SHA256 nativa de Postgres
        computed_signature := extensions.hmac(payload_text, signing_key, 'sha256');

        -- Despachar la petición HTTP incluyendo la firma digital en los headers
        PERFORM net.http_post(
            url := CONCAT(current_setting('app.settings.supabase_url', true), '/functions/v1/process-trueke'),
            headers := jsonb_build_object(
                'Content-Type', 'application/json',
                'Authorization', CONCAT('Bearer ', current_setting('app.settings.jwt_secret', true)),
                'X-Trueke-Signature', computed_signature
            ),
            body := payload_text,
            timeout_milliseconds := 5000
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
