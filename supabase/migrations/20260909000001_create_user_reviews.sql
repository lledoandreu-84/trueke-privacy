-- Create user reviews table for feedback loop
create table if not exists public.user_reviews (
    id uuid default gen_random_uuid() primary key,
    reviewer_id uuid references auth.users(id) on delete set null,
    reviewer_name text not null default 'Usuario',
    reviewer_avatar text not null default '',
    receiver_id uuid references auth.users(id) on delete cascade not null,
    rating numeric(2,1) not null check (rating >= 1.0 and rating <= 5.0),
    comment text not null default '',
    created_at timestamp with time zone default timezone('utc'::text, now()) not null
);

-- Enable RLS (Row Level Security)
alter table public.user_reviews enable row level security;

-- Policies for user reviews
create policy "Anyone can view user reviews"
    on public.user_reviews for select
    using (true);

create policy "Authenticated users can insert reviews"
    on public.user_reviews for insert
    with check (auth.uid() = reviewer_id);

-- Create indexes for performance on user profile fetches
create index if not exists user_reviews_receiver_id_idx on public.user_reviews(receiver_id);
