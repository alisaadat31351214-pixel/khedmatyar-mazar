"""تست دودی خودکار خدمت‌یار (بدون نیاز به Supabase واقعی؛ پاسخ‌ها شبیه‌سازی می‌شوند).
اجرا:  pip install playwright && playwright install chromium && python tests/smoke.py
این تست ثابت می‌کند صفحه‌ها بدون خطای جاوااسکریپت کار می‌کنند؛ جایگزین تست روی Supabase واقعی نیست (docs/TEST_PLAN.md)."""
import asyncio, json, subprocess, sys, time, pathlib
from playwright.async_api import async_playwright
ROOT = pathlib.Path(__file__).resolve().parent.parent
PORT = 8799; BASE = f'http://localhost:{PORT}/'
SITE = {"key": "site", "value": {"dhikr": {"on": True, "days": ["ذکر"] * 7}, "ordersOff": False, "contact": {"on": True, "wa": "93700123456"}}}
PROV = [{"id": 7, "name": "دکان نمونه", "cats": ["قصابی و خوراکه", "تعمیر وسایل برقی"], "skills": {}, "areas": [], "all_areas": True, "address": "بلخ", "phone": "0700111222", "status": "approved", "extra": {"products": [{"name": "روغن", "price": "۱۸۰", "unit": "لیتر"}]}}]
ORD = [{"id": 3, "code": "AB12CD34", "provider_id": 7, "category": "تعمیر موتر", "details": "تست", "customer_name": "علی", "customer_phone": "0700", "status": "pending", "commission_status": "none", "created_at": "2026-10-17T10:00:00Z", "provider_done": False, "customer_confirmed": False}]
PR0 = {"id": 1, "provider_id": 7, "deal": "gerawi", "ptype": "haveli", "title": "حویلی نمونه", "area": "ناحیه 3", "price": 900000, "currency": "AFN", "term_months": 12, "facilities": [], "images": [], "agent_name": "راهنما", "agent_phone": "0700111222", "status": "active", "featured": False}
calls = []
async def route(r, settings=SITE):
    u = r.request.url; m = r.request.method
    if u.startswith(BASE): return await r.continue_()
    J = lambda b, s=200: r.fulfill(status=s, content_type='application/json', body=json.dumps(b))
    if '/rpc/create_order' in u: calls.append('create_order'); return await J('QX12AB89')
    if '/rpc/track_order' in u: return await J({"code": "QX12AB89", "status": "accepted", "kind": "service", "category": "x", "details": "d", "provider": "احمد", "done_pin": "4821", "events": []})
    if '/rpc/prov_orders' in u: return await J({"provider": "احمد", "orders": []})
    if '/rpc/prov_open' in u: return await J({"orders": [{"id": 11, "code": "OP", "category": "x", "details": "d"}]})
    if '/rpc/prov_action' in u: calls.append('prov_action'); return await J({"ok": True})
    if '/rpc/create_shop_order' in u: calls.append('shop'); return await J('SH12AB34')
    if '/rpc/agent_props' in u: return await J({"props": [PR0]})
    if '/rpc/agent_save_prop' in u: calls.append('agent_save'); return await J({"id": 5})
    if '/rest/v1/properties' in u and m == 'GET': return await J([PR0, dict(PR0, id=2, deal='rent', title='آپارتمان', ptype='apartment', price=15000)])
    if '/rpc/admin_list_admins' in u: return await J([{"user_id": "1", "email": "a@b.c"}])
    if '/auth/v1/token' in u: return await J({"access_token": "a.b.c", "user": {"id": "1", "email": "a@b.c"}})
    if '/rest/v1/admins' in u: return await J([{"user_id": "1"}])
    if '/rest/v1/settings' in u: return await J([settings])
    if '/rest/v1/providers' in u and m == 'GET': return await J(PROV)
    if '/rest/v1/orders' in u: return await J(ORD)
    if '/rest/v1/' in u: return await J([])
    if u.startswith('http'): return await r.abort()
    return await r.continue_()
