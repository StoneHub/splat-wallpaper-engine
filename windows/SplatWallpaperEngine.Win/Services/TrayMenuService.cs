using System.Drawing;
using System.IO;
using System.Windows;
using Forms = System.Windows.Forms;

namespace SplatWallpaperEngine.Win.Services;

public sealed class TrayMenuService : IDisposable
{
    private readonly MainWindow _window;
    private readonly Forms.NotifyIcon _notifyIcon;
    private readonly Forms.ToolStripMenuItem _interactionItem;
    private readonly Forms.ToolStripMenuItem _rotationItem;
    private readonly Forms.ToolStripMenuItem _vSyncItem;
    private readonly Forms.ToolStripMenuItem _speedItem;
    private readonly Forms.ToolStripMenuItem _fpsItem;

    public TrayMenuService(MainWindow window)
    {
        _window = window;
        _interactionItem = new Forms.ToolStripMenuItem("Interaction Mode", null, async (_, _) => await ToggleInteractionAsync());
        _rotationItem = new Forms.ToolStripMenuItem("Rotate", null, async (_, _) => await ToggleRotationAsync());
        _vSyncItem = new Forms.ToolStripMenuItem("VSync Rotation", null, async (_, _) => await ToggleVSyncAsync());
        _speedItem = new Forms.ToolStripMenuItem(RotationSpeedLabel());
        _fpsItem = new Forms.ToolStripMenuItem(RotationFpsLabel());

        _speedItem.DropDownItems.AddRange(CreateSpeedItems());
        _fpsItem.DropDownItems.AddRange(CreateFpsItems());

        var menu = new Forms.ContextMenuStrip();
        menu.Items.Add("Open SOG Scene...", null, async (_, _) => await _window.OpenSceneAsync());
        menu.Items.Add("Show Wallpaper", null, (_, _) => _window.ShowWallpaper());
        menu.Items.Add("Hide Wallpaper", null, (_, _) => _window.HideWallpaper());
        menu.Items.Add(new Forms.ToolStripSeparator());
        menu.Items.Add(_interactionItem);
        menu.Items.Add(_rotationItem);
        menu.Items.Add(_vSyncItem);
        menu.Items.Add(_speedItem);
        menu.Items.Add(_fpsItem);
        menu.Items.Add(new Forms.ToolStripSeparator());
        menu.Items.Add("About Splat Wallpaper Engine", null, (_, _) => ShowAbout());
        menu.Items.Add("Quit", null, (_, _) => System.Windows.Application.Current.Shutdown());

        _notifyIcon = new Forms.NotifyIcon
        {
            Text = "Splat Wallpaper Engine",
            Icon = IconFactory.CreateTrayIcon(),
            ContextMenuStrip = menu,
            Visible = false
        };
    }

    public void Show()
    {
        _notifyIcon.Visible = true;
    }

    public void Dispose()
    {
        _notifyIcon.Visible = false;
        _notifyIcon.Dispose();
    }

    private async Task ToggleInteractionAsync()
    {
        await _window.ToggleInteractionModeAsync();
        _interactionItem.Checked = _window.IsInteractive;
    }

    private async Task ToggleRotationAsync()
    {
        await _window.ToggleRotationAsync();
        _rotationItem.Checked = _window.IsRotating;
    }

    private async Task ToggleVSyncAsync()
    {
        await _window.SetRotationVSyncAsync(!_window.UsesVSync);
        _vSyncItem.Checked = _window.UsesVSync;
    }

    private Forms.ToolStripItem[] CreateSpeedItems()
    {
        double[] speeds = [0.01, 0.05, 0.1, 0.25, 0.5, 1, 2, 4, 8, 16, 36];
        return speeds.Select(speed => new Forms.ToolStripMenuItem($"{speed:0.##} deg/s", null, async (_, _) =>
        {
            await _window.SetRotationSpeedAsync(speed);
            _speedItem.Text = RotationSpeedLabel();
        })).ToArray();
    }

    private Forms.ToolStripItem[] CreateFpsItems()
    {
        double[] frames = [10, 15, 24, 30, 45, 60];
        return frames.Select(fps => new Forms.ToolStripMenuItem($"{fps:0} fps", null, async (_, _) =>
        {
            await _window.SetRotationFpsAsync(fps);
            _fpsItem.Text = RotationFpsLabel();
        })).ToArray();
    }

    private string RotationSpeedLabel() => $"Rotate Speed: {_window.RotationSpeed:0.##} deg/s";

    private string RotationFpsLabel() => $"Rotate FPS Cap: {_window.RotationFps:0} fps";

    private static void ShowAbout()
    {
        MessageBox.Show(
            "Splat Wallpaper Engine\n\nInteractive desktop wallpaper for Gaussian splats.\n\nGitHub: https://github.com/StoneHub\nPersonal site: https://monroes.tech",
            "About Splat Wallpaper Engine",
            MessageBoxButton.OK,
            MessageBoxImage.Information);
    }
}
