# Tasks

## Done

- Created project folder under `/Users/monroe/Developer/Scratch/splat-wallpaper-engine`.
- Wrote the initial product/technical design.
- Added a SwiftPM macOS prototype.
- Added a menu-bar app shell.
- Added a desktop-level borderless wallpaper window.
- Added a bundled renderer host loaded through `WKWebView`.
- Verified `swift build` passes.

## Next

1. Pick one known-good local `.sog` scene from Monroe's existing splats.
2. Add a scene picker or config file for that `.sog`.
3. Replace the placeholder renderer with a real SOG-capable renderer.
4. Add interaction mode:
   - passive mode ignores mouse events;
   - interactive mode accepts drag, scroll, and keyboard input.
5. Persist camera state.
6. Add idle/power policy.
7. Test desktop behavior across Spaces, full-screen apps, and external displays.

## Current Bet

Use the native AppKit shell for desktop/window behavior and keep the renderer replaceable. Start with whichever SOG renderer gets a real splat visible fastest, then decide whether to keep web rendering or move lower-level into Metal.

