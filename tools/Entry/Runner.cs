using System.Diagnostics;
using System.Text;
using Common.Extensions;
using Common.Io;
using Common.Publications;
using Common.Utils;
using Generate;
using Generate.Media;
using Generate.OpenSource;
using Generate.Papers;
using Generate.Talks;
using Generate.Web;

namespace Entry;

public class Runner
{
    public static readonly Runner Instance = new();

    public void Rename(string oldId, string newId) => new GlobalStorage().Rename(oldId, newId);

    public void Update()
    {
        new TalkProcessor().Run();
        new MediaProcessor().Run();
        new PublicationProcessor().Run();
        new OpenSourceProcessor().Run();

        GlobalStorage.Update();

        Relations.Create().Dump();
    }

    public void Download()
    {
        var storage = new PaperStorage();
        foreach (var file in storage.Files)
            file.DownloadPdf();
    }

    public void Doi(string doi)
    {
        var bib = PaperHelper.Instance.Doi2Bib(doi);
        if (bib.IsBlank())
        {
            Logger.Error("Failed to get BibTeX from DOI.");
            return;
        }

        var pubEntry = PublicationEntry.Read(PaperHelper.Instance.FormatBib(bib));
        new PaperStorage().Import(pubEntry, false).OpenInVsCode();
    }

    public void ImportBib(string path) =>
        new PaperStorage().ImportBibFromPath(path).Files.LastOrDefault()?.OpenInVsCode();

    public void Quote(string source)
    {
        var directoryPath = FileSystem.Quotes;
        var fileName = Guid.NewGuid().ToString("D") + ".md";
        var filePath = directoryPath.File(fileName);
        var content = CreateQuote(source);
        filePath.WriteAllText(content);
        Console.WriteLine($"Generated: {fileName}");
        Process.Start("code", filePath);
    }

    private string CreateQuote(string source)
    {
        var builder = new StringBuilder();
        builder.AppendLine("---");
        builder.AppendLine("title: \"\"");
        builder.AppendLine($"source: {source}");
        builder.AppendLine("page: ");
        builder.AppendLine("---");
        builder.AppendLine();
        builder.AppendLine("> ");
        return builder.ToString();
    }

    public void Web(string url) => new WebStorage().Import(url).OpenInVsCode();
}