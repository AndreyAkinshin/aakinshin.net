using Common.Collections;
using Common.Io;
using Common.Light;
using Common.Publications;
using Common.Utils;

namespace Generate.Papers;

public class PaperStorage : LightStorage<PaperFile, PaperEntry>
{
    private readonly Dictionary<string, PaperFile> hashIdToPaper = new();
    private readonly HashSet<string> ids = [];

    public PaperStorage() : base(FileSystem.Papers)
    {
        foreach (var paperFile in Files)
        {
            ids.Add(paperFile.Id);
            var pubEntry = paperFile.Entry.PublicationEntry;
            if (pubEntry != null)
                hashIdToPaper[pubEntry.GetHashId()] = paperFile;
        }
    }

    public static void Refresh() => new PaperStorage().SaveAll();

    public PaperStorage ImportBibFromPath(string targetPath)
    {
        if (Directory.Exists(targetPath))
        {
            foreach (var file in Directory.GetFiles(targetPath, "*.bib"))
                ImportBibFromPath(file);
            return this;
        }

        foreach (var entry in PublicationEntry.ReadAll(PublicationLanguage.English, targetPath))
            Import(entry, true); //.DownloadPdf();

        return this;
    }

    public PaperFile Import(PublicationEntry entry, bool preserveKey)
    {
        if (hashIdToPaper.ContainsKey(entry.GetHashId()))
        {
            var file = hashIdToPaper[entry.GetHashId()];
            Logger.Info($"[{file.Id}] Exists");
            return file;
        }

        var id = preserveKey ? entry.Key : entry.GetNiceKey();
        if (ids.Contains(id))
        {
            for (var c = 'a'; c <= 'z'; c++)
                if (!ids.Contains(id + c))
                {
                    id += c;
                    break;
                }

            if (ids.Contains(id))
                throw new Exception("Key exists: " + id);
        }

        entry.Key = id;

        var orderedDictionary = new OrderedDictionary<string, string>
        {
            ["Bib"] = entry.FormatBib()
        };
        var md = new LightMd(orderedDictionary);
        var content = new LightContent(id, LightYaml.CreateEmpty(), md);
        var paperEntry = new PaperEntry(content);
        var paperFile = new PaperFile(paperEntry);

        Add(paperFile);
        hashIdToPaper[entry.GetHashId()] = paperFile;
        ids.Add(id);
        return paperFile;
    }
}