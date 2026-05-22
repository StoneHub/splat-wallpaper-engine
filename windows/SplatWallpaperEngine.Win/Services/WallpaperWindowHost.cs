using System.Runtime.InteropServices;
using System.Text;
using System.Windows;

namespace SplatWallpaperEngine.Win.Services;

public sealed class WallpaperWindowHost
{
    private const int GWL_EXSTYLE = -20;
    private const int WS_EX_TOOLWINDOW = 0x00000080;
    private const int WS_EX_TRANSPARENT = 0x00000020;

    public bool AttachBehindDesktopIcons(nint wallpaperWindow)
    {
        var workerW = FindWallpaperWorkerW();
        if (workerW == nint.Zero)
        {
            return false;
        }

        SetParent(wallpaperWindow, workerW);
        var style = GetWindowLong(wallpaperWindow, GWL_EXSTYLE);
        SetWindowLong(wallpaperWindow, GWL_EXSTYLE, style | WS_EX_TOOLWINDOW | WS_EX_TRANSPARENT);
        return true;
    }

    public void DetachFromDesktop(Window window)
    {
        var interop = new System.Windows.Interop.WindowInteropHelper(window);
        var handle = interop.Handle;
        SetParent(handle, nint.Zero);

        var style = GetWindowLong(handle, GWL_EXSTYLE);
        SetWindowLong(handle, GWL_EXSTYLE, style & ~WS_EX_TRANSPARENT);
    }

    private static nint FindWallpaperWorkerW()
    {
        var progman = FindWindow("Progman", null);
        if (progman == nint.Zero)
        {
            return nint.Zero;
        }

        _ = SendMessageTimeout(
            progman,
            0x052C,
            nint.Zero,
            nint.Zero,
            SendMessageTimeoutFlags.SMTO_NORMAL,
            1000,
            out _);

        nint workerW = nint.Zero;

        EnumWindows((topHandle, _) =>
        {
            var shellView = FindWindowEx(topHandle, nint.Zero, "SHELLDLL_DefView", null);
            if (shellView == nint.Zero)
            {
                return true;
            }

            workerW = FindWindowEx(nint.Zero, topHandle, "WorkerW", null);
            return false;
        }, nint.Zero);

        return workerW == nint.Zero ? progman : workerW;
    }

    private delegate bool EnumWindowsProc(nint hwnd, nint lParam);

    [DllImport("user32.dll")]
    private static extern bool EnumWindows(EnumWindowsProc enumProc, nint lParam);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern nint FindWindow(string? lpClassName, string? lpWindowName);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern nint FindWindowEx(nint hwndParent, nint hwndChildAfter, string? lpszClass, string? lpszWindow);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern nint SetParent(nint hWndChild, nint hWndNewParent);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern int GetWindowLong(nint hWnd, int nIndex);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern int SetWindowLong(nint hWnd, int nIndex, int dwNewLong);

    [DllImport("user32.dll", SetLastError = true)]
    private static extern nint SendMessageTimeout(
        nint hWnd,
        uint msg,
        nint wParam,
        nint lParam,
        SendMessageTimeoutFlags flags,
        uint timeout,
        out nint result);

    [Flags]
    private enum SendMessageTimeoutFlags : uint
    {
        SMTO_NORMAL = 0x0000
    }
}
