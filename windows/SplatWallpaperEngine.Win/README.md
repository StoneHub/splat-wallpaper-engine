# Splat Wallpaper Engine for Windows

This is the Windows shell for Splat Wallpaper Engine. It is intended to match the macOS app while using Windows-native pieces:

- WPF app shell;
- WebView2 renderer host;
- notification-area tray menu;
- Win32 WorkerW desktop attachment;
- local `.sog` scene storage under `%LOCALAPPDATA%\SplatWallpaperEngine`.

## Current Status

This scaffold is ready for a Windows machine with the .NET SDK and WebView2 runtime. It has not been built on this Mac because `dotnet` is not installed here and WPF requires Windows.

## Expected Build

```powershell
cd windows\SplatWallpaperEngine.Win
dotnet restore
dotnet build -c Release
```

Before building a distributable package, copy the shared renderer into this project:

```powershell
.\sync-renderer.ps1
dotnet publish -c Release -r win-x64 --self-contained false
```

## GitHub Actions

The repository includes `.github/workflows/windows-build.yml`, which runs on `windows-latest`, builds this project, publishes `win-x64`, zips the publish folder, and uploads `Splat-Wallpaper-Engine-Windows-x64.zip` as a workflow artifact.

## Test Checklist

- App starts without a normal taskbar button.
- Tray icon is visible.
- Tray menu can open a `.sog` scene.
- WebView2 renders the scene in a normal window.
- Wallpaper window attaches behind desktop icons.
- Interaction Mode receives drag and scroll input.
- Rotate, VSync Rotation, speed, and FPS controls update the renderer.
- App survives Explorer restart, sleep/wake, and DPI changes.
