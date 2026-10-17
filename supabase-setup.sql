-- خدمت‌یار مزارشریف — اسکریپت کامل و قابل اجرای مجدد. یک‌جا در SQL Editor اجرا کن (Run).

create table if not exists public.admins(user_id uuid primary key references auth.users(id) on delete cascade);

create table if not exists public.providers(
 id bigint generated always as identity primary key,
 name text not null check (char_length(name) between 2 and 80),
 cats text[] not null default '{}', skills jsonb not null default '{}',
 areas text[] not null default '{}', all_areas boolean not null default false,
 address text, phone text not null check (char_length(phone) between 7 and 20),
 extra jsonb not null default '{}', note text,
 status text not null default 'pending' check (status in ('pending','approved','rejected')),
 created_at timestamptz not null default now());

create table if not exists public.ads(
 id bigint generated always as identity primary key,
 name text not null, type text not null default 'رستورانت', description text, address text, phone text, map_url text, image_url text,
 menu jsonb not null default '[]', starts_at date, ends_at date,
 status text not null default 'pending' check (status in ('pending','approved','hidden')),
 created_at timestamptz not null default now());

create table if not exists public.listings(
 id bigint generated always as identity primary key,
 kind text not null, title text not null check (char_length(title) between 3 and 120), price numeric, description text,
 attrs jsonb not null default '{}', images text[] not null default '{}',
 phone text not null check (char_length(phone) between 7 and 20),
 status text not null default 'pending' check (status in ('pending','approved','sold','rejected')),
 created_at timestamptz not null default now());

create table if not exists public.settings(key text primary key, value jsonb not null);

create or replace function public.is_admin() returns boolean language sql security definer set search_path=public as
$fn$ select exists(select 1 from public.admins where user_id = auth.uid()) $fn$;

alter table public.admins enable row level security;
alter table public.providers enable row level security;
alter table public.ads enable row level security;
alter table public.listings enable row level security;
alter table public.settings enable row level security;

drop policy if exists "admin sees self" on public.admins;
create policy "admin sees self" on public.admins for select using (user_id = auth.uid());

drop policy if exists "public reads approved providers" on public.providers;
create policy "public reads approved providers" on public.providers for select using (status='approved');
drop policy if exists "anyone submits provider" on public.providers;
create policy "anyone submits provider" on public.providers for insert with check (status='pending');
drop policy if exists "admin all providers" on public.providers;
create policy "admin all providers" on public.providers for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "public reads live ads" on public.ads;
create policy "public reads live ads" on public.ads for select using (status='approved' and (ends_at is null or ends_at >= current_date) and (starts_at is null or starts_at <= current_date));
drop policy if exists "admin all ads" on public.ads;
create policy "admin all ads" on public.ads for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "public reads approved listings" on public.listings;
create policy "public reads approved listings" on public.listings for select using (status in ('approved','sold'));
drop policy if exists "anyone submits listing" on public.listings;
create policy "anyone submits listing" on public.listings for insert with check (status='pending');
drop policy if exists "admin all listings" on public.listings;
create policy "admin all listings" on public.listings for all using (public.is_admin()) with check (public.is_admin());

drop policy if exists "public reads settings" on public.settings;
create policy "public reads settings" on public.settings for select using (true);
drop policy if exists "admin writes settings" on public.settings;
create policy "admin writes settings" on public.settings for all using (public.is_admin()) with check (public.is_admin());

grant usage on schema public to anon, authenticated;
grant select, insert on public.providers, public.listings to anon;
grant select on public.ads, public.settings to anon;
grant all on public.providers, public.ads, public.listings, public.settings, public.admins to authenticated;
grant execute on function public.is_admin() to anon, authenticated;

create table if not exists public.messages(
 id bigint generated always as identity primary key,
 kind text not null default 'contact' check (kind in ('contact','report')),
 name text check (char_length(name)<=80), contact text check (char_length(contact)<=60),
 body text not null check (char_length(body) between 3 and 1000), ref text,
 status text not null default 'new' check (status in ('new','read')),
 created_at timestamptz not null default now());
alter table public.messages enable row level security;
drop policy if exists "anyone sends message" on public.messages;
create policy "anyone sends message" on public.messages for insert with check (status='new');
drop policy if exists "admin all messages" on public.messages;
create policy "admin all messages" on public.messages for all using (public.is_admin()) with check (public.is_admin());
grant insert on public.messages to anon;
grant all on public.messages to authenticated;

-- بخش عکس‌ها: اگر خطا بدهد فقط همین بخش رد می‌شود و جدول‌ها سالم می‌مانند.
do $st$ begin
  insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
  values('media','media',true,3145728,array['image/jpeg','image/png','image/webp'])
  on conflict (id) do update set public=true, file_size_limit=3145728, allowed_mime_types=array['image/jpeg','image/png','image/webp'];
  drop policy if exists "media public read" on storage.objects;
  create policy "media public read" on storage.objects for select using (bucket_id='media');
  drop policy if exists "anyone uploads to uploads" on storage.objects;
  create policy "anyone uploads to uploads" on storage.objects for insert with check (bucket_id='media' and (storage.foldername(name))[1]='uploads');
  drop policy if exists "admin manages media" on storage.objects;
  create policy "admin manages media" on storage.objects for all using (bucket_id='media' and public.is_admin()) with check (bucket_id='media' and public.is_admin());
exception when others then raise notice 'بخش عکس‌ها اجرا نشد: %', sqlerrm;
end $st$;

-- ثبت مدیر (اگر کاربر با این ایمیل در Authentication ساخته شده باشد):
insert into public.admins(user_id) select id from auth.users where email='taher.watan.dost@gmail.com' on conflict do nothing;

notify pgrst, 'reload schema';
