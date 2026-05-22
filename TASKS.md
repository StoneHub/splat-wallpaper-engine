# Tasks

## Done

- Created project folder under `/Users/monroe/Developer/Scratch/splat-wallpaper-engine`.
- Wrote the initial product/technical design.
- Added a SwiftPM macOS prototype.
- Added a menu-bar app shell.
- Added a desktop-level borderless wallpaper window.
- Added a bundled renderer host loaded through `WKWebView`.
- Verified `swift build` passes.
- Vendored the proven SuperSplat viewer from `monroe.space`.
- Bundled a small known-good `scene.sog` for first real rendering.
- Added menu-driven interaction mode toggling.
- Added `Open SOG Scene...` and managed scene copying for selected `.sog` files.

## Next

1. Confirm the bundled Bucryss Erie `.sog` renders in the desktop window.
2. Persist camera state.
3. Add idle/power policy.
4. Test desktop behavior across Spaces, full-screen apps, and external displays.
5. Replace prototype scene copying with security-scoped file access if needed for a packaged app.

## Current Bet

Use the native AppKit shell for desktop/window behavior and keep the renderer replaceable. Start with whichever SOG renderer gets a real splat visible fastest, then decide whether to keep web rendering or move lower-level into Metal.
