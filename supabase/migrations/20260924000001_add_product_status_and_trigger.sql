-- 1. Anadir columna de estado a la tabla de productos
alter table public.products 
add column if not exists status text not null default 'available';

-- 2. Crear la funcion PL/pgSQL para gestionar el stock/disponibilidad automaticamente
create or replace function public.handle_trade_offer_status_change()
returns trigger as '
begin
    -- Validar si la oferta ha sido aceptada
    if new.status = ''accepted'' and old.status != ''accepted'' then
        
        -- Marcar el producto principal como intercambiado (no disponible)
        update public.products
        set status = ''traded''
        where id = new.product_id;
        
        -- Si la oferta incluia un producto de cambio, marcarlo tambien como intercambiado
        if new.offered_product_id is not null then
            update public.products
            set status = ''traded''
            where id = new.offered_product_id;
        end if;
        
    -- Validar si una oferta aceptada se cancela o revierte (opcional, para robustez)
    elsif new.status = ''rejected'' and old.status = ''accepted'' then
        
        update public.products
        set status = ''available''
        where id = new.product_id;
        
        if new.offered_product_id is not null then
            update public.products
            set status = ''available''
            where id = new.offered_product_id;
        end if;
    end if;
    
    return new;
end;
' language plpgsql security definer;

-- 3. Crear el Trigger sobre la tabla trade_offers
drop trigger if exists on_trade_offer_status_update on public.trade_offers;
create trigger on_trade_offer_status_update
    after update of status on public.trade_offers
    for each row
    execute function public.handle_trade_offer_status_change();
