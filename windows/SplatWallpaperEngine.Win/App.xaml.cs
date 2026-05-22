using System.Windows;
using SplatWallpaperEngine.Win.Services;

namespace SplatWallpaperEngine.Win;

public partial class App : System.Windows.Application
{
    private MainWindow? _window;
    private TrayMenuService? _tray;

    protected override void OnStartup(StartupEventArgs e)
    {
        base.OnStartup(e);

        _window = new MainWindow();
        _tray = new TrayMenuService(_window);
        _tray.Show();

        _window.ShowWallpaper();
    }

    protected override void OnExit(ExitEventArgs e)
    {
        _tray?.Dispose();
        base.OnExit(e);
    }
}
