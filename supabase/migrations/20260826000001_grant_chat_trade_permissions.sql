-- Grant table privileges to authenticated users.
-- RLS policies continue to control which rows each user can access.

grant select, insert on public.conversations to authenticated;
grant select, insert on public.messages to authenticated;
grant select, insert on public.trade_offers to authenticated;
