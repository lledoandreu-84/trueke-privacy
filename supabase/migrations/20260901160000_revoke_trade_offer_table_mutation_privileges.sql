-- Keep trade-offer mutations behind the validated SECURITY DEFINER RPCs.
-- Authenticated clients may read offers but must not mutate them directly.

REVOKE INSERT, UPDATE, DELETE
ON TABLE public.trade_offers
FROM authenticated;

GRANT SELECT
ON TABLE public.trade_offers
TO authenticated;
