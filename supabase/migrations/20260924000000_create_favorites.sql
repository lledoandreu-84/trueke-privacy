-- Create favorites table for authenticated users.
create table if not exists public.favorites (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references auth.users (id) on delete cascade,
  product_id text not null,
  created_at timestamptz not null default now(),
  unique (user_id, product_id)
);

-- Enable Row Level Security (RLS)
alter table public.favorites enable row level security;

-- Drop policies if exist to prevent collisions
drop policy if exists "Los usuarios pueden ver sus propios favoritos" on public.favorites;
drop policy if exists "Los usuarios pueden insertar sus propios favoritos" on public.favorites;
drop policy if exists "Los usuarios pueden eliminar sus propios favoritos" on public.favorites;

-- Create secure policies
create policy "Los usuarios pueden ver sus propios favoritos"
  on public.favorites for select
  to authenticated
  using (auth.uid() = user_id);

create policy "Los usuarios pueden insertar sus propios favoritos"
  on public.favorites for insert
  to authenticated
  with check (auth.uid() = user_id);

create policy "Los usuarios pueden eliminar sus propios favoritos"
  on public.favorites for delete
  to authenticated
  using (auth.uid() = user_id);
