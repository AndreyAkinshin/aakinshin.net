using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text;
using DataProcessor.Common;

namespace DataProcessor.Talks
{
    public class TalkFormatter
    {
        private readonly string openingQuotationMark, closingQuotationMark, dateFormat, culture;

        public static readonly TalkFormatter Ru = new TalkFormatter("«", "»", "dd MMMM yyyy", "ru-RU");
        public static readonly TalkFormatter En = new TalkFormatter("“", "”", "MMMM dd, yyyy", "en-US");

        private TalkFormatter(string openingQuotationMark, string closingQuotationMark, string dateFormat, string culture)
        {
            this.openingQuotationMark = openingQuotationMark;
            this.closingQuotationMark = closingQuotationMark;
            this.dateFormat = dateFormat;
            this.culture = culture;
        }

        private string Quote(string s) => openingQuotationMark + s + closingQuotationMark;

        private string QuoteWithLink(Talk conf, string text, string linkKey)
        {
//            var link = conf.GetLink(linkKey);
//            if (link != null)
//                return $"<a href=\"{link.Url}\">{Quote(text)}</a>";
            return Quote(text);
        }

        private string ToHtmlMain(Talk talk)
        {
            var builder = new StringBuilder();

            if (talk.Title != "")
            {
                builder.Append("  ");
                builder.Append(QuoteWithLink(talk, talk.Title, "talk"));

                builder.AppendLine(",<br />");
            }

            if (talk.Event != "")
            {
                builder.Append("  ");
                if (talk.EventHint != "")
                    builder.Append(talk.EventHint + " ");
                builder.Append(QuoteWithLink(talk, talk.Event, "event"));
                builder.AppendLine(",<br />");
            }

            var details = new List<string>();
            if (talk.Date != null)
            {
                var dateStr = talk.Date.Value.ToString(dateFormat, new CultureInfo(culture));
                if (talk.Date2 != null)
                    dateStr += " – " + talk.Date2.Value.ToString(dateFormat, new CultureInfo(culture));
                details.Add(dateStr);
            }
            else
                details.Add(talk.Year.ToString());

            if (talk.Location != null)
                details.Add(talk.Location.Replace("г. ", "г.&nbsp;"));
            if (details.Any())
                builder.AppendLine("  <i>" + string.Join(", ", details) + "</i>");

            return builder.ToString();
        }

        public string ToHtml(Talk talk, int number = -1)
        {
            var builder = new StringBuilder();

            if (number > 0)
                builder.AppendLine($"<li value=\"{number}\">");
            else
                builder.AppendLine("<li>");

            builder.Append(ToHtmlMain(talk));

            if (talk.Links.Any())
            {
                builder.AppendLine("<br />");
                foreach (var link in talk.Links)
                    builder.AppendLine("    " + link.ToHtml());
            }

            builder.AppendLine("</li>");

            return builder.ToString();
        }

        public string ToHtml(List<Talk> talks)
        {
            var builder = new StringBuilder();
            var years = talks.Select(t => t.Year).Distinct().OrderByDescending(x => x).ToList();
            int counter = talks.Count;
            foreach (var year in years)
            {
                var yearTalks = talks.Where(t => t.Year == year).OrderByDescending(t => t.Date).ToList();
                builder.AppendLine($"<h4>{year} ({yearTalks.Count} in Total)</h4>");
                builder.AppendLine("<ol>");
                foreach (var talk in yearTalks)
                    builder.AppendLine(ToHtml(talk, counter--));
                builder.AppendLine("</ol>");
                builder.AppendLine();
            }

            return builder.ToString();
        }

        public string ToToml(List<Talk> talks)
        {
            var builder = new StringBuilder();
            builder.AppendLine("Indexer = true");
            builder.AppendLine();

            var orderedTalks = talks
                .OrderByDescending(t => t.Year)
                .ThenByDescending(t => t.Date)
                .ThenBy(t => t.Title)
                .ThenBy(t => t.Event)
                .ToList();
            var counter = orderedTalks.Count;
            foreach (var talk in orderedTalks)
            {
                builder.AppendLine("[[item]]");
                builder.AppendLine($"Group = \"{talk.Year}\"");
                builder.AppendLine($"Html = \"{Util.Escape(ToHtmlMain(talk))}\"");
                builder.AppendLine($"Index = {counter--}");

                if (!string.IsNullOrEmpty(talk.Lang))
                {
                    builder.AppendLine("  [[item.badge]]");
                    builder.AppendLine($"  Label = \"{talk.Lang.ToUpper()}\"");
                }

                foreach (var link in talk.Links)
                {
                    builder.AppendLine("  [[item.link]]");
                    builder.AppendLine($"  Label = \"{link.GetLabel()}\"");
                    builder.AppendLine($"  Url = \"{link.Url}\"");
                }
                
                builder.AppendLine();
            }
            
            return builder.ToString();
        }
    }
}