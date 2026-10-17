create or replace function public.respond_to_trade_offer(
  p_offer_id uuid,
  p_status text
)
returns void
language plpgsql
security definer
set search_path = public
as $function$
declare
  v_offer public.trade_offers%rowtype;
  v_text text;
begin
  if auth.uid() is null then
    raise exception 'Debes iniciar sesión para responder a una propuesta';
  end if;

  if p_status not in ('accepted', 'rejected') then
    raise exception 'Estado de propuesta no válido';
  end if;

  select *
  into v_offer
  from public.trade_offers
  where id = p_offer_id
  for update;

  if not found or v_offer.to_user_id <> auth.uid() then
    raise exception 'No puedes responder a esta propuesta';
  end if;

  if v_offer.status <> 'sent' then
    raise exception 'Esta propuesta ya está respondida';
  end if;

  update public.trade_offers
  set status = p_status
  where id = p_offer_id;

  if v_offer.conversation_id is not null then
    v_text := case
      when p_status = 'accepted'
        then 'He aceptado tu propuesta de intercambio.'
      else
        'He rechazado tu propuesta de intercambio.'
    end;

    insert into public.messages (
      conversation_id,
      sender_id,
      text
    )
    values (
      v_offer.conversation_id,
      auth.uid(),
      v_text
    );
  end if;
end;
$function$;

revoke execute
on function public.respond_to_trade_offer(uuid, text)
from public;

revoke execute
on function public.respond_to_trade_offer(uuid, text)
from anon;

grant execute
on function public.respond_to_trade_offer(uuid, text)
to authenticated;
