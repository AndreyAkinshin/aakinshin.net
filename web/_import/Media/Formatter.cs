using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;

namespace Media
{
       public class Formatter
    {
        private readonly string openingQuotationMark, closingQuotationMark, dateFormat, culture;

        public static readonly Formatter Ru = new Formatter("«", "»", "dd MMMM yyyy", "ru-RU");
        public static readonly Formatter En = new Formatter("“", "”", "MMMM dd, yyyy", "en-US");

        private Formatter(string openingQuotationMark, string closingQuotationMark, string dateFormat, string culture)
        {
            this.openingQuotationMark = openingQuotationMark;
            this.closingQuotationMark = closingQuotationMark;
            this.dateFormat = dateFormat;
            this.culture = culture;
        }

        private string Quote(string s) => openingQuotationMark + s + closingQuotationMark;

        private string QuoteWithLink(MediaItem item)
        {
            var link = item.Url;
            if (link != null)
                return $"<a href=\"{link}\">{Quote(item.Title)}</a>";
            return Quote(item.Title);
        }

        public string ToHtml(MediaItem item)
        {
            var builder = new StringBuilder();

            builder.AppendLine("<li>");
            
            if (item.Title != "")
            {
                builder.Append("  ");
                builder.AppendLine(QuoteWithLink(item));
                if (item.Lang != "")
                    builder.AppendLine("    (" + item.Lang.ToUpperInvariant() + ")");

                builder.AppendLine("  ,<br />");
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

            builder.AppendLine("</li>");

            return builder.ToString();
        }

        public string GetTypeHeader(string type, string lang)
        {
            switch (type + "-" + lang.Substring(0, 2))
            {
                case "interview-ru":
                    return "Интервью";
                case "podcast-ru":
                    return "Подкасты";
                case "review-ru":
                    return "Обзоры";
                case "interview-en":
                    return "Interviews";
                case "podcast-en":
                    return "Podcasts";
                case "review-en":
                    return "Reviews";
            }
            return type;
        }

        public string ToHtml(List<MediaItem> items)
        {
            var builder = new StringBuilder();
            var types = items.Select(t => t.Type).Distinct().OrderBy(x => x).ToList();
            foreach (var type in types)
            {
                var typeItems = items.Where(t => t.Type == type).OrderByDescending(t => t.Date).ToList();
                builder.AppendLine($"<h4>{GetTypeHeader(type, culture)}</h4>");
                builder.AppendLine("<ul>");
                foreach (var item in typeItems)
                    builder.AppendLine(ToHtml(item));
                builder.AppendLine("</ul>");
                builder.AppendLine();
            }

            return builder.ToString();
        }
    }

}