using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

namespace SplatWallpaperEngine.Win.Services;

public static class IconFactory
{
    public static Icon CreateTrayIcon()
    {
        using var bitmap = new Bitmap(64, 64, PixelFormat.Format32bppArgb);
        using var graphics = Graphics.FromImage(bitmap);
        graphics.SmoothingMode = SmoothingMode.AntiAlias;
        graphics.Clear(Color.Transparent);

        using var background = RoundedRectangle(new RectangleF(4, 4, 56, 56), 14);
        using var backgroundBrush = new SolidBrush(Color.FromArgb(255, 5, 7, 9));
        graphics.FillPath(backgroundBrush, background);

        using var screenBrush = new SolidBrush(Color.FromArgb(255, 28, 34, 39));
        using var screen = RoundedRectangle(new RectangleF(12, 20, 40, 30), 5);
        graphics.FillPath(screenBrush, screen);
        using var screenPen = new Pen(Color.FromArgb(90, 255, 255, 255), 2);
        graphics.DrawPath(screenPen, screen);

        DrawSplat(graphics, 25, 32, 9, Color.FromArgb(230, 52, 235, 124));
        DrawSplat(graphics, 35, 31, 10, Color.FromArgb(220, 204, 235, 45));
        DrawSplat(graphics, 40, 25, 7, Color.FromArgb(210, 30, 168, 235));
        DrawSplat(graphics, 31, 41, 7, Color.FromArgb(200, 235, 92, 54));

        using var orbitPen = new Pen(Color.FromArgb(230, 245, 255, 250), 4);
        graphics.DrawEllipse(orbitPen, 16, 25, 34, 20);

        var handle = bitmap.GetHicon();
        return Icon.FromHandle(handle);
    }

    private static void DrawSplat(Graphics graphics, float x, float y, float radius, Color color)
    {
        using var brush = new SolidBrush(color);
        graphics.FillEllipse(brush, x - radius, y - radius, radius * 2, radius * 2);
    }

    private static GraphicsPath RoundedRectangle(RectangleF rect, float radius)
    {
        var path = new GraphicsPath();
        var diameter = radius * 2;
        path.AddArc(rect.Left, rect.Top, diameter, diameter, 180, 90);
        path.AddArc(rect.Right - diameter, rect.Top, diameter, diameter, 270, 90);
        path.AddArc(rect.Right - diameter, rect.Bottom - diameter, diameter, diameter, 0, 90);
        path.AddArc(rect.Left, rect.Bottom - diameter, diameter, diameter, 90, 90);
        path.CloseFigure();
        return path;
    }
}
