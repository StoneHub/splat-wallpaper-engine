using System.IO;

namespace SplatWallpaperEngine.Win.Services;

public sealed class SceneStore
{
    private readonly string _sceneDirectory;
    private readonly string _currentScenePathFile;

    public SceneStore()
    {
        var appData = Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData);
        var root = Path.Combine(appData, "SplatWallpaperEngine");
        _sceneDirectory = Path.Combine(root, "Scenes");
        _currentScenePathFile = Path.Combine(root, "current-scene.txt");
        Directory.CreateDirectory(_sceneDirectory);
    }

    public string? CurrentScenePath
    {
        get
        {
            if (!File.Exists(_currentScenePathFile))
            {
                return null;
            }

            var path = File.ReadAllText(_currentScenePathFile).Trim();
            return File.Exists(path) ? path : null;
        }
    }

    public string InstallScene(string sourcePath)
    {
        var destination = Path.Combine(_sceneDirectory, Path.GetFileName(sourcePath));
        File.Copy(sourcePath, destination, overwrite: true);
        File.WriteAllText(_currentScenePathFile, destination);
        return destination;
    }
}
