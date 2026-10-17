-- Remove legacy profile policies that are not represented
-- in the current migration history.

drop policy if exists "profiles_delete_own" on public.profiles;
drop policy if exists "profiles_insert_own" on public.profiles;
drop policy if exists "profiles_select_own" on public.profiles;
drop policy if exists "profiles_update_own" on public.profiles;
