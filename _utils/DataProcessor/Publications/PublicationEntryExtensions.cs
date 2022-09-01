using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using DataProcessor.Common;

namespace DataProcessor.Publications
{
    internal static class PublicationEntryExtensions
    {
        public static string GetProperty(this PublicationEntry entry, string name) =>
            entry.Properties.ContainsKey(name.ToLowerInvariant()) ? entry.Properties[name.ToLowerInvariant()] : "";

        public static int GetYear(this PublicationEntry entry) => int.Parse(entry.GetProperty("year"));
        public static string GetTitle(this PublicationEntry entry) => entry.GetProperty("title");
        public static string GetPublisher(this PublicationEntry entry) => entry.GetProperty("publisher");
        public static string GetAddress(this PublicationEntry entry) => entry.GetProperty("address");
        public static string GetJournal(this PublicationEntry entry) => entry.GetProperty("journal");
        public static string GetOrganization(this PublicationEntry entry) => entry.GetProperty("organization");
        public static string GetPages(this PublicationEntry entry) => entry.GetProperty("pages").Replace("--", "–");
        public static string GetVolume(this PublicationEntry entry) => entry.GetProperty("volume");
        public static string GetNumber(this PublicationEntry entry) => entry.GetProperty("number");
        public static string GetAbstract(this PublicationEntry entry) => entry.GetProperty("abstract");
        public static string GetBookTitle(this PublicationEntry entry) => entry.GetProperty("booktitle");
        public static string GetIsbn(this PublicationEntry entry) => entry.GetProperty("isbn");
        public static string GetDoi(this PublicationEntry entry) => entry.GetProperty("doi");
        public static string GetArchivePrefix(this PublicationEntry entry) => entry.GetProperty("archivePrefix");
        public static string GetEPrint(this PublicationEntry entry) => entry.GetProperty("eprint");

        public static PublicationLanguage GetLanguage(this PublicationEntry entry) =>
            entry.GetProperty("language").StartsWith("ru") ? PublicationLanguage.Russian : PublicationLanguage.English;

        public static string[] GetUrls(this PublicationEntry entry)
        {
            var urls = new List<string>();
            foreach (var (key, value) in entry.Properties)
                if (key.ToLowerInvariant().StartsWith("url") || key.ToLowerInvariant().StartsWith("custom-url"))
                    urls.AddRange(value.Split(new[] { ' ' }, StringSplitOptions.RemoveEmptyEntries));

            return urls.ToArray();
        }

        public static string[] GetTags(this PublicationEntry entry) => entry.GetProperty("custom-tags")
            .Split(new[] {','}, StringSplitOptions.RemoveEmptyEntries);

        public static PublicationEntryAuthor[] GetAuthors(this PublicationEntry entry) =>
            PublicationEntryAuthor.Parse(entry.GetProperty("author"));

        public static IList<PublicationEntry> WithYear(this IEnumerable<PublicationEntry> entries, int year) =>
            entries.Where(it => GetYear(it) == year).ToList();

        public static IList<PublicationEntry> WithType(this IEnumerable<PublicationEntry> entries,
            PublicationEntryType type) =>
            entries.Where(it => it.Type == type).ToList();

        public static string ToHtml(this IEnumerable<PublicationEntryAuthor> authors) =>
            "<i>" + string.Join(", ", authors.Select(it => $"{it.FirstName} {it.LastName}")) + "</i>";

