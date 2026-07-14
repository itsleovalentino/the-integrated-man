// The Integrated Man — offline service worker
// Network-first for the page (so updates always show), cache-first for static assets.
var CACHE = "tim-v61.75-dev";
var PRECACHE = ["./", "index.html", "the21.json",
  "assets/orb-vitality.png?v=2", "assets/orb-mental.png?v=2", "assets/orb-faith.png?v=2",
  "assets/orb-vocation.png?v=2", "assets/orb-wealth.png?v=2", "assets/orb-environment.png?v=2",
  "assets/orb-tribe.png?v=2", "assets/cross.png", "assets/logo-trimmed.png"];

self.addEventListener("install", function (e) {
  self.skipWaiting();
  e.waitUntil(caches.open(CACHE).then(function (c) { return c.addAll(PRECACHE); }).catch(function () {}));
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

  var isPage = req.mode === "navigate" || req.destination === "document";
  if (isPage) {
    // network-first: always try the latest page; fall back to cache when offline.
    // CACHE-POISONING GUARD: only overwrite the stored app shell with a real, OK response
    // for the app root itself — never a /waitlist page, a /dev/ page, or a 404/error page.
    e.respondWith(
      fetch(req).then(function (res) {
        try {
          var scopePath = new URL(self.registration.scope).pathname;
          var reqPath = new URL(req.url).pathname;
          var isAppRoot = reqPath === scopePath || reqPath === scopePath + "index.html";
          if (res && res.ok && isAppRoot) { var copy = res.clone(); caches.open(CACHE).then(function (c) { c.put("index.html", copy); }); }
        } catch (err) {}
        return res;
      }).catch(function () { return caches.match("index.html"); })
    );
    return;
  }

  // other GETs (fonts, etc.): cache-first, then network
  e.respondWith(
    caches.match(req).then(function (hit) {
      if (hit) return hit;
      return fetch(req).then(function (res) {
        try {
          var ok = res && (res.status === 200 || res.type === "opaque");
          var cacheable = req.url.indexOf(self.location.origin) === 0 || req.url.indexOf("fonts.g") > -1 || req.url.indexOf("jsdelivr") > -1;
          if (ok && cacheable) { var copy = res.clone(); caches.open(CACHE).then(function (c) { c.put(req, copy); }); }
        } catch (err) {}
        return res;
      });
    })
  );
});

// ---- web push: show the banner; tapping it focuses or opens the app ----
self.addEventListener("push", function (e) {
  var d = {};
  try { d = e.data ? e.data.json() : {}; } catch (err) {}
  e.waitUntil(self.registration.showNotification(d.title || "The Integrated Man", {
    body: d.body || "",
    icon: "assets/cross.png",
    badge: "assets/cross.png",
    data: d
  }));
});
self.addEventListener("notificationclick", function (e) {
  e.notification.close();
  e.waitUntil(clients.matchAll({ type: "window", includeUncontrolled: true }).then(function (list) {
    for (var i = 0; i < list.length; i++) { if ("focus" in list[i]) return list[i].focus(); }
    return clients.openWindow("./");
  }));
});
