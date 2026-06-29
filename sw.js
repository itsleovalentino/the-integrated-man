// The Integrated Man — offline service worker
// Caches the app shell so it opens instantly and works with no connection.
var CACHE = "tim-v1";
var SHELL = ["./", "index.html"];

self.addEventListener("install", function (e) {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(function (c) { return c.addAll(SHELL); }).catch(function () {}));
});

self.addEventListener("activate", function (e) {
  e.waitUntil(
    caches.keys().then(function (keys) {
      return Promise.all(keys.map(function (k) { if (k !== CACHE) return caches.delete(k); }));
    })
  );
  self.clients.claim();
});

self.addEventListener("fetch", function (e) {
  var req = e.request;
  if (req.method !== "GET") return;
  e.respondWith(
    caches.match(req).then(function (hit) {
      if (hit) return hit;
      return fetch(req).then(function (res) {
        // cache same-origin assets and the web font so they're available offline next time
        try {
          var ok = res && res.status === 200;
          var cacheable = req.url.indexOf(self.location.origin) === 0 || req.url.indexOf("fonts.g") > -1;
          if (ok && cacheable) {
            var copy = res.clone();
            caches.open(CACHE).then(function (c) { c.put(req, copy); });
          }
        } catch (err) {}
        return res;
      }).catch(function () {
        // offline fallback: serve the app shell for navigations
        if (req.mode === "navigate") return caches.match("index.html");
      });
    })
  );
});