        public static string ToHtml(this PublicationEntry entry)
        {
            var lang = entry.OutputLanguage;
            var builder = new StringBuilder();
            builder.Append(entry.GetAuthors().ToHtml());
            builder.Append(' ');
            builder.Append($"<span title=\"{entry.GetAbstract()}\">");
            builder.Append(Resolve(lang, "“", "«"));
            builder.Append(entry.GetTitle());
            builder.Append(Resolve(lang, "”", "»"));
            builder.Append("</span>");
            if (entry.GetYear() != 0)
                builder.Append(" (" + entry.GetYear() + ")");
            builder.Append(" //");
            if (entry.GetBookTitle() != "")
                builder.Append(" " + entry.GetBookTitle() + ".");
            if (entry.GetJournal() != "")
                builder.Append(" " + entry.GetJournal() + ".");
            if (entry.GetPublisher() != "")
                builder.Append($" {Resolve(lang, "Publisher", "Издательство")}: " + entry.GetPublisher() + ".");
            if (entry.GetAddress() != "")
                builder.Append(" " + entry.GetAddress() + ".");
            if (entry.GetOrganization() != "")
                builder.Append(" " + entry.GetOrganization() + ".");
            if (entry.GetIsbn() != "")
                builder.Append(" ISBN:&nbsp;" + entry.GetIsbn() + ".");
            if (entry.GetVolume() != "")
                builder.Append($" {Resolve(lang, "Vol", "Т")}.&nbsp;" + entry.GetVolume() + ".");
            if (entry.GetNumber() != "")
                builder.Append($" {Resolve(lang, "No", "№")}&nbsp;" + entry.GetNumber() + ".");
            if (entry.GetPages() != "")
                builder.Append($" {Resolve(lang, "Pp", "Стр")}.&nbsp;" + entry.GetPages() + ".");
            if (entry.GetDoi() != "")
                builder.Append($" DOI:&nbsp;<a href='https://doi.org/{entry.GetDoi()}'>{entry.GetDoi()}</a>");
            if (entry.GetArchivePrefix().ToLowerInvariant() == "arxiv" && entry.GetEPrint() != "")
                builder.Append($" <a href='https://arxiv.org/abs/{entry.GetEPrint()}'>arXiv:{entry.GetEPrint()}</a>");
            
            if (builder.ToString().EndsWith("//"))
                builder.Remove(builder.Length - 2, 2);

            var urls = entry.GetUrls();
            bool isVak = entry.GetTags().Contains("Vak");
            if (urls.Any() || isVak)
            {
                // builder.Append(" //");
                // foreach (var url in urls)
                // {
                //     var title = Resolve(lang, "Link", "Ссылка");
                //     if (url.EndsWith(".pdf"))
                //         title = "Pdf";
                //     else if (url.Contains("ieeexplore.ieee.org"))
                //         title = "IEEE";
                //     else if (url.Contains("apps.webofknowledge.com"))
                //         title = "Web of Science";
                //     else if (url.Contains("www.scopus.com"))
                //         title = "Scopus";
                //     else if (url.Contains("elibrary.ru"))
                //         title = Resolve(lang, "RSCI", "РИНЦ");
                //     else if (url.Contains("mathnet.ru"))
                //         title = "MathNet";
                //     else if (url.Contains("link.springer.com"))
                //         title = "Springer";
                //     else if (url.Contains("www.packtpub.com"))
                //         title = "PacktPub";
                //     else if (url.Contains("conf.nsc.ru") || url.Contains("uni-bielefeld.de") ||
                //              url.Contains("cmb.molgen.mpg.de") || url.Contains("sites.google.com"))
                //         title = Resolve(lang, "Conference site", "Сайт конференции");
                //     else if (url.Contains("authorea"))
                //         title = url.Substring(url.IndexOf("authorea.com", StringComparison.Ordinal)).TrimEnd('/');
                //     else if (url.Contains("scholar.google.ru"))
                //         title = "Google Scholar";
                //     builder.AppendLine($" <a href=\"{url}\">[{title}]</a>");
                // }

                // if (isVak)
                // builder.AppendLine(Resolve(lang, " [VAK]", " [ВАК]"));
            }

            return builder.ToString();
        }

