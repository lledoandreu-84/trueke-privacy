set local check_function_bodies = off;

alter default privileges for role "postgres" in schema "public" revoke all on sequences from "anon";

alter default privileges for role "postgres" in schema "public" revoke all on sequences from "authenticated";

alter default privileges for role "postgres" in schema "public" revoke all on sequences from "service_role";

alter table "public"."products"
  drop constraint "products_owner_id_fkey";

alter table "public"."products"
  alter column "category" drop default;

alter table "public"."products"
  alter column "condition" drop default;

alter table "public"."products"
  alter column "description" drop default;

alter table "public"."products"
  alter column "images" drop default;

alter table "public"."products"
  alter column "location" drop default;

alter table "public"."products"
  alter column "owner" drop default;

alter table "public"."products"
  alter column "title" drop default;

alter table "public"."products"
  alter column "trade_type" drop default;

alter table "public"."products"
  alter column "wanted" drop default;

alter table "public"."products"
  alter column "category" drop not null;

alter table "public"."products"
  alter column "condition" drop not null;

alter table "public"."products"
  alter column "created_at" drop not null;

alter table "public"."products"
  alter column "description" drop not null;

alter table "public"."products"
  alter column "images" drop not null;

alter table "public"."products"
  alter column "images" drop default;

alter table "public"."products"
  alter column "images" type jsonb using to_jsonb("images");

alter table "public"."products"
  alter column "location" drop not null;

alter table "public"."products"
  alter column "owner" drop not null;

alter table "public"."products"
  alter column "trade_type" drop not null;

alter table "public"."products"
  alter column "wanted" drop not null;

create or replace function public.handle_new_user()
  returns trigger
  language plpgsql
  security definer
  set search_path to 'public'
  AS $function$
begin
  insert into public.profiles (id, username, display_name)
  values (
    new.id,
    split_part(coalesce(new.email, ''), '@', 1),
    split_part(coalesce(new.email, ''), '@', 1)
  )
  on conflict (id) do nothing;

  return new;
end;
$function$;

alter table "public"."profiles"
  add constraint "profiles_username_key" unique (username);

create trigger on_auth_user_created
  after insert on auth.users
  for each row
  execute function public.handle_new_user();

alter publication "supabase_realtime" add table "public"."trade_offers";

grant execute on function "public"."handle_new_user"() to public, "postgres";

revoke all on table "public"."products" from "anon";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."products" to "anon";

revoke all on table "public"."products" from "authenticated";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."products" to "authenticated";

revoke all on table "public"."profiles" from "authenticated";

grant delete, insert, maintain, references, select, trigger, truncate, update on table "public"."profiles" to "authenticated";

