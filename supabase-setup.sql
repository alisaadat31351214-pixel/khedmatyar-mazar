-- خدمت‌یار: جداول و قانون‌های امنیتی. در SQL Editor یک‌جا اجرا کن (Run).
create table if not exists admins(user_id uuid primary key references auth.users(id) on delete cascade);
alter table admins enable row level security;
create policy "admin sees self" on admins for select using (user_id = auth.uid());
create or replace function public.is_admin() returns boolean language sql security definer set search_path=public as $$ select exists(select 1 from public.admins where user_id=auth.uid()) $$;

create table if not exists providers(
 id bigint generated always as identity primary key,
 name text not null check (char_length(name) between 2 and 80),
 cats text[] not null default '{}', skills jsonb not null default '{}',
 areas text[] not null default '{}', all_areas boolean not null default false,
 address text check (char_length(address)<=200),
 phone text not null check (phone ~ '^\+?[0-9]{9,14}$'),
 extra jsonb not null default '{}', note text,
 status text not null default 'pending' check (status in ('pending','approved','rejected')),
 created_at timestamptz not null default now());
create table if not exists ads(
 id bigint generated always as identity primary key,
 name text not null, type text not null default 'رستورانت', description text, address text, phone text, map_url text, image_url text,
 menu jsonb not null default '[]', starts_at date, ends_at date,
 status text not null default 'pending' check (status in ('pending','approved','hidden')),
 created_at timestamptz not null default now());
create table if not exists listings(
 id bigint generated always as identity primary key,
 kind text not null, title text not null check (char_length(title) between 3 and 120), price numeric, description text,
 attrs jsonb not null default '{}', images text[] not null default '{}',
 phone text not null check (phone ~ '^\+?[0-9]{9,14}$'),
 status text not null default 'pending' check (status in ('pending','approved','sold','rejected')),
 created_at timestamptz not null default now());
create table if not exists settings(key text primary key, value jsonb not null);

alter table providers enable row level security; alter table ads enable row level security;
alter table listings enable row level security; alter table settings enable row level security;

create policy "public reads approved providers" on providers for select using (status='approved');
create policy "anyone submits provider" on providers for insert with check (status='pending');
create policy "admin all providers" on providers for all using (is_admin()) with check (is_admin());

create policy "public reads live ads" on ads for select using (status='approved' and (ends_at is null or ends_at >= current_date) and (starts_at is null or starts_at <= current_date));
create policy "admin all ads" on ads for all using (is_admin()) with check (is_admin());

create policy "public reads approved listings" on listings for select using (status in ('approved','sold'));
create policy "anyone submits listing" on listings for insert with check (status='pending');
create policy "admin all listings" on listings for all using (is_admin()) with check (is_admin());

create policy "public reads settings" on settings for select using (true);
create policy "admin writes settings" on settings for all using (is_admin()) with check (is_admin());

insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('media','media',true,3145728,array['image/jpeg','image/png','image/webp']) on conflict (id) do nothing;
create policy "media public read" on storage.objects for select using (bucket_id='media');
create policy "anyone uploads to uploads/" on storage.objects for insert with check (bucket_id='media' and (storage.foldername(name))[1]='uploads');
create policy "admin manages media" on storage.objects for all using (bucket_id='media' and is_admin()) with check (bucket_id='media' and is_admin());

-- بعد از ساختن کاربر مدیر در Authentication ← Users، این خط را (دوباره) اجرا کن:
insert into admins(user_id) select id from auth.users where email='taher.watan.dost@gmail.com' on conflict do nothing;

window.KHEDMATYAR_CONFIG = {
  url: 'https://rkkjbkmnhzccucqbrqqt.supabase.co',
  anonKey: 'sb_publishable_Ty6EvQ6_VTkxHE8alPnH3A_bEeUyJq-',
  adminEmail: 'ایمیل-واقعی-مدیر-را-اینجا-بنویس'
};

