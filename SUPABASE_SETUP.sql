-- Admin access setup for public.messages.
--
-- Before running this migration:
-- 1. In Supabase Dashboard > Authentication > Users, create a confirmed user
--    for naveenbv3011@gmail.com. Do not create a user password in this file.
-- 2. Disable public sign-ups in Authentication settings. The public contact
--    form continues to submit with the anon role and does not need sign-ups.
-- 3. Run this SQL in the Supabase SQL Editor.
--
-- The existing "allow read" policy grants public access to contact messages.
-- This removes it and gives only the named authenticated admin read/delete
-- access. The existing "allow insert" contact-form policy is left unchanged.
-- Review any additional policies on public.messages: permissive SELECT or
-- DELETE policies also grant access and should be removed if they are not
-- explicitly admin-only.

begin;

alter table public.messages enable row level security;

drop policy if exists "allow read" on public.messages;
drop policy if exists "messages_admin_select" on public.messages;
drop policy if exists "messages_admin_delete" on public.messages;

create policy "messages_admin_select"
  on public.messages
  for select
  to authenticated
  using (
    lower(coalesce(auth.jwt() ->> 'email', '')) = 'naveenbv3011@gmail.com'
  );

create policy "messages_admin_delete"
  on public.messages
  for delete
  to authenticated
  using (
    lower(coalesce(auth.jwt() ->> 'email', '')) = 'naveenbv3011@gmail.com'
  );

create index if not exists messages_created_at_desc_idx
  on public.messages (created_at desc);

commit;
