set local check_function_bodies = off;

create or replace function public.create_trade_offer (
  p_product_id         text,
  p_message            text,
  p_offered_product_id text default null::text
)
  returns uuid
  language plpgsql
  security definer
  set search_path to 'public'
  AS $function$
declare
  v_user_id uuid := auth.uid();
  v_product public.products%rowtype;
  v_conversation_id uuid;
  v_offer_id uuid;
  v_message text := trim(coalesce(p_message, ''));
begin
  if v_user_id is null then
    raise exception 'Debes iniciar sesión para enviar una propuesta';
  end if;

  if v_message = '' then
    raise exception 'El mensaje no puede estar vacío';
  end if;

  select *
  into v_product
  from public.products
  where id = p_product_id;

  if not found or v_product.owner_id is null then
    raise exception 'El producto de destino no existe o no tiene propietario';
  end if;

  if v_product.owner_id = v_user_id then
    raise exception 'No puedes crear una propuesta para tu propio producto';
  end if;

  if p_offered_product_id is not null
    and not exists (
      select 1
      from public.products
      where id = p_offered_product_id
        and owner_id = v_user_id
    )
  then
    raise exception 'El producto ofrecido no pertenece al usuario actual';
  end if;

  insert into public.conversations (
    product_id,
    product_title,
    buyer_id,
    seller_id,
    buyer_name,
    seller_name
  )
  values (
    v_product.id,
    v_product.title,
    v_user_id,
    v_product.owner_id,
    coalesce(
      (
        select split_part(email, '@', 1)
        from auth.users
        where id = v_user_id
      ),
      'Usuario'
    ),
    coalesce(v_product.owner, 'Usuario')
  )
  on conflict (product_id, buyer_id)
  do update
  set product_title = excluded.product_title,
      seller_id = excluded.seller_id,
      seller_name = excluded.seller_name
  returning id into v_conversation_id;

  insert into public.messages (
    conversation_id,
    sender_id,
    text
  )
  values (
    v_conversation_id,
    v_user_id,
    v_message
  );

  insert into public.trade_offers (
    product_id,
    product_title,
    from_user_id,
    to_user_id,
    conversation_id,
    message,
    status,
    offered_product_id,
    offered_product_title
  )
  values (
    v_product.id,
    v_product.title,
    v_user_id,
    v_product.owner_id,
    v_conversation_id,
    v_message,
    'sent',
    p_offered_product_id,
    case
      when p_offered_product_id is null then null
      else (
        select title
        from public.products
        where id = p_offered_product_id
      )
    end
  )
  returning id into v_offer_id;

  return v_offer_id;
end;
$function$;

create or replace function public.validate_trade_offer_insert()
  returns trigger
  language plpgsql
  security definer
  set search_path to 'public'
  AS $function$
declare
  product_owner uuid;
  offered_owner uuid;
begin
  if new.from_user_id <> auth.uid() then
    raise exception 'El remitente no coincide con el usuario autenticado';
  end if;

  select owner_id
  into product_owner
  from public.products
  where id = new.product_id;

  if product_owner is null or product_owner <> new.to_user_id then
    raise exception 'El producto de destino no pertenece al destinatario';
  end if;

  if new.from_user_id = new.to_user_id then
    raise exception 'No puedes crear una propuesta para ti mismo';
  end if;

  if new.offered_product_id is not null then
    select owner_id
    into offered_owner
    from public.products
    where id = new.offered_product_id;

    if offered_owner is null or offered_owner <> new.from_user_id then
      raise exception 'El producto ofrecido no pertenece al remitente';
    end if;
  end if;

  return new;
end;
$function$;

create or replace function public.validate_trade_offer_update()
  returns trigger
  language plpgsql
  security definer
  set search_path to 'public'
  AS $function$
begin
  if new.from_user_id <> old.from_user_id
    or new.to_user_id is distinct from old.to_user_id
    or new.product_id <> old.product_id
    or new.product_title <> old.product_title
    or new.conversation_id is distinct from old.conversation_id
    or new.message <> old.message
    or new.offered_product_id is distinct from old.offered_product_id
    or new.offered_product_title is distinct from old.offered_product_title
  then
    raise exception 'Solo se puede modificar el estado de una propuesta';
  end if;

  if old.status <> 'sent'
    or new.status not in ('accepted', 'rejected')
  then
    raise exception 'Transición de estado no permitida';
  end if;

  return new;
end;
$function$;

revoke all on table "public"."profiles" from "anon";

grant maintain, references, trigger, truncate on table "public"."profiles" to "anon";

revoke all on table "public"."trade_offers" from "authenticated";

grant insert, maintain, references, select, trigger, truncate, update on table "public"."trade_offers" to "authenticated";
