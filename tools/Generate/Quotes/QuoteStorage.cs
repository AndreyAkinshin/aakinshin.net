using Common.Io;
using Common.Light;
using Generate.Papers;

namespace Generate.Quotes;

public class QuoteStorage : LightStorage<QuoteFile, QuoteEntry>
{
    public QuoteStorage(): base(FileSystem.Quotes)
    {
        var paperStorage = new PaperStorage();
        foreach (var quoteFile in Files)
        {
            var quoteEntry = quoteFile.Entry;
            var quoteYaml = quoteEntry.Content.Yaml;

            var source = quoteEntry.Content.Yaml.GetScalar("source");
            if (source == null) continue;

            var paperFile = paperStorage.Files.FirstOrDefault(paperFile => paperFile.Id == source);
            if (paperFile == null) continue;

            var paperYaml = paperFile.Entry.Content.Yaml;
            quoteYaml.Set("authors", paperYaml.GetArray("authors") ?? []);
            quoteYaml.Set("year", paperYaml.GetScalar("year") ?? "");
            quoteYaml.Set("date", paperYaml.GetScalar("date") ?? "");
            quoteYaml.Set("sourceTitle", paperYaml.GetScalar("title") ?? "");
            quoteFile.Save();
        }
    }
}