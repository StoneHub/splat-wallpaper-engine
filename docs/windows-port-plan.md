# Windows Port Plan

## Goal

Build a Windows version of Splat Wallpaper Engine that feels nearly identical to the macOS menu-bar app:

- local `.sog` scene loading;
- desktop-level live wallpaper window;
- taskbar notification-area menu;
- interaction mode;
- in-place rotation with speed, FPS cap, and VSync controls;
- About dialog and app icon.

## Recommended Stack

Use a native Windows shell with the existing web renderer:

```text
WPF tray app
  -> WebView2 renderer host
  -> Win32 desktop attachment service
  -> scene store under LocalAppData
  -> shared Renderer assets from the macOS app
```

This keeps the expensive Gaussian splat rendering path aligned with the current macOS implementation while replacing only the platform shell.

## Why WPF + WebView2

- WebView2 is Microsoft's supported Chromium web view for desktop Windows apps.
- WPF gives quick tray/menu/file-picker/settings implementation.
- WPF exposes HWNDs cleanly enough for the Win32 desktop-window work.
- The existing renderer bridge can be reused with JavaScript calls.

## Desktop Window Strategy

Windows does not expose a first-class public interactive live-wallpaper API. The practical approach is the same family of technique used by live wallpaper tools:

1. find the shell `Progman` window;
2. ask Explorer to create/reveal a `WorkerW`;
3. find the `WorkerW` behind desktop icons;
4. parent the borderless renderer window to it;
5. reattach if Explorer restarts.

The Windows app must keep a fallback normal borderless window path for machines where WorkerW attachment fails.

## Milestones

1. Scaffold WPF/WebView2 app and load the bundled renderer in a normal window.
2. Add taskbar notification-area menu matching macOS controls.
3. Copy/open `.sog` files into `%LOCALAPPDATA%\SplatWallpaperEngine\Scenes`.
4. Attach the renderer HWND behind desktop icons.
5. Implement click-through passive mode and raised/input-enabled interaction mode.
6. Port rotation speed/FPS/VSync bridge calls.
7. Package x64 Windows build and publish GitHub release artifact.

## Verification Matrix

- Windows 11, single monitor.
- Windows 11, multiple monitors.
- Windows 10 if practical.
- Explorer restart while app is running.
- Sleep/wake.
- DPI scaling at 100%, 150%, and mixed-DPI monitors.
- Hide desktop icons on/off.
- WebView2 runtime absent/present.

## Open Risks

- Desktop attachment is shell-behavior dependent and less stable than an ordinary top-level app window.
- Interaction mode may need a temporary top-level overlay if childing to WorkerW prevents reliable input.
- WebView2 Evergreen runtime distribution needs an installer decision.
- Multi-monitor support needs a per-monitor renderer window and scene/camera state model.
