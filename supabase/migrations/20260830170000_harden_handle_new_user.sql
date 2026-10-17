-- Prevent external RPC execution of the Auth profile trigger.
-- The function remains SECURITY DEFINER because it is invoked by
-- the auth.users trigger, not directly by clients.

revoke execute
on function public.handle_new_user()
from public;

revoke execute
on function public.handle_new_user()
from anon;

revoke execute
on function public.handle_new_user()
from authenticated;
