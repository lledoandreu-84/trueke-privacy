-- Restrict SECURITY DEFINER RPC functions to service_role.
-- These functions perform privileged database operations and must not
-- be directly executable by authenticated API clients.

REVOKE EXECUTE ON FUNCTION public.create_trade_offer(text, text, text)
FROM PUBLIC, anon, authenticated;

REVOKE EXECUTE ON FUNCTION public.respond_to_trade_offer(uuid, text)
FROM PUBLIC, anon, authenticated;

GRANT EXECUTE ON FUNCTION public.create_trade_offer(text, text, text)
TO service_role;

GRANT EXECUTE ON FUNCTION public.respond_to_trade_offer(uuid, text)
TO service_role;
