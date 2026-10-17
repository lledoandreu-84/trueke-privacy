revoke all
on function public.create_trade_offer(text, text, text)
from public;

revoke all
on function public.create_trade_offer(text, text, text)
from authenticated;

grant execute
on function public.create_trade_offer(text, text, text)
to authenticated;


revoke all
on function public.respond_to_trade_offer(uuid, text)
from public;

revoke all
on function public.respond_to_trade_offer(uuid, text)
from authenticated;

grant execute
on function public.respond_to_trade_offer(uuid, text)
to authenticated;
