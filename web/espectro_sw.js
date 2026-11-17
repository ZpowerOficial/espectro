'use strict';

// O Flutter 3.47 gera um service worker que se desregistra (migração para o
// novo bootstrap). Para manter o PWA offline, o Espectro usa este worker
// próprio, registrado por web/index.html e versionado por build em tool/build_portable.sh.
const CACHE_NAME = 'espectro-shell-v2';
const NETWORK_FIRST_PATHS = [
  '/flutter_bootstrap.js',
  '/main.dart.js',
  '/flutter.js',
  '/manifest.json',
  '/version.json',
];
const CORE = [
  './',
  './index.html',
  './manifest.json',
  './favicon.png',
  './flutter.js',
  './flutter_bootstrap.js',
  './main.dart.js',
  './icons/Icon-192.png',
  './icons/Icon-512.png',
  './icons/Icon-maskable-192.png',
  './icons/Icon-maskable-512.png',
  './canvaskit/canvaskit.js',
  './canvaskit/canvaskit.wasm',
  './canvaskit/chromium/canvaskit.js',
  './canvaskit/chromium/canvaskit.wasm',
  './canvaskit/webparagraph/canvaskit.js',
  './canvaskit/webparagraph/canvaskit.wasm',
  './assets/AssetManifest.bin',
  './assets/AssetManifest.bin.json',
  './assets/FontManifest.json',
  './assets/assets/figma/espectro-mascot.png',
  './assets/assets/figma/atlas-circle.png',
  './assets/assets/fonts/IBMPlexSans-Regular.ttf',
  './assets/assets/fonts/IBMPlexSans-Medium.ttf',
  './assets/assets/fonts/IBMPlexSans-SemiBold.ttf',
  './assets/assets/fonts/IBMPlexSans-Bold.ttf',
  './assets/assets/fonts/IBMPlexMono-Regular.ttf',
  './assets/assets/fonts/IBMPlexMono-Medium.ttf',
  './assets/assets/fonts/IBMPlexMono-SemiBold.ttf',
  './assets/assets/fonts/IBMPlexMono-Bold.ttf',
  './assets/assets/data/twelve_axes.json',
  './assets/assets/data/twelve_axes_extra.json',
  './assets/assets/data/six_triangles.json',
  './assets/assets/data/six_triangles_extra.json',
  './assets/assets/data/ideological_currents.json',
  './assets/assets/data/personalities.json',
  './assets/assets/data/personalities_extended.json',
  './assets/assets/data/parties_movements.json',
  './assets/assets/data/historical_eras.json',
  './assets/assets/data/books_catalog.json',
  './assets/assets/data/countries.json',
  './assets/assets/data/study_media.json',
  './assets/assets/data/study_relations_extended.json',
  './assets/assets/data/external_catalog.json',
  './assets/assets/data/dossiers/shard_00.json',
  './assets/assets/data/dossiers/shard_01.json',
  './assets/assets/data/dossiers/shard_02.json',
  './assets/assets/data/dossiers/shard_03.json',
  './assets/assets/data/dossiers/shard_04.json',
  './assets/assets/data/dossiers/shard_05.json',
  './assets/assets/data/dossiers/shard_06.json',
  './assets/assets/data/dossiers/shard_07.json',
  './assets/assets/data/dossiers/shard_08.json',
  './assets/assets/data/dossiers/shard_09.json',
  './assets/assets/data/dossiers/shard_10.json',
  './assets/assets/data/dossiers/shard_11.json',
  './assets/assets/data/dossiers/shard_12.json',
  './assets/assets/data/dossiers/shard_13.json',
  './assets/assets/data/dossiers/shard_14.json',
  './assets/assets/data/dossiers/shard_15.json',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE_NAME);
      await Promise.all(
        CORE.map(async (entry) => {
          const response = await fetch(new Request(entry, { cache: 'reload' }));
          if (!response || !response.ok) {
            throw new Error(`Falha ao pré-cachear ${entry}`);
          }
          await cache.put(new Request(entry), response);
        }),
      );
      await self.skipWaiting();
    })(),
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const keys = await caches.keys();
      await Promise.all(
        keys
          .filter((key) => key.startsWith('espectro-shell-') && key !== CACHE_NAME)
          .map((key) => caches.delete(key)),
      );
      await self.clients.claim();
    })(),
  );
});

function isCacheable(request, url) {
  if (request.method !== 'GET') return false;
  if (url.origin !== self.location.origin) return false;
  if (url.pathname.endsWith('/espectro_sw.js')) return false;
  if (url.pathname.endsWith('/flutter_service_worker.js')) return false;
  return true;
}

function isNetworkFirstAsset(pathname) {
  return NETWORK_FIRST_PATHS.some((suffix) => pathname.endsWith(suffix));
}

async function networkFirstNavigation(request) {
  const url = new URL(request.url);
  const cache = await caches.open(CACHE_NAME);
  const isHomeShell = url.pathname === '/' || url.pathname === '/index.html';
  const shell = await cache.match('./index.html');
  try {
    const response = await fetch(request);
    if (response && response.ok && isHomeShell) {
      cache.put('./index.html', response.clone());
    }
    if (response && response.ok) {
      return response;
    }
    // Hospedagem estática pode devolver 404 para rotas do app. O shell já
    // instalado preserva o deep link e deixa o Flutter resolver a rota.
    return shell || response;
  } catch (_) {
    return shell || Response.error();
  }
}

async function networkFirstAsset(request) {
  const cache = await caches.open(CACHE_NAME);
  try {
    const response = await fetch(new Request(request.url, { cache: 'no-cache' }));
    if (response && response.ok) {
      cache.put(request, response.clone());
      return response;
    }
    return (await cache.match(request)) || response;
  } catch (_) {
    return (await cache.match(request)) || Response.error();
  }
}

async function cacheFirst(request) {
  const cache = await caches.open(CACHE_NAME);
  const cached = await cache.match(request);
  if (cached) return cached;

  const response = await fetch(request);
  if (response && response.ok) {
    cache.put(request, response.clone());
  }
  return response;
}

self.addEventListener('fetch', (event) => {
  const url = new URL(event.request.url);
  if (!isCacheable(event.request, url)) return;

  if (event.request.mode === 'navigate') {
    event.respondWith(networkFirstNavigation(event.request));
    return;
  }

  if (isNetworkFirstAsset(url.pathname)) {
    event.respondWith(networkFirstAsset(event.request));
    return;
  }

  event.respondWith(
    cacheFirst(event.request).catch(async () => {
      const cache = await caches.open(CACHE_NAME);
      return (await cache.match(event.request)) || Response.error();
    }),
  );
});
