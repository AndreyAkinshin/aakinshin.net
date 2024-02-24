using System.Text.RegularExpressions;
using Common.Extensions;
using Common.Helpers;
using Common.Io;
using Common.Publications;
using Common.Utils;

namespace Generate.Papers;

public class PaperPdfResolver
{
    public static readonly PaperPdfResolver Instance = new();

    private readonly Lazy<string[]> lazyNoPdfKeys = new(() => FileSystem.Papers.File(".no-pdf.txt").ReadAllLines());
    public IReadOnlyList<string> NoPdfKeys => lazyNoPdfKeys.Value;

    public async Task<string> GetPdfUrlAsync(string key, PublicationEntry entry)
    {
        var prefix = $"[{key}]";

        var doi = entry.GetDoi();
        if (doi.StartsWith("10.48550/ARXIV."))
            return doi.Replace("10.48550/ARXIV.", "https://arxiv.org/pdf/") + ".pdf";

        var arxiv = entry.GetArxiv();
        if (arxiv.IsNotBlank())
            return $"https://arxiv.org/pdf/{arxiv}.pdf";

        var customPdfUrl = entry.GetCustomPdfUrl();
        if (customPdfUrl.IsNotBlank())
            return customPdfUrl;

        var pdfUrls = entry.GetUrls().Where(url => url.EndsWith(".pdf")).ToList();
        if (pdfUrls.Any())
            return pdfUrls.First();

        var mainUrl = entry.GetMainUrl();
        if (mainUrl.StartsWith("https://cran.r-project.org/web/packages/") && mainUrl.EndsWith("/index.html"))
        {
            var packageName = mainUrl.Split('/').SkipLast(1).Last();
            return mainUrl.Replace("index.html", $"{packageName}.pdf");
        }

        if (doi.IsNotBlank())
        {
            var sciHubHtml = await WebHelper.DownloadStringAsync($"https://sci-hub.se/{doi}");
            if (sciHubHtml.IsBlank())
            {
                Logger.Error($"{prefix} No Sci-Hub response");
                return "";
            }

            var pdfRegex = new Regex(@"<embed[^>]*src=""([^""]*)", RegexOptions.IgnoreCase);
            var pdfMatch = pdfRegex.Match(sciHubHtml);
            if (!pdfMatch.Success)
            {
                Logger.Error($"{prefix} No PDF url in Sci-Hub response");
                return "";
            }

            var pdfUrl = pdfMatch.Groups[1].Value;
            if (pdfUrl.StartsWith("/downloads/"))
                pdfUrl = "https://sci-hub.se" + pdfUrl;
            if (pdfUrl.StartsWith("//"))
                pdfUrl = "https:" + pdfUrl;
            return pdfUrl;
        }

        return "";
    }
}