using System.Globalization;
using System.Text;
using Common.Utils;
using Generate.Common;

namespace Generate.Media;

public class MediaFormatter
{
    private readonly string openingQuotationMark, closingQuotationMark, dateFormat, culture;

    public static readonly MediaFormatter Ru = new MediaFormatter("«", "»", "dd MMMM yyyy", "ru-RU");
    public static readonly MediaFormatter En = new MediaFormatter("“", "”", "MMMM dd, yyyy", "en-US");

    private MediaFormatter(string openingQuotationMark, string closingQuotationMark, string dateFormat,
        string culture)
    {
        this.openingQuotationMark = openingQuotationMark;
        this.closingQuotationMark = closingQuotationMark;
        this.dateFormat = dateFormat;
        this.culture = culture;
    }

    private string Quote(string s) => openingQuotationMark + s + closingQuotationMark;

    public string ToHtmlMain(MediaItem item)
    {
        var builder = new StringBuilder();

        if (item.Title != "")
        {
            builder.Append("  ");
            builder.Append($"<a href='{item.Url}'>");
            builder.Append(item.Title);
            builder.Append("</a>");
            builder.AppendLine("<br />");
        }

        var details = new List<string>();

        if (item.Host != null)
            details.Add(item.Host);

        if (item.Date != null)
        {
            var dateStr = item.Date.Value.ToString(dateFormat, new CultureInfo(culture));
            details.Add(dateStr);
        }

        if (details.Any())
            builder.AppendLine("  <i>" + string.Join(", ", details) + "</i>");

        return builder.ToString();
    }


    public string GetTypeLabel(string type, string lang)
    {
        switch (type + "-" + lang.Substring(0, 2))
        {
            case "interview-ru":
                return "Интервью";
            case "podcast-ru":
                return "Подкаст";
            case "review-ru":
                return "Обзор";
            case "interview-en":
                return "Interview";
            case "podcast-en":
                return "Podcast";
            case "review-en":
                return "Review";
        }

        return type;
    }

    public string GetKindTitle(MediaItem item, string culture)
    {
        if (culture.StartsWith("ru"))
            switch (item.Kind)
            {
                case "text":
                    return "Текст";
                case "video":
                    return item.Url.Contains("youtube", StringComparison.OrdinalIgnoreCase) ? "Видео (YouTube)" : "Видео";
                case "audio":
                    return "Аудио";
                default:
                    throw new Exception($"Unknown kind: {item.Kind}");
            }

        if (culture.StartsWith("en"))
            switch (item.Kind)
            {
                case "text":
                    return "Text";
                case "video":
                    return item.Url.Contains("youtube", StringComparison.OrdinalIgnoreCase) ? "Video (YouTube)" : "Video";
                case "audio":
                    return "Audio";
                default:
                    throw new Exception($"Unknown kind: {item.Kind}");
            }

        throw new Exception($"Unknown culture: {culture}");
    }


    public string ToToml(List<MediaItem> items)
    {
        var builder = new StringBuilder();
        builder.AppendLine("Indexer = true");
        builder.AppendLine();
        var types = items.Select(t => t.Year).Distinct().OrderByDescending(x => x).ToList();
        var counter = items.Count;
        foreach (var type in types)
        {
            var typeItems = items.Where(t => t.Year == type).OrderByDescending(t => t.Date).ToList();
            foreach (var item in typeItems)
            {
                builder.AppendLine("[[item]]");
                builder.AppendLine($"Group = \"{item.Year}\"");
                builder.AppendLine($"Html = \"{Util.Escape(ToHtmlMain(item))}\"");
                builder.AppendLine($"Index = {counter--}");

                if (!string.IsNullOrEmpty(item.Lang))
                {
                    builder.AppendLine("  [[item.badge]]");
                    builder.AppendLine($"  Label = \"{item.Lang.ToUpper()}\"");
                }

                if (!string.IsNullOrEmpty(item.Type))
                {
                    builder.AppendLine("  [[item.badge]]");
                    builder.AppendLine($"  Label = \"{GetTypeLabel(item.Type, culture)}\"");
                }

                if (!string.IsNullOrEmpty(item.Kind))
                {
                    builder.AppendLine("  [[item.badge]]");
                    builder.AppendLine($"  Label = \"{GetKindTitle(item, culture)}\"");
                }

                builder.AppendLine();
            }
        }

        return builder.ToString();
    }
}