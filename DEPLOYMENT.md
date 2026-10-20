# انتشار

1. فایل‌های ریشه را در مخزن بگذارید: `index.html admin.html app.js app.css quran.json sw.js config.js manifest.webmanifest icon-192.png icon-512.png logo.png`.
2. GitHub → Settings → Pages → Deploy from branch → `main` و `/ (root)`.
3. در Supabase → SQL Editor فایل `supabase-setup.sql` را اجرا کنید (قابل اجرای مجدد).
4. Authentication → Users: کاربر مدیر را بسازید (Auto Confirm) و خط `insert into admins...` را اجرا کنید (صفحهٔ ورود مدیر، دستور دقیق را نشان می‌دهد).
5. بعد از هر انتشار، عدد `CACHE_NAME` در `sw.js` را زیاد کنید.
6. پایین سایت شمارهٔ نسخه نوشته شده؛ با آن مطمئن شوید نسخهٔ جدید لود شده است.

**انتقال به میزبان دیگر:** فایل‌ها ایستا هستند؛ روی هر هاست HTTPS (Netlify، Cloudflare Pages، سرور خودتان) قابل‌استفاده‌اند. فقط `config.js` را نگه دارید.

7. نکته: پلن رایگان Supabase پشتیبان خودکار ندارد و پروژهٔ بی‌فعالیت ممکن است متوقف شود (در مستندات رسمی Supabase شرایط فعلی را بررسی کن). سایت را مرتب باز کن و پشتیبان بگیر.
