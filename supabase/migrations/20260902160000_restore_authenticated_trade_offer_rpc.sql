-- Trade offers cannot be mutated via the table API. The Flutter client
-- must execute the validated SECURITY DEFINER RPCs as an authenticated user.
-- A later hardening migration revoked that EXECUTE grant and left only
-- service_role, which breaks create/respond from the app.

revoke execute on function public.create_trade_offer(text, text, text)
  from public, anon;

revoke execute on function public.respond_to_trade_offer(uuid, text)
  from public, anon;

grant execute on function public.create_trade_offer(text, text, text)
  to authenticated, service_role;

grant execute on function public.respond_to_trade_offer(uuid, text)
  to authenticated, service_role;
