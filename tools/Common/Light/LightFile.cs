using Common.Io;
using Common.Utils;

namespace Common.Light;

public interface ILightFile
{
    FilePath FilePath { get; }
    LightContent Content { get; }

    void OpenInVsCode();
    void ApplyFromFile(FilePath filePath);
    void Save();
    DirectoryPath GetRoot();
    Task FetchAsync();
}

public abstract class LightFile<T>(T entry) : ILightFile where T : LightEntry
{
    public T Entry { get; } = entry;

    public FilePath FilePath => GetRoot().File(Entry.Id + ".md");
    public LightContent Content => Entry.Content;
    public void OpenInVsCode() => FilePath.OpenInVsCode();
    public void ApplyFromFile(FilePath filePath) => Entry.ApplyFromFile(filePath);

    public void Save()
    {
        var oldContent = FilePath.Exists ? FilePath.ReadAllText() : "";
        var newContent = Entry.Format();
        if (oldContent.Replace("\r", "").Replace("\n", "") != newContent.Replace("\r", "").Replace("\n", ""))
        {
            Logger.Info($"[{Entry.Id}] Update");
            FilePath.WriteAllText(newContent);
        }
    }

    public abstract DirectoryPath GetRoot();
    public virtual Task FetchAsync() => Task.CompletedTask;
}