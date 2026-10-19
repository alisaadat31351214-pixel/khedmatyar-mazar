const CACHE_NAME = 'khedmatyar-mazar-v23-stats';
const CORE = ['./', './index.html', './manifest.webmanifest', './config.js', './icon-192.png', './icon-512.png', './logo.png'];
self.addEventListener('install', event => {
  /* هر فایل جدا کش می‌شود تا نبودِ یک فایل کل کش را خراب نکند */
  event.waitUntil(caches.open(CACHE_NAME).then(cache => Promise.allSettled(CORE.map(url => cache.add(new Request(url, {cache:'reload'}))))));
  self.skipWaiting();
});
self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key.startsWith('khedmatyar-') && key !== CACHE_NAME).map(key => caches.delete(key)))));
  self.clients.claim();
});
self.addEventListener('fetch', event => {
  const req = event.request, url = new URL(req.url);
  if (req.method !== 'GET' || url.origin !== self.location.origin || url.pathname.endsWith('/admin.html')) return;
  event.respondWith(fetch(req, {cache: 'no-cache'}).then(r => {
    if (r && r.ok) { const c = r.clone(); caches.open(CACHE_NAME).then(k => k.put(req, c)); }
    return r;
  }).catch(() => caches.match(req).then(m => m || (req.mode === 'navigate' ? caches.match('./index.html') : undefined))));
});
