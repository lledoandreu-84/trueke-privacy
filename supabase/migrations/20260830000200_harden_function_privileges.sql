-- Restrict exposed database functions and force trade mutations through
-- the validated RPCs.

-- SECURITY DEFINER functions are callable through the Data API unless their
-- EXECUTE privilege is explicitly restricted.
revoke execute on function public.create_trade_offer(text, text, text)
  from public, anon;
revoke execute on function public.respond_to_trade_offer(uuid, text)
  from public, anon;
revoke execute on function public.validate_trade_offer_insert()
  from public, anon, authenticated;
revoke execute on function public.validate_trade_offer_update()
  from public, anon, authenticated;

grant execute on function public.create_trade_offer(text, text, text)
  to authenticated;
grant execute on function public.respond_to_trade_offer(uuid, text)
  to authenticated;

-- Pin SECURITY DEFINER functions to an empty search_path. Their database
-- relations are already schema-qualified in the function bodies.
alter function public.create_trade_offer(text, text, text)
  set search_path = '';
alter function public.respond_to_trade_offer(uuid, text)
  set search_path = '';
alter function public.validate_trade_offer_insert()
  set search_path = '';
alter function public.validate_trade_offer_update()
  set search_path = '';

-- Trade offers are created and transitioned only through the validated RPCs.
-- Reads remain available to authenticated users through the existing RLS policy.
revoke insert, update, delete on public.trade_offers from authenticated;
grant select on public.trade_offers to authenticated;

-- Profiles are private and owner-scoped.
revoke all on public.profiles from anon, authenticated;
grant select, insert, update on public.profiles to authenticated;
