-- Store each user's product images in a private folder and prevent anonymous uploads.
drop policy if exists "Allow anon uploads product images" on storage.objects;
drop policy if exists "Allow anon reads product images" on storage.objects;
drop policy if exists "Allow public reads product images" on storage.objects;
drop policy if exists "Public can view product images" on storage.objects;
drop policy if exists "Authenticated users can upload own product images" on storage.objects;

create policy "Public can view product images"
  on storage.objects for select
  to public
  using (bucket_id = 'product-images');

create policy "Authenticated users can upload own product images"
  on storage.objects for insert
  to authenticated
  with check (
    bucket_id = 'product-images'
    and (storage.foldername(name))[1] = (select auth.uid()::text)
  );
