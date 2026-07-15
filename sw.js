// Service worker de TREP CAMP
// Estrategia: "red primero" para la página (así se actualiza cuando hay internet)
// y respaldo en caché para funcionar sin conexión.
const CACHE = 'trepcamp-v1';
const ARCHIVOS = [
  './',
  './index.html',
  './manifest.json',
  './icon-192.png',
  './icon-512.png',
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

  // Nunca interceptar llamadas a la API de IA u otros dominios
  if (url.origin !== self.location.origin || e.request.method !== 'GET') return;

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
