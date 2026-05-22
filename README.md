# Splat Wallpaper Engine

Interactive macOS desktop wallpaper for Gaussian splats.

The goal is a menu-bar Mac app that renders a local Gaussian splat as the desktop background, then lets the user temporarily interact with it by orbiting, panning, zooming, and saving a new default camera angle.

## MVP

- Load an existing local `.sog` splat.
- Keep `.ply` files as source/archive assets, not runtime assets.
- Render the splat in a desktop-level borderless window.
- Toggle interaction mode from the menu bar or a hotkey.
- Save the active camera view.
- Pause or reduce frame rate when not interacting.

## Preferred Asset Flow

```text
Gaussian Splat PLY source -> SOG runtime derivative -> desktop renderer
```

`.sog` is the preferred runtime format because it is compact and already fits Monroe's `monroe.space` publishing flow. `.spz` and `.ksplat` remain fallback candidates if renderer support is better in a chosen library.

## First Technical Bet

Start with a Swift/AppKit shell that owns the desktop-level window, then embed a splat renderer. The renderer can initially be web-based if that gets us to a visible prototype faster, but the windowing behavior should be native macOS from the beginning.

