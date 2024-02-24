using Common.Extensions;
using Common.Helpers;
using Common.Io;
using Common.Light;
using Common.Publications;
using Common.Utils;

namespace Generate.Papers;

public class PaperFile(PaperEntry entry) : LightFile<PaperEntry>(entry)
{
    public string Id => Entry.Id;
    public void DownloadPdf() => DownloadPdfAsync().Wait();

    public async Task DownloadPdfAsync()
    {
        var prefix = "[" + FilePath.NameWithoutExtension + "]";
        var lastUrl = "";

        var pubEntry = Entry.PublicationEntry;
        if (pubEntry == null)
        {
            Logger.Error($"{prefix} No bib");
            return;
        }

        try
        {
            if (pubEntry.Type == PublicationEntryType.Book)
            {
                Logger.Trace($"{prefix} Skip: Book");
                return;
            }

            if (pubEntry.Type == PublicationEntryType.PhdThesis)
            {
                Logger.Trace($"{prefix} Skip: PhdThesis");
                return;
            }

            if (PaperPdfResolver.Instance.NoPdfKeys.Contains(FilePath.NameWithoutExtension))
            {
                Logger.Trace($"{prefix} Skip: NO-PDF List");
                return;
            }

            var pdfFilePath = FileSystem.PdfPapers.File($"{FilePath.NameWithoutExtension}.pdf");
            if (pdfFilePath.Exists)
            {
                Logger.Trace($"{prefix} Exist");
                return;
            }

            var pdfUrl = await PaperPdfResolver.Instance.GetPdfUrlAsync(FilePath.NameWithoutExtension, pubEntry);
            if (pdfUrl.IsBlank())
            {
                Logger.Error($"{prefix} No PDF");
                return;
            }

            lastUrl = pdfUrl;
            await WebHelper.DownloadFileAsync(pdfUrl, pdfFilePath);
            Logger.Info($"{prefix} Downloaded: {pdfFilePath}");
        }
        catch (InvalidOperationException ex)
        {
            if (ex.Message.StartsWith("An invalid request URI was provided"))
                Logger.Error($"{prefix} Invalid URI: {lastUrl}");
            else
                Logger.Error($"{prefix} {ex.GetType().Name}: {ex.Message}");
        }
        catch (HttpRequestException ex)
        {
            Logger.Error($"{prefix} {ex.GetType().Name}: {ex.Message} | {lastUrl}");
        }
        catch (Exception ex)
        {
            Logger.Error($"{prefix} {ex.GetType().Name}: {ex.Message}");
        }
    }

    public override DirectoryPath GetRoot() => FileSystem.Papers;
}