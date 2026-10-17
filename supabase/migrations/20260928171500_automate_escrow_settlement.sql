CREATE OR REPLACE FUNCTION public.handle_trueke_escrow_settlement()
RETURNS TRIGGER AS $$
BEGIN
    -- Si el trueke se completa con éxito, liberamos los fondos retenidos
    IF (NEW.status = 'completed'::trueke_status) THEN
        UPDATE public.trueke_escrow_ledger
        SET status = 'released'::escrow_ledger_status,
            updated_at = timezone('utc'::text, now())
        WHERE trueke_id = NEW.id AND status = 'held'::escrow_ledger_status;
    
    -- Si el trueke se cancela, reembolsamos el colateral en garantía
    ELSIF (NEW.status = 'cancelled'::trueke_status) THEN
        UPDATE public.trueke_escrow_ledger
        SET status = 'refunded'::escrow_ledger_status,
            updated_at = timezone('utc'::text, now())
        WHERE trueke_id = NEW.id AND status = 'held'::escrow_ledger_status;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Enlazar el trigger reactivo a la tabla de truekes principal
DROP TRIGGER IF EXISTS on_trueke_financial_settlement ON public.truekes;
CREATE TRIGGER on_trueke_financial_settlement
    AFTER UPDATE ON public.truekes
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_trueke_escrow_settlement();
