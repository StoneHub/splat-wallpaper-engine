# Tasks

## Status

This repo is now a public landing/migration repo for the original WebKit
prototype. Active development should move to the native Metal successor,
`benwilliams0540/gsplat`, once licensing and public access are settled.

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
- Published macOS releases through `v0.1.7`.
- Added a Windows WebView2/tray prototype and CI artifact workflow.

## Next

1. Keep this repo as a clear public reference for the old prototype.
2. Do not copy private `gsplat` source into this Apache-2.0 repo without an
   explicit license/contribution decision.
3. If the successor becomes public, update README links to the public release
   and archive this repo on GitHub.
4. If Windows remains important, use the old WPF/WebView2 notes as UX reference,
   but plan a separate native graphics strategy rather than porting Apple Metal.

## Final Bet

The native Metal renderer path won. This prototype should stay useful as
historical product and packaging reference, not as the primary renderer codebase.
