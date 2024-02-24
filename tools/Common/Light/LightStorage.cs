using Common.Io;
using Common.Utils;

namespace Common.Light;

public class LightStorage<TFile, TEntry> : ILightStorage
    where TFile : LightFile<TEntry>
    where TEntry : LightEntry
{
    private readonly DirectoryPath root;
    public List<TFile> Files { get; } = [];

    protected LightStorage(DirectoryPath root)
    {
        this.root = root;
        foreach (var filePath in root.EnumerateFiles("*.md").Where(file => !LightFileHelper.IsServiceFile(file)))
        {
            var content = LightContent.Parse(filePath);
            var entry = Activator.CreateInstance(typeof(TEntry), content) as TEntry;
            var file = Activator.CreateInstance(typeof(TFile), entry) as TFile;
            if (file == null)
                throw new InvalidOperationException($"Failed to create {typeof(TFile).Name}");
            file.ApplyFromFile(filePath);
            Files.Add(file);
        }
    }

    public virtual void SaveAll()
    {
        var existingFiles = root
            .EnumerateFiles("*.md")
            .Where(file => !LightFileHelper.IsServiceFile(file))
            .ToHashSet();
        var newFiles = Files
            .Select(file => file.FilePath)
            .ToList();

        foreach (var file in Files)
            file.Save();

        var obsoleteFiles = existingFiles.Except(newFiles);
        foreach (var obsoleteFile in obsoleteFiles)
            obsoleteFile.Delete();
    }

    public ILightFile? GetFile(string id) => Files.FirstOrDefault(file1 => file1.Entry.Id == id);

    public virtual Task FetchAsync()
    {
        foreach (var file in Files)
            file.FetchAsync();
        return Task.CompletedTask;
    }

    public TFile Add(TFile file)
    {
        var existingFile = Files.FirstOrDefault(existingFile => existingFile.Entry.Id == file.Entry.Id);
        if (existingFile != null)
        {
            Logger.Info($"[{file.Entry.Id}] Exist");
            return existingFile;
        }

        file.Save();
        Files.Add(file);
        Logger.Info($"[{file.Entry.Id}] Added");
        return file;
    }
}