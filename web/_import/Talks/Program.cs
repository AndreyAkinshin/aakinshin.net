using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using Utils;
using YamlDotNet.RepresentationModel;

namespace MyTalks
{
    public class Link
    {
        private static readonly Dictionary<string, string> faDictionary = new Dictionary<string, string>()
        {
            {"youtube", "fab fa-youtube"},
            {"pdf", "fas fa-file-pdf"},
            {"slideshare", "fab fa-slideshare"},
            {"photos", "fas fa-camera-retro"},
            {"org", "fas fa-building"}
        };

        public string Key { get; set; }
        public string Url { get; set; }
        public string Caption { get; set; }

        public string ToHtml()
        {
            var fa = faDictionary.ContainsKey(Key) ? faDictionary[Key] : "fas fa-question";
            return $"<a href=\"{Url}\"><i class=\"{fa} fa-profile-link\" title=\"{Key}\"></i></a>";
        }
    }

    public class Talk
    {
        public DateTime? Date { get; set; }
        public DateTime? Date2 { get; set; }
        public string Event { get; set; }
        public string EventHint { get; set; }
        public string Title { get; set; }
        public string Location { get; set; }
        public string Lang { get; set; }
        public int Year { get; set; }
        public List<Link> Links { get; set; }
        public Link GetLink(string key) => Links.FirstOrDefault(l => l.Key == key);
    }

    public class Parser : YamlParser
    {
        public static readonly Parser En = new Parser("en");
        public static readonly Parser Ru = new Parser("ru");

        private Parser(string lang) : base(lang)
        {
        }

        private Link ParseLink(YamlMappingNode yaml)
        {
            var link = new Link
            {
                Key = GetStr(yaml, "key"),
                Url = GetStr(yaml, "url"),
                Caption = GetStr(yaml, "caption")
            };
            if (link.Key.Contains("_"))
            {
                if (link.Key.EndsWith("_" + Lang))
                    link.Key = link.Key.Replace("_" + Lang, "");
                else
                    link = null;
            }

            return link;
        }

        private List<Link> GetLinks(YamlMappingNode yaml, string name)
        {
            var yamlList = Get(yaml, name) as YamlSequenceNode;
            if (yamlList == null)
                return new List<Link>();
            return yamlList.Children
                .Select(link => ParseLink((YamlMappingNode) link))
                .Where(link => link != null)
                .ToList();
        }

        public List<Talk> Parse(List<YamlMappingNode> yamlNodes)
        {
            return yamlNodes.Select(conf => Parse(conf)).ToList();
        }

        public Talk Parse(YamlMappingNode yaml) => new Talk
        {
            Date = GetDate(yaml, "date"),
            Date2 = GetDate(yaml, "date2"),
            Event = GetStr(yaml, "event"),
            EventHint = GetStr(yaml, "event-hint"),
            Title = GetStr(yaml, "title"),
            Location = GetStr(yaml, "location"),
            Lang = GetStr(yaml, "lang"),
            Year = GetDate(yaml, "date")?.Year ?? GetInt(yaml, "year"),
            Links = GetLinks(yaml, "links")
        };
    }

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

        private string QuoteWithLink(Talk conf, string text, string linkKey)
        {
            var link = conf.GetLink(linkKey);
            if (link != null)
                return $"<a href=\"{link.Url}\">{Quote(text)}</a>";
            return Quote(text);
        }

        public string ToHtml(Talk talk, int number = -1)
        {
            var builder = new StringBuilder();

            if (number > 0)
                builder.AppendLine($"<li value=\"{number}\">");
            else
                builder.AppendLine("<li>");

            if (talk.Event != "")
            {
                builder.Append("  ");
                if (talk.EventHint != "")
                    builder.Append(talk.EventHint + " ");
                builder.Append(QuoteWithLink(talk, talk.Event, "event"));
                builder.AppendLine(",<br />");
            }

            if (talk.Title != "")
            {
                builder.Append("  ");
                builder.AppendLine(QuoteWithLink(talk, talk.Title, "talk"));
                if (talk.Lang != "")
                    builder.AppendLine("    (" + talk.Lang.ToUpperInvariant() + ")");
                foreach (var link in talk.Links)
                {
                    if (link.Key != "event" && link.Key != "talk")
                        builder.AppendLine("    " + link.ToHtml());
                }

                builder.AppendLine("  ,<br />");
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
    }

    class Program
    {
        static void Main()
        {
            var yaml = new YamlStream();
            yaml.Load(new StreamReader("talks.yaml"));
            var yamlRoot = (YamlMappingNode) yaml.Documents[0].RootNode;
            List<YamlMappingNode> talkYamlList = ((YamlSequenceNode) yamlRoot.Children.Values.First())
                .Children.Cast<YamlMappingNode>().ToList();

            var talkListEn = Parser.En.Parse(talkYamlList);
            var talkListRu = Parser.Ru.Parse(talkYamlList);

            var htmlEn = Formatter.En.ToHtml(talkListEn);
            var htmlRu = Formatter.Ru.ToHtml(talkListRu);

            if (!Directory.Exists("_generated"))
                Directory.CreateDirectory("_generated");

            File.WriteAllText(Path.Combine("_generated", "talks.html"), htmlEn);
            File.WriteAllText(Path.Combine("_generated", "talks-ru.html"), htmlRu);
            File.WriteAllText(Path.Combine("_generated", "talks-count.txt"), talkListEn.Count.ToString());
            File.WriteAllText(Path.Combine("_generated", "talks-ru-count.txt"), talkListRu.Count.ToString());

            // Console.WriteLine(htmlEn);
            // Console.WriteLine("-------------");
            // Console.WriteLine(htmlRu);
        }
    }
}