        public static string ToHtml(this IList<PublicationEntry> entries,
            PublicationLanguage lang = PublicationLanguage.English)
        {
            var builder = new StringBuilder();
            var years = entries.Select(it => it.GetYear()).Distinct().OrderByDescending(it => it);
            foreach (var year in years)
            {
                builder.AppendLine($"<h4>{year}</h4>");
                var localEntries = entries.WithYear(year);
                builder.Append(localEntries.WithType(PublicationEntryType.PhdThesis)
                    .ToHtmlSection(Resolve(lang, "Phd thesis", "Диссертационные работы")));
                builder.Append(localEntries.WithType(PublicationEntryType.Book)
                    .ToHtmlSection(Resolve(lang, "Books", "Книги")));
                builder.Append(localEntries.WithType(PublicationEntryType.Article)
                    .ToHtmlSection(Resolve(lang, "Articles", "Статьи")));
                builder.Append(localEntries.WithType(PublicationEntryType.Inproceedings)
                    .ToHtmlSection(Resolve(lang, "Inproceedings", "Тезисы")));
                builder.Append(localEntries.WithType(PublicationEntryType.TechReport)
                    .ToHtmlSection(Resolve(lang, "Technical reports", "Технические отчёты")));
            }

            return builder.ToString();
        }

        public static string ToLabel(this PublicationEntryType type, string culture)
        {
            if (culture.StartsWith("en"))
            {
                switch (type)
                {
                    case PublicationEntryType.Inproceedings:
                        return "Inproceedings";
                    case PublicationEntryType.TechReport:
                        return "Technical Report";
                    case PublicationEntryType.Book:
                        return "Book";
                    case PublicationEntryType.Article:
                        return "Article";
                    case PublicationEntryType.PhdThesis:
                        return "PhD Thesis";
                    default:
                        throw new ArgumentOutOfRangeException(nameof(type), type, null);
                }
            }

            if (culture.StartsWith("ru"))
            {
                switch (type)
                {
                    case PublicationEntryType.Inproceedings:
                        return "Тезисы";
                    case PublicationEntryType.TechReport:
                        return "Технический отчёт";
                    case PublicationEntryType.Book:
                        return "Книга";
                    case PublicationEntryType.Article:
                        return "Статья";
                    case PublicationEntryType.PhdThesis:
                        return "Диссертационная работа";
                    default:
                        throw new ArgumentOutOfRangeException(nameof(type), type, null);
                }
            }

            throw new Exception($"Unknown culture: {culture}");
        }

