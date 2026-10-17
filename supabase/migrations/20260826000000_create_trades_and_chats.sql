-- Conversations, messages and trade offers for authenticated users.

create table if not exists public.conversations (
  id uuid primary key default gen_random_uuid(),
  product_id text not null,
  product_title text not null default '',
  buyer_id uuid not null references auth.users (id) on delete cascade,
  seller_id uuid references auth.users (id) on delete set null,
  buyer_name text not null default 'Usuario',
  seller_name text not null default 'Usuario',
  created_at timestamptz not null default now(),
  unique (product_id, buyer_id)
);

create table if not exists public.messages (
  id uuid primary key default gen_random_uuid(),
  conversation_id uuid not null references public.conversations (id) on delete cascade,
  sender_id uuid not null references auth.users (id) on delete cascade,
  text text not null,
  created_at timestamptz not null default now()
);

create table if not exists public.trade_offers (
  id uuid primary key default gen_random_uuid(),
  product_id text not null,
  product_title text not null default '',
  from_user_id uuid not null references auth.users (id) on delete cascade,
  to_user_id uuid references auth.users (id) on delete set null,
  conversation_id uuid references public.conversations (id) on delete set null,
  message text not null default '',
  status text not null default 'sent',
  created_at timestamptz not null default now()
);

create index if not exists messages_conversation_created_at_idx
  on public.messages (conversation_id, created_at);

create index if not exists trade_offers_from_user_id_idx
  on public.trade_offers (from_user_id, created_at desc);

create index if not exists trade_offers_to_user_id_idx
  on public.trade_offers (to_user_id, created_at desc);

alter table public.conversations enable row level security;
alter table public.messages enable row level security;
alter table public.trade_offers enable row level security;

drop policy if exists "Participants can read conversations" on public.conversations;
drop policy if exists "Buyers can create conversations" on public.conversations;
drop policy if exists "Participants can read messages" on public.messages;
drop policy if exists "Participants can send messages" on public.messages;
drop policy if exists "Users can read own trade offers" on public.trade_offers;
drop policy if exists "Users can create trade offers" on public.trade_offers;

create policy "Participants can read conversations"
  on public.conversations for select
  to authenticated
  using (auth.uid() = buyer_id or auth.uid() = seller_id);

create policy "Buyers can create conversations"
  on public.conversations for insert
  to authenticated
  with check (auth.uid() = buyer_id);

create policy "Participants can read messages"
  on public.messages for select
  to authenticated
  using (
    exists (
      select 1
      from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

create policy "Participants can send messages"
  on public.messages for insert
  to authenticated
  with check (
    auth.uid() = sender_id
    and exists (
      select 1
      from public.conversations c
      where c.id = conversation_id
        and (c.buyer_id = auth.uid() or c.seller_id = auth.uid())
    )
  );

create policy "Users can read own trade offers"
  on public.trade_offers for select
  to authenticated
  using (auth.uid() = from_user_id or auth.uid() = to_user_id);

create policy "Users can create trade offers"
  on public.trade_offers for insert
  to authenticated
  with check (auth.uid() = from_user_id);
