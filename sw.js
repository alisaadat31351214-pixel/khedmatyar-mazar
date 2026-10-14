const CACHE_NAME = 'khedmatyar-mazar-v9-final';
const CORE = ['./', './index.html', './manifest.webmanifest','./icon-192.png','./icon-512.png'];
self.addEventListener('install', event => {
  event.waitUntil(caches.open(CACHE_NAME).then(cache => cache.addAll(CORE.map(url => new Request(url, {cache:'reload'}))).catch(() => {})));
  self.skipWaiting();
});
self.addEventListener('activate', event => {
  event.waitUntil(caches.keys().then(keys => Promise.all(keys.filter(key => key.startsWith('khedmatyar-') && key !== CACHE_NAME).map(key => caches.delete(key)))));
  self.clients.claim();
});
self.addEventListener('fetch', event => {
  const req = event.request;
  if (req.method !== 'GET' || new URL(req.url).origin !== self.location.origin) return;
  if(req.mode==='navigate'){event.respondWith(fetch(req).then(r=>{const c=r.clone();caches.open(CACHE_NAME).then(k=>k.put(req,c));return r}).catch(()=>caches.match(req).then(m=>m||caches.match('./index.html'))));return}
  event.respondWith(caches.match(req).then(cached => cached || fetch(req).then(response => {
    if (response && response.ok) { const copy=response.clone(); caches.open(CACHE_NAME).then(cache=>cache.put(req,copy)); }
    return response;
  }).catch(() => caches.match('./index.html'))));
});
