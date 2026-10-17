-- Harden private profile access, trade-offer mutations and chat realtime delivery.

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

alter table public.profiles enable row level security;

drop policy if exists "Users can read own profile" on public.profiles;
drop policy if exists "Users can create own profile" on public.profiles;
drop policy if exists "Users can update own profile" on public.profiles;

create policy "Users can read own profile"
  on public.profiles for select
  to authenticated
  using (auth.uid() = id);

create policy "Users can create own profile"
  on public.profiles for insert
  to authenticated
  with check (auth.uid() = id);

create policy "Users can update own profile"
  on public.profiles for update
  to authenticated
  using (auth.uid() = id)
  with check (auth.uid() = id);

create or replace function public.validate_trade_offer_update()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
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

  if old.status <> 'sent' or new.status not in ('accepted', 'rejected') then
    raise exception 'Transición de estado no permitida';
  end if;

  return new;
end;
$$;

drop trigger if exists trade_offers_validate_update on public.trade_offers;
create trigger trade_offers_validate_update
before update on public.trade_offers
for each row execute function public.validate_trade_offer_update();

create or replace function public.validate_trade_offer_insert()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  product_owner uuid;
  offered_owner uuid;
begin
  if new.from_user_id <> auth.uid() then
    raise exception 'El remitente no coincide con el usuario autenticado';
  end if;

  select owner_id into product_owner
  from public.products
  where id = new.product_id;

  if product_owner is null or product_owner <> new.to_user_id then
    raise exception 'El producto de destino no pertenece al destinatario';
  end if;

  if new.from_user_id = new.to_user_id then
    raise exception 'No puedes crear una propuesta para ti mismo';
  end if;

  if new.offered_product_id is not null then
    select owner_id into offered_owner
    from public.products
    where id = new.offered_product_id;

    if offered_owner is null or offered_owner <> new.from_user_id then
      raise exception 'El producto ofrecido no pertenece al remitente';
    end if;
  end if;

  return new;
end;
$$;

drop trigger if exists trade_offers_validate_insert on public.trade_offers;
create trigger trade_offers_validate_insert
before insert on public.trade_offers
for each row execute function public.validate_trade_offer_insert();

create or replace function public.create_trade_offer(
  p_product_id text,
  p_message text,
  p_offered_product_id text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
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

  select * into v_product
  from public.products
  where id = p_product_id;

  if not found or v_product.owner_id is null then
    raise exception 'El producto de destino no existe o no tiene propietario';
  end if;

  if v_product.owner_id = v_user_id then
    raise exception 'No puedes crear una propuesta para tu propio producto';
  end if;

  if p_offered_product_id is not null then
    if not exists (
      select 1
      from public.products
      where id = p_offered_product_id
        and owner_id = v_user_id
    ) then
      raise exception 'El producto ofrecido no pertenece al usuario actual';
    end if;
  end if;

  insert into public.conversations (
    product_id,
    product_title,
    buyer_id,
    seller_id,
    buyer_name,
    seller_name
  ) values (
    v_product.id,
    v_product.title,
    v_user_id,
    v_product.owner_id,
    coalesce((select split_part(email, '@', 1) from auth.users where id = v_user_id), 'Usuario'),
    coalesce(v_product.owner, 'Usuario')
  )
  on conflict (product_id, buyer_id) do update
    set product_title = excluded.product_title,
        seller_id = excluded.seller_id,
        seller_name = excluded.seller_name
  returning id into v_conversation_id;

  insert into public.messages (conversation_id, sender_id, text)
  values (v_conversation_id, v_user_id, v_message);

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
  ) values (
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
      else (select title from public.products where id = p_offered_product_id)
    end
  )
  returning id into v_offer_id;

  return v_offer_id;
end;
$$;

create or replace function public.respond_to_trade_offer(
  p_offer_id uuid,
  p_status text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
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

  select * into v_offer
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
      when p_status = 'accepted' then 'He aceptado tu propuesta de intercambio.'
      else 'He rechazado tu propuesta de intercambio.'
    end;

    insert into public.messages (conversation_id, sender_id, text)
    values (v_offer.conversation_id, auth.uid(), v_text);
  end if;
end;
$$;

revoke update on public.trade_offers from authenticated;
grant execute on function public.create_trade_offer(text, text, text) to authenticated;
grant execute on function public.respond_to_trade_offer(uuid, text) to authenticated;

-- Enable Postgres Changes for chat messages without failing if already enabled.
do $$
begin
  if not exists (
    select 1
    from pg_publication_tables
    where pubname = 'supabase_realtime'
      and schemaname = 'public'
      and tablename = 'messages'
  ) then
    execute 'alter publication supabase_realtime add table public.messages';
  end if;
end;
$$;
