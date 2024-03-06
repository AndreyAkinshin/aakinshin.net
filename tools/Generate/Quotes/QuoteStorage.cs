using Common.Io;
using Common.Light;
using Generate.Books;
using Generate.Papers;
using Generate.Web;

namespace Generate.Quotes;

public class QuoteStorage : LightStorage<QuoteFile, QuoteEntry>
{
    public QuoteStorage() : base(FileSystem.Quotes)
    {
        var paperStorage = new PaperStorage();
        var bookStorage = new BookStorage();
        var webStorage = new WebStorage();
        foreach (var quoteFile in Files)
        {
            var quoteEntry = quoteFile.Entry;
            var quoteYaml = quoteEntry.Content.Yaml;

            var source = quoteEntry.Content.Yaml.GetScalar("source");
            if (source == null) continue;

            var sourceYaml = paperStorage.Files.FirstOrDefault(paperFile => paperFile.Id == source)?.Entry.Content.Yaml;
            if (sourceYaml == null)
                sourceYaml = bookStorage.Files.FirstOrDefault(bookFile => bookFile.Id == source)?.Entry.Content.Yaml;
            if (sourceYaml == null)
                sourceYaml = webStorage.Files.FirstOrDefault(webFile => webFile.Id == source)?.Entry.Content.Yaml;
            if (sourceYaml == null)
                continue;

            quoteYaml.Set("authors", sourceYaml.GetArray("authors") ?? []);
            quoteYaml.Set("year", sourceYaml.GetScalar("year") ?? "");
            quoteYaml.Set("date", sourceYaml.GetScalar("date") ?? "");
            quoteYaml.Set("sourceTitle", sourceYaml.GetScalar("title") ?? "");
            quoteFile.Save();
        }
    }
}