// Service worker de TREP CAMP
// Estrategia: "red primero" para la página (así se actualiza cuando hay internet)
// y respaldo en caché para funcionar sin conexión.
const CACHE = 'trepcamp-v6';
const ARCHIVOS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
  'https://cdn.jsdelivr.net/npm/@supabase/supabase-js@2',
];

self.addEventListener('install', e => {
  e.waitUntil(
    caches.open(CACHE).then(c => c.addAll(ARCHIVOS)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', e => {
  e.waitUntil(
    caches.keys()
      .then(keys => Promise.all(keys.filter(k => k !== CACHE).map(k => caches.delete(k))))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', e => {
  const url = new URL(e.request.url);
  if (e.request.method !== 'GET') return;

  // Librería de Supabase y tipografía (CDN): caché primero, son versiones estables
  if (url.origin === 'https://cdn.jsdelivr.net'
      || url.origin === 'https://fonts.googleapis.com'
      || url.origin === 'https://fonts.gstatic.com') {
    e.respondWith(
      caches.match(e.request).then(r => r || fetch(e.request).then(resp => {
        const copia = resp.clone();
        caches.open(CACHE).then(c => c.put(e.request, copia));
        return resp;
      }))
    );
    return;
  }

  // Nunca interceptar llamadas a Supabase (datos) ni a la API de IA
  if (url.origin !== self.location.origin) return;

  e.respondWith(
    // Red primero: si hay internet se descarga la versión más reciente y se guarda en caché
    fetch(e.request)
      .then(resp => {
        const copia = resp.clone();
        caches.open(CACHE).then(c => c.put(e.request, copia));
        return resp;
      })
      // Sin internet: se sirve la última versión guardada
      .catch(() => caches.match(e.request, { ignoreSearch: true })
        .then(r => r || caches.match('./index.html')))
  );
});