async def main():
    srv = subprocess.Popen([sys.executable, '-m', 'http.server', str(PORT), '--directory', str(ROOT)], stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL); time.sleep(1.2)
    res = []; errs = []
    def ok(n, c): res.append((n, bool(c)))
    try:
        async with async_playwright() as p:
            b = await p.chromium.launch(); pg = await b.new_page(viewport={'width': 430, 'height': 900}); pg.on('pageerror', lambda e: errs.append(str(e)[:120]))
            pg.on('dialog', lambda d: asyncio.ensure_future(d.accept('100')))
            await pg.route('**/*', lambda r: route(r)); await pg.goto(BASE + 'index.html'); await pg.wait_for_timeout(1200)
            ok('home: 12+ category tiles', await pg.locator('.kv-c').count() >= 12)
            ok('quran not loaded at start (lazy)', await pg.evaluate('Q.every(function(x){return x.length===0})'))
            await pg.click('nav button[data-t="qur"]'); await pg.wait_for_timeout(1200)
            ok('quran lazy-load: 114 surahs listed', await pg.locator('#ql .srow').count() == 114)
            await pg.click('#ql [data-s="1"]'); await pg.wait_for_timeout(300)
            ok('quran: 7 ayah medallions in Fatiha', await pg.locator('.qm').count() == 7)
            await pg.click('nav button[data-t="cal"]'); await pg.wait_for_timeout(300)
            ok('calendar: 28-31 day cells', 28 <= await pg.locator('.kc-d').count() <= 31)
            await pg.click('nav button[data-t="ord"]'); await pg.select_option('#ordCat', 'تعمیر وسایل برقی')
            await pg.fill('#ordDet', 'یخچال خاموش می‌شود'); await pg.fill('#ordName', 'تست'); await pg.fill('#ordPhone', '0700123456'); await pg.click('#ordSend'); await pg.wait_for_timeout(600)
            ok('order: tracking code + end-of-job PIN shown', calls.count('create_order') == 1 and await pg.locator('.kv-pin').count() == 1)
            await pg.select_option('#ordCat', 'تکسی و باربری') if False else None
            await pg.select_option('#shopSel', '7'); await pg.fill('#shopItems input >> nth=0', '2'); await pg.fill('#shopName', 'تست'); await pg.fill('#shopPhone', '0700123456'); await pg.fill('#shopAddr', 'ناحیه ۲'); await pg.click('#shopSend'); await pg.wait_for_timeout(300)
            ok('shop order submitted', 'shop' in calls)
            await pg.click('nav button[data-t="pp"]'); await pg.fill('#ppPhone', '0700111222'); await pg.fill('#ppCode', 'ABCD1234'); await pg.click('#ppGo'); await pg.wait_for_timeout(500)
            ok('provider portal: open orders listed', await pg.locator('[data-claim]').count() == 1)
            await pg.click('[data-claim]'); await pg.wait_for_timeout(200); ok('provider claim sent', 'prov_action' in calls)
            await pg.click('nav button[data-t="re"]'); await pg.wait_for_timeout(400); ok('real estate: listings shown', await pg.locator('.re-card').count() == 2)
            await pg.select_option('#reDeal', 'gerawi'); await pg.wait_for_timeout(200); ok('real estate: deal filter works', await pg.locator('.re-card').count() == 1)
            await pg.click('nav button[data-t="pp"]'); await pg.wait_for_timeout(200); await pg.click('#agNew') if await pg.locator('#agNew').count() else None
            ok('agent panel lists own properties', await pg.locator('#agBox .ppc').count() == 1)
            await pg.click('#agNew'); await pg.fill('#agTitle', 'حویلی'); await pg.fill('#agPrice', '1000'); await pg.click('#agSave'); await pg.wait_for_timeout(300); ok('agent saves a property', 'agent_save' in calls)
            await pg.click('[data-lite]'); ok('lite mode toggles', await pg.evaluate("document.documentElement.classList.contains('lite')"))
            ad = await b.new_page(viewport={'width': 430, 'height': 900}); ad.on('pageerror', lambda e: errs.append('adm ' + str(e)[:120])); ad.on('dialog', lambda d: asyncio.ensure_future(d.accept()))
            await ad.route('**/*', lambda r: route(r)); await ad.goto(BASE + 'admin.html'); await ad.fill('#em', 'a@b.c'); await ad.fill('#pw', 'x'); await ad.click('#in'); await ad.wait_for_timeout(900)
            ok('admin: dashboard stats', await ad.locator('.st').count() >= 3)
            await ad.click('.nb[data-t="x"]'); await ad.wait_for_timeout(200); ok('admin: security tab lists admins', 'a@b.c' in await ad.inner_text('#view'))
            await ad.click('.nb[data-t="r"]'); await ad.click('[data-act=csug]'); await ad.wait_for_timeout(200); ok('admin: Afghan categories suggested', await ad.locator('.card h2').count() > 8)
            await ad.click('.nb[data-t="e"]'); await ad.wait_for_timeout(200); ok('admin: properties tab', await ad.locator('.it').count() == 2)
            await ad.click('.nb[data-t="o"]'); await ad.wait_for_timeout(200); ok('admin: orders list + CSV button', await ad.locator('[data-act=ocsv]').count() == 1)
            off = await b.new_page(); off.on('pageerror', lambda e: errs.append('off ' + str(e)[:120]))
            await off.route('**/*', lambda r: route(r, {"key": "site", "value": {"ordersOff": True, "ordersOffMsg": "بسته"}})); await off.goto(BASE + 'index.html'); await off.wait_for_timeout(1000)
            ok('ordersOff disables order buttons', await off.is_disabled('#ordSend'))
            await b.close()
    finally:
        srv.terminate()
    ok('no JavaScript page errors', not errs)
    for n, c in res: print(('PASS ' if c else 'FAIL ') + n)
    if errs: print('errors:', errs)
    sys.exit(0 if all(c for _, c in res) else 1)
asyncio.run(main())
