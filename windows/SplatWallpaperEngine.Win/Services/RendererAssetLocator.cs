using System.IO;

namespace SplatWallpaperEngine.Win.Services;

public static class RendererAssetLocator
{
    public static string RendererDirectory
    {
        get
        {
            var appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
            return Path.Combine(appData, "SplatWallpaperEngine", "Renderer");
        }
    }

    public static string IndexHtmlPath => Path.Combine(RendererDirectory, "index.html");

    public static void EnsureRuntimeRenderer()
    {
        var source = SourceRendererDirectory;
        if (!Directory.Exists(source))
        {
            throw new DirectoryNotFoundException($"Renderer source not found: {source}");
        }

        Directory.CreateDirectory(RendererDirectory);
        CopyDirectory(source, RendererDirectory);
    }

    private static string SourceRendererDirectory
    {
        get
        {
            var baseDirectory = AppContext.BaseDirectory;
            var bundled = Path.Combine(baseDirectory, "Renderer");
            if (File.Exists(Path.Combine(bundled, "index.html")))
            {
                return bundled;
            }

            return Path.GetFullPath(Path.Combine(
                baseDirectory,
                "..",
                "..",
                "..",
                "..",
                "..",
                "Sources",
                "SplatWallpaperEngine",
                "Renderer"));
        }
    }

    private static void CopyDirectory(string source, string destination)
    {
        foreach (var directory in Directory.EnumerateDirectories(source, "*", SearchOption.AllDirectories))
        {
            Directory.CreateDirectory(directory.Replace(source, destination));
        }

        foreach (var file in Directory.EnumerateFiles(source, "*", SearchOption.AllDirectories))
        {
            var target = file.Replace(source, destination);
            Directory.CreateDirectory(Path.GetDirectoryName(target)!);
            File.Copy(file, target, overwrite: true);
        }
    }
}
