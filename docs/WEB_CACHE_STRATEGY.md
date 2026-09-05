# Web cache and updates

Each export embeds its full commit in `index.html` and ships `build-version.json`. The shell fetches that JSON every 60 seconds with both a timestamp query and `cache: no-store`; if its commit differs, a user-controlled update button appears. It never forces a reload, protecting races and unsaved actions. PWA/service-worker support is disabled, so no worker pins old `.pck` files. GitHub Pages cache headers are not configurable here. Godot saves remain at the unchanged `user://career.json`, preserving the same browser IndexedDB origin and application identity.
