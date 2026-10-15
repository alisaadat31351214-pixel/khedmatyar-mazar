-- اگر ورود مدیر خطای دسترسی داد، یک بار اجرا کن (بی‌خطر است؛ قانون‌های امنیتی RLS سر جایشان می‌مانند).
grant usage on schema public to anon, authenticated;
grant select, insert on public.providers, public.listings to anon;
grant select on public.ads, public.settings to anon;
grant all on public.providers, public.ads, public.listings, public.settings, public.admins to authenticated;
grant usage, select on all sequences in schema public to anon, authenticated;
-- مدیر را با همان خطی که صفحهٔ ورود نشان می‌دهد ثبت کن (شامل شناسهٔ دقیق کاربر است).
