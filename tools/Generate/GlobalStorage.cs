using Common.Io;
using Common.Light;
using Common.Utils;
using Generate.Books;
using Generate.Media;
using Generate.Papers;
using Generate.Quotes;
using Generate.Talks;
using Generate.Web;

namespace Generate;

public class GlobalStorage : ILightStorage
{
    public WebStorage WebStorage { get; } = new();
    public PaperStorage PaperStorage { get; } = new();
    public QuoteStorage QuoteStorage { get; } = new();
    public BookStorage BookStorage { get; } = new();
    public TalkStorage TalkStorage { get; } = new();
    public MediaStorage MediaStorage { get; } = new();

    public IEnumerable<ILightStorage> Storages =>
        [WebStorage, PaperStorage, QuoteStorage, BookStorage, TalkStorage, MediaStorage];

    public static void Update() => new GlobalStorage().SaveAll();

    public void SaveAll()
    {
        foreach (var storage in Storages)
            storage.SaveAll();
    }

    public ILightFile? GetFile(string id) =>
        Storages.Select(storage => storage.GetFile(id)).OfType<ILightFile>().FirstOrDefault();

    public async Task FetchAsync()
    {
        foreach (var storage in Storages)
            await storage.FetchAsync();
    }

    public void Rename(string oldId, string newId)
    {
        var prefix = $"[{oldId}->{newId}] ";

        var oldFile = GetFile(oldId);
        if (oldFile == null)
        {
            Logger.Error(prefix + $"'{oldId}' not found");
            return;
        }

        var newFilePath = oldFile.FilePath.Parent?.File(newId + ".md");
        if (newFilePath == null)
        {
            Logger.Error(prefix + "Failed to create new file path");
            return;
        }

        var oldPattern1 = "{{< link " + oldId + " >}}";
        var newPattern1 = "{{< link " + newId + " >}}";
        var oldPattern2 = "{{< ref " + oldId + " >}}";
        var newPattern2 = "{{< ref " + newId + " >}}";
        foreach (var filePath in FileSystem.Content.EnumerateFilesRecursively("*.md"))
        {
            if (LightFileHelper.IsServiceFile(filePath)) continue;

            var oldContent = filePath.ReadAllText();
            var newContent = oldContent.Replace(oldPattern1, newPattern1).Replace(oldPattern2, newPattern2);
            if (oldContent != newContent)
            {
                Logger.Info(prefix + $"[{filePath.NameWithoutExtension}] Update");
                filePath.WriteAllText(newContent);
            }
        }

        oldFile.Content.Yaml.Set("id", newId);
        oldFile.Save();
        oldFile.FilePath.RenameTo(newFilePath);
        Logger.Info($"{prefix}Done");
    }
}