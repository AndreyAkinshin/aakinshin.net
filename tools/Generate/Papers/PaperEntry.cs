using System.Diagnostics.CodeAnalysis;
using System.Text;
using Common.Extensions;
using Common.Light;
using Common.Publications;

namespace Generate.Papers;

public class PaperEntry : LightEntry
{
    public PublicationEntry? PublicationEntry { get; }

    public override string Id { get; }

    protected override void Patch()
    {
        if (PublicationEntry == null) return;

        PublicationEntry.Key = PublicationEntry.Key.ToLowerInvariant();
        var title = PublicationEntry.GetTitle();
        if (title.IsBlank())
            title = PublicationEntry.GetBookTitle();
        Content.Yaml.Set("title",
            title
                .Replace("\\&\\#039;", "'")
                .Replace("\\&", "&")
                .Replace("\\_", "_")
                .Replace("\\textgreater", ">")
                .Replace("\\textless", "<")
                .Replace("\\textit", "")
                .Replace("&lt;", "<"));
        var authors = PublicationEntry
            .GetAuthors()
            .Concat(PublicationEntry.GetEditors())
            .Select(author => author.ToText())
            .Where(author => author != "others")
            .OrderBy(s => s == PublicationEntryAuthor.Me ? 0 : 1)
            .ToArray();
        Content.Yaml.Set("authors", authors);
        Content.Yaml.Set("year", PublicationEntry.GetYear().ToString());
        Content.Yaml.Set("doi", PublicationEntry.GetDoi());
        Content.Yaml.Set("arxiv", PublicationEntry.GetArxiv());
        Content.Yaml.Set("urls", PublicationEntry
            .GetUrls()
            .Select(url => Unescape(url.Replace("\\_", "_")))
            .ToArray());
        if (authors.ContainsIgnoreCase(PublicationEntryAuthor.Me))
        {
            var tags = (Content.Yaml.GetArray("tags") ?? []).ToList();
            if (!tags.ContainsIgnoreCase("My own work"))
                tags.Add("My own work");
            Content.Yaml.Set("tags", tags.ToArray());
        }

        Content.Md.SetContent("Reference", $"> {PublicationEntry.ToHtml()}");
        var abs = PublicationEntry.GetAbstract();
        Content.Md.SetContent("Abstract", abs.IsNotBlank() ? $"> {abs}" : "");
        Content.Md.SetContent("Bib", new StringBuilder()
            .AppendLine("```bib")
            .AppendLine(PublicationEntry.FormatBib())
            .Append("```")
            .ToString());

        base.Patch();
    }

    private string Unescape(string s)
    {
        var builder = new StringBuilder(s.Length);
        for (int i = 0; i < s.Length; i++)
        {
            if (s[i] == '\\')
                i++;
            if (i < s.Length)
                builder.Append(s[i]);
        }

        return builder.ToString();
    }

    [SuppressMessage("ReSharper", "VirtualMemberCallInConstructor")]
    public PaperEntry(LightContent content) : base(content)
    {
        Id = "";
        var bib = content.Md.GetContent("Bib");
        if (bib == null) return;

        if (bib.StartsWith("```bib"))
            bib = bib[6..].Trim();
        if (bib.EndsWith("```"))
            bib = bib[..^3].Trim();
        var bibReader = new StreamReader(new MemoryStream(Encoding.UTF8.GetBytes(bib)));
        PublicationEntry = PublicationEntry.Read(PublicationLanguage.English, bibReader);

        Id = PublicationEntry.Key;
        Patch();
    }
}