using System.IO;
using System.Windows;
using System.Windows.Interop;
using Microsoft.Win32;
using SplatWallpaperEngine.Win.Services;

namespace SplatWallpaperEngine.Win;

public partial class MainWindow : Window
{
    private readonly SceneStore _sceneStore = new();
    private readonly WallpaperWindowHost _wallpaperHost = new();
    private bool _isInteractive;
    private bool _isRotating;
    private bool _usesVSync;
    private double _rotationSpeed = 8.0;
    private double _rotationFps = 30.0;

    public MainWindow()
    {
        InitializeComponent();
        Loaded += OnLoaded;
    }

    public bool IsInteractive => _isInteractive;
    public bool IsRotating => _isRotating;
    public bool UsesVSync => _usesVSync;
    public double RotationSpeed => _rotationSpeed;
    public double RotationFps => _rotationFps;

    public async void ShowWallpaper()
    {
        if (!IsVisible)
        {
            Show();
        }

        WindowState = WindowState.Normal;
        WindowStartupLocation = WindowStartupLocation.Manual;
        Left = SystemParameters.VirtualScreenLeft;
        Top = SystemParameters.VirtualScreenTop;
        Width = SystemParameters.VirtualScreenWidth;
        Height = SystemParameters.VirtualScreenHeight;

        await AttachToDesktopAsync();
    }

    public void HideWallpaper()
    {
        Hide();
    }

    public async Task OpenSceneAsync()
    {
        var dialog = new OpenFileDialog
        {
            Title = "Choose a Gaussian Splat SOG Scene",
            Filter = "SuperSplat scene (*.sog)|*.sog",
            Multiselect = false
        };

        if (dialog.ShowDialog(this) != true)
        {
            return;
        }

        var installed = _sceneStore.InstallScene(dialog.FileName);
        await LoadRendererAsync(installed);
    }

    public async Task ToggleInteractionModeAsync()
    {
        _isInteractive = !_isInteractive;

        if (_isInteractive)
        {
            _wallpaperHost.DetachFromDesktop(this);
            WindowStyle = WindowStyle.None;
            Topmost = true;
            Activate();
        }
        else
        {
            Topmost = false;
            await AttachToDesktopAsync();
        }
    }

    public async Task ToggleRotationAsync()
    {
        _isRotating = !_isRotating;
        await SetRotationSpeedAsync(_rotationSpeed);
        await SetRotationFpsAsync(_rotationFps);
        await SetRotationVSyncAsync(_usesVSync);
        await Renderer.ExecuteScriptAsync($"window.splatWallpaperSetRotate?.({_isRotating.ToString().ToLowerInvariant()});");
    }

    public async Task SetRotationSpeedAsync(double speed)
    {
        _rotationSpeed = Math.Clamp(speed, 0.01, 90);
        await Renderer.ExecuteScriptAsync($"window.splatWallpaperSetRotateSpeed?.({_rotationSpeed.ToString(System.Globalization.CultureInfo.InvariantCulture)});");
    }

    public async Task SetRotationFpsAsync(double fps)
    {
        _rotationFps = Math.Clamp(fps, 1, 60);
        await Renderer.ExecuteScriptAsync($"window.splatWallpaperSetRotateFPS?.({_rotationFps.ToString(System.Globalization.CultureInfo.InvariantCulture)});");
    }

    public async Task SetRotationVSyncAsync(bool enabled)
    {
        _usesVSync = enabled;
        await Renderer.ExecuteScriptAsync($"window.splatWallpaperSetRotateVSync?.({_usesVSync.ToString().ToLowerInvariant()});");
    }

    private async void OnLoaded(object sender, RoutedEventArgs e)
    {
        await Renderer.EnsureCoreWebView2Async();
        await LoadRendererAsync(_sceneStore.CurrentScenePath);
        await SetRotationSpeedAsync(_rotationSpeed);
        await SetRotationFpsAsync(_rotationFps);
        await SetRotationVSyncAsync(_usesVSync);
    }

    private async Task AttachToDesktopAsync()
    {
        await Dispatcher.InvokeAsync(() =>
        {
            var helper = new WindowInteropHelper(this);
            _wallpaperHost.AttachBehindDesktopIcons(helper.Handle);
        });
    }

    private async Task LoadRendererAsync(string? scenePath)
    {
        await Renderer.EnsureCoreWebView2Async();

        RendererAssetLocator.EnsureRuntimeRenderer();
        var content = scenePath is { Length: > 0 } && File.Exists(scenePath)
            ? $"?content={Uri.EscapeDataString(Path.GetFileName(scenePath))}"
            : string.Empty;

        Renderer.CoreWebView2.SetVirtualHostNameToFolderMapping(
            "splatwallpaper",
            RendererAssetLocator.RendererDirectory,
            Microsoft.Web.WebView2.Core.CoreWebView2HostResourceAccessKind.Allow);

        if (scenePath is { Length: > 0 } && File.Exists(scenePath))
        {
            File.Copy(scenePath, Path.Combine(RendererAssetLocator.RendererDirectory, Path.GetFileName(scenePath)), overwrite: true);
        }

        Renderer.Source = new Uri($"https://splatwallpaper/index.html{content}");
    }
}
