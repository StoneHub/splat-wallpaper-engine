# Windows Packaging Notes

Initial release target:

```powershell
dotnet publish -c Release -r win-x64 --self-contained false `
  -p:PublishSingleFile=false `
  -p:PublishReadyToRun=true
```

Artifact options:

- Start with a `.zip` of the publish folder for the first Windows tester build.
- Move to Inno Setup or WiX once desktop attachment behavior is proven.
- Decide whether to bundle the WebView2 Evergreen runtime installer or document it as a prerequisite.

Release asset naming:

```text
Splat-Wallpaper-Engine-Windows-x64.zip
Splat-Wallpaper-Engine-Setup.exe
```
