-- Recipients can accept or decline offers. Offers may include a listed item.

alter table public.trade_offers
  add column if not exists offered_product_id text,
  add column if not exists offered_product_title text;

drop policy if exists "Recipients can update trade offer status" on public.trade_offers;

create policy "Recipients can update trade offer status"
  on public.trade_offers for update
  to authenticated
  using (auth.uid() = to_user_id)
  with check (auth.uid() = to_user_id);

grant update on public.trade_offers to authenticated;
