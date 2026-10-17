-- Baseline schema required by the Flutter application.

create table if not exists public.products (
  id text primary key,
  title text not null default '',
  description text not null default '',
  price numeric,
  category text not null default 'Otros',
  created_at timestamptz not null default now()
);

create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  username text,
  display_name text,
  avatar_url text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
