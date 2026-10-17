-- Align the products table with the Flutter app and protect ownership.
create table if not exists public.products (
  id text primary key,
  title text not null default '',
  description text not null default '',
  images text[] not null default '{}',
  price numeric,
  trade_type text not null default 'trade',
  category text not null default 'Otros',
  location text not null default '',
  owner text not null default 'Usuario',
  owner_id uuid references auth.users (id) on delete set null,
  condition text not null default 'Usado',
  wanted text not null default '',
  created_at timestamptz not null default now()
);

alter table public.products
  add column if not exists images text[] not null default '{}',
  add column if not exists trade_type text not null default 'trade',
  add column if not exists location text not null default '',
  add column if not exists owner text not null default 'Usuario',
  add column if not exists owner_id uuid references auth.users (id) on delete set null,
  add column if not exists condition text not null default 'Usado',
  add column if not exists wanted text not null default '';

alter table public.products enable row level security;

drop policy if exists "Products are publicly readable" on public.products;
drop policy if exists "Authenticated users can create products" on public.products;
drop policy if exists "Users can update their own products" on public.products;
drop policy if exists "Users can delete their own products" on public.products;

create policy "Products are publicly readable"
  on public.products for select
  to anon, authenticated
  using (true);

create policy "Authenticated users can create products"
  on public.products for insert
  to authenticated
  with check (auth.uid() = owner_id);

create policy "Users can update their own products"
  on public.products for update
  to authenticated
  using (auth.uid() = owner_id)
  with check (auth.uid() = owner_id);

create policy "Users can delete their own products"
  on public.products for delete
  to authenticated
  using (auth.uid() = owner_id);