        public static string ToToml(this IList<PublicationEntry> entries,
            PublicationLanguage lang = PublicationLanguage.English)
        {
            string culture = lang == PublicationLanguage.English ? "en-us" : "ru-ru";
            var builder = new StringBuilder();
            builder.AppendLine("Indexer = true");
            builder.AppendLine();
            var years = entries.Select(it => it.GetYear()).Distinct().OrderByDescending(it => it);
            int counter = entries.Count;
            foreach (var year in years)
            {
                foreach (var entry in entries.Where(e => e.GetYear() == year))
                {
                    builder.AppendLine("[[item]]");
                    builder.AppendLine($"Group = \"{year}\"");
                    builder.AppendLine($"Html = \"{Util.Escape(entry.ToHtml())}\"");
                    builder.AppendLine($"Index = {counter--}");

                    builder.AppendLine("  [[item.badge]]");
                    builder.AppendLine($"  Label = \"{entry.GetLanguage().ToString().Substring(0, 2).ToUpper()}\"");

                    builder.AppendLine("  [[item.badge]]");
                    builder.AppendLine($"  Label = \"{entry.Type.ToLabel(culture)}\"");

                    bool isWoS = entry.GetTags().Contains("WoS");
                    if (isWoS)
                    {
                        builder.AppendLine("  [[item.badge]]");
                        builder.AppendLine($"  Label = \"Web of Science\"");
                    }
                    
                    bool isSpringer = entry.GetTags().Contains("Springer");
                    if (isSpringer)
                    {
                        builder.AppendLine("  [[item.badge]]");
                        builder.AppendLine($"  Label = \"Springer\"");
                    }
                    
                    bool isScopus = entry.GetTags().Contains("Scopus");
                    if (isScopus)
                    {
                        builder.AppendLine("  [[item.badge]]");
                        builder.AppendLine($"  Label = \"Scopus\"");
                    }

                    bool isPreprint = entry.GetTags().Contains("Preprint");
                    if (isPreprint)
                    {
                        builder.AppendLine("  [[item.badge]]");
                        var label = lang == PublicationLanguage.Russian ? "Препринт" : "Preprint";
                        builder.AppendLine($"  Label = \"{label}\"");
                    }

                    bool isVak = entry.GetTags().Contains("Vak");
                    if (isVak || isWoS || isSpringer || isScopus)
                    {
                        builder.AppendLine("  [[item.badge]]");
                        var label = lang == PublicationLanguage.Russian ? "ВАК" : "VAK";
                        builder.AppendLine($"  Label = \"{label}\"");
                    }

                    var doi = entry.GetDoi();
                    if (!string.IsNullOrEmpty(doi))
                    {
                        builder.AppendLine("  [[item.link]]");
                        builder.AppendLine($"  Label = \"DOI\"");
                        builder.AppendLine($"  Url = \"http://dx.doi.org/{doi}\"");
                    }

                    foreach (var url in entry.GetUrls())
                    {
                        var title = Resolve(lang, "Link", "Ссылка");
                        if (url.EndsWith(".pdf"))
                            title = "<i class='fas fa-file-pdf'></i> PDF";
                        else if (url.Contains("ieeexplore.ieee.org"))
                            title = "IEEE";
                        else if (url.Contains("apps.webofknowledge.com"))
                            title = "Web of Science";
                        else if (url.Contains("www.scopus.com"))
                            title = "Scopus";
                        else if (url.Contains("elibrary.ru"))
                            title = Resolve(lang, "RSCI", "РИНЦ");
                        else if (url.Contains("mathnet.ru"))
                            title = "MathNet";
                        else if (url.Contains("www.packtpub.com"))
                            title = "PacktPub";
                        else if (url.Contains("apress"))
                            title = "Apress";
                        else if (url.Contains("springer"))
                            title = "Springer";
                        else if (url.Contains("arxiv"))
                            title = "<i class='fas fa-file-pdf'></i> arXiv (PDF)";
                        else if (url.Contains("publons"))
                            title = "Publons";
                        else if (url.Contains("github"))
                            title = "<i class='fab fa-github' title='GitHub'></i> GitHub";
                        else if (url.Contains("conf.nsc.ru") || url.Contains("uni-bielefeld.de") ||
                                 url.Contains("cmb.molgen.mpg.de") || url.Contains("sites.google.com"))
                            title = Resolve(lang, "Conference site", "Сайт конференции");
                        else if (url.Contains("authorea"))
                            title = url.Substring(url.IndexOf("authorea.com", StringComparison.Ordinal))
                                .TrimEnd('/');
                        else if (url.Contains("scholar.google."))
                            title = "Google Scholar";
                        builder.AppendLine("  [[item.link]]");
                        builder.AppendLine($"  Label = \"{title}\"");
                        builder.AppendLine($"  Url = \"{url}\"");
                    }
                }
            }

            return builder.ToString();
        }

        private static string ToHtmlSection(this IList<PublicationEntry> entries, string title)
        {
            if (!entries.Any())
                return "";
            var builder = new StringBuilder();
            builder.AppendLine($"  <h5>{title}</h5>");
            builder.AppendLine($"  <ul>");
            foreach (var entry in entries)
                builder.AppendLine($"  <li>{entry.ToHtml()}</li>");
            builder.AppendLine($"  </ul>");
            return builder.ToString();
        }

        private static string Resolve(PublicationLanguage lang, string en, string ru) =>
            lang == PublicationLanguage.English ? en : ru;
    }
}