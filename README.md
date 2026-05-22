# Splat Wallpaper Engine

Interactive macOS desktop wallpaper for Gaussian splats.

<p align="center">
  <img src="assets/AppIcon.iconset/icon_256x256.png" width="128" alt="Splat Wallpaper Engine app icon">
</p>

![Splat Wallpaper Engine showing a crane Gaussian splat as a macOS desktop wallpaper](assets/splat-wallpaper-desktop.png)

![Splat Wallpaper Engine about window over the desktop wallpaper](assets/splat-wallpaper-about.png)

![Splat Wallpaper Engine menu bar controls for rotation, VSync, speed, and FPS](assets/splat-wallpaper-menu.png)

The goal is a menu-bar Mac app that renders a local Gaussian splat as the desktop background, then lets the user temporarily interact with it by orbiting, panning, zooming, and saving a new default camera angle.

## MVP

- Load an existing local `.sog` splat.
- Keep `.ply` files as source/archive assets, not runtime assets.
- Render the splat in a desktop-level borderless window.
- Toggle interaction mode from the menu bar or a hotkey.
- Toggle in-place splat rotation from the menu bar with speed, FPS cap, and VSync controls.
- Open a local `.sog` scene from the menu.
- Save the active camera view.
- Pause or reduce frame rate when not interacting.

## Preferred Asset Flow

```text
Gaussian Splat PLY source -> SOG runtime derivative -> desktop renderer
```

`.sog` is the preferred runtime format because it is compact and already fits Monroe's `monroe.space` publishing flow. `.spz` and `.ksplat` remain fallback candidates if renderer support is better in a chosen library.

## First Technical Bet

Start with a Swift/AppKit shell that owns the desktop-level window, then embed the proven SuperSplat web viewer from `monroe.space`. Once the user experience is validated, decide whether to keep the web renderer or replace it with a native Metal renderer.

## Run

### macOS

```bash
swift run
```

Use the menu-bar `Splat` item to:

- open a `.sog` scene;
- show or hide the wallpaper window;
- toggle interaction mode;
- toggle in-place rotation and tune speed, FPS cap, or VSync rendering.

### Windows Prototype

The Windows port is scaffolded under `windows/SplatWallpaperEngine.Win`. It uses WPF, WebView2, a notification-area tray menu, and a Win32 WorkerW desktop attachment service.

```powershell
cd windows\SplatWallpaperEngine.Win
.\sync-renderer.ps1
dotnet restore
dotnet build -c Release
```

See `docs/windows-port-plan.md` for the conversion plan and Windows verification checklist.

## Links

- GitHub: https://github.com/StoneHub
- Personal site: https://monroes.tech

## License

Splat Wallpaper Engine is licensed under the Apache License, Version 2.0. Apache-2.0 is permissive like MIT, but includes an explicit patent grant from contributors.

The bundled renderer includes MIT-licensed SuperSplat/PlayCanvas code from PlayCanvas Ltd.; see `NOTICE`.
