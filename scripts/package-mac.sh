#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_NAME="Splat Wallpaper Engine"
BUNDLE_ID="space.monroe.splat-wallpaper-engine"
APP_VERSION="0.1.5"
BUILD_DIR="$ROOT_DIR/.build/arm64-apple-macosx/release"
DIST_DIR="$ROOT_DIR/dist"
APP_PATH="$DIST_DIR/$APP_NAME.app"
DMG_ROOT="$DIST_DIR/dmg-root"
DMG_PATH="$DIST_DIR/Splat-Wallpaper-Engine.dmg"
ICON_PATH="$ROOT_DIR/assets/AppIcon.icns"

cd "$ROOT_DIR"

swift build -c release

if [[ ! -f "$ICON_PATH" ]]; then
  swift scripts/make-icon.swift
fi

rm -rf "$APP_PATH" "$DMG_ROOT" "$DMG_PATH"
mkdir -p "$APP_PATH/Contents/MacOS" "$APP_PATH/Contents/Resources" "$DMG_ROOT"

cp "$BUILD_DIR/SplatWallpaperEngine" "$APP_PATH/Contents/MacOS/SplatWallpaperEngine"
cp -R "$BUILD_DIR/SplatWallpaperEngine_SplatWallpaperEngine.bundle" "$APP_PATH/Contents/Resources/"
cp "$ICON_PATH" "$APP_PATH/Contents/Resources/AppIcon.icns"

cat > "$APP_PATH/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>en</string>
  <key>CFBundleExecutable</key>
  <string>SplatWallpaperEngine</string>
  <key>CFBundleIdentifier</key>
  <string>$BUNDLE_ID</string>
  <key>CFBundleIconFile</key>
  <string>AppIcon</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundleName</key>
  <string>$APP_NAME</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleShortVersionString</key>
  <string>$APP_VERSION</string>
  <key>CFBundleVersion</key>
  <string>5</string>
  <key>LSMinimumSystemVersion</key>
  <string>14.0</string>
  <key>LSUIElement</key>
  <true/>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

codesign --force --deep --sign - "$APP_PATH"

ln -s /Applications "$DMG_ROOT/Applications"
cp -R "$APP_PATH" "$DMG_ROOT/"

hdiutil create \
  -volname "$APP_NAME" \
  -srcfolder "$DMG_ROOT" \
  -ov \
  -format UDZO \
  "$DMG_PATH"

rm -rf "$DMG_ROOT"

codesign --verify --deep --strict "$APP_PATH"

echo "$APP_PATH"
echo "$DMG_PATH"
