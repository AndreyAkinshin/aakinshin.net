using System.Text;
using System.Text.RegularExpressions;
using Common.Io;

namespace Generate;

public class Relations(
    IReadOnlyDictionary<string, HashSet<string>> links,
    IReadOnlyDictionary<string, HashSet<string>> backlinks,
    IReadOnlyDictionary<string, HashSet<string>> quotes)
{
    public IReadOnlyDictionary<string, HashSet<string>> Links { get; } = links;
    public IReadOnlyDictionary<string, HashSet<string>> Backlinks { get; } = backlinks;
    public IReadOnlyDictionary<string, HashSet<string>> Quotes { get; } = quotes;

    public static Relations Create()
    {
        var links = new Dictionary<string, HashSet<string>>();
        var backlinks = new Dictionary<string, HashSet<string>>();
        var quotes = new Dictionary<string, HashSet<string>>();

        void AddLink(string source, string target)
        {
            if (!links.ContainsKey(source))
                links[source] = new HashSet<string>();
            links[source].Add(target);

            if (!backlinks.ContainsKey(target))
                backlinks[target] = new HashSet<string>();
            backlinks[target].Add(source);
        }

        var regex = new Regex("{{< (ref|link) (\\S+) >}}");
        foreach (var filePath in FileSystem.Content.EnumerateFilesRecursively("*.md"))
        {
            if (filePath.Name.StartsWith('_')) continue;
            if (filePath.FullPath.Contains("drafts")) continue;

            var key = filePath.NameWithoutExtension == "index"
                ? filePath.Parent?.Name ?? ""
                : filePath.NameWithoutExtension;

            var content = filePath.ReadAllText();

            foreach (Match match in regex.Matches(content))
                AddLink(key, match.Groups[2].Value.Trim('\"'));

            if (filePath.Parent?.Name == "quotes")
            {
                var sourceLine = content.Split('\n').FirstOrDefault(line => line.StartsWith("source:"));
                if (sourceLine != null)
                {
                    var source = sourceLine.Substring(7).Trim();
                    if (!quotes.ContainsKey(source))
                        quotes[source] = new HashSet<string>();
                    quotes[source].Add(filePath.NameWithoutExtension);
                }
            }
        }

        return new Relations(links, backlinks, quotes);
    }

    public void Dump()
    {
        var keys = Links.Keys.Concat(Backlinks.Keys).Concat(Quotes.Keys).Distinct().OrderBy(x => x).ToList();
        var builder = new StringBuilder();
        foreach (var key in keys)
        {
            builder.AppendLine(key + ":");
            if (Links.ContainsKey(key))
            {
                builder.AppendLine("  links:");
                foreach (var link in Links[key].OrderBy(x => x))
                    builder.AppendLine("    - " + link);
            }

            if (Backlinks.ContainsKey(key))
            {
                builder.AppendLine("  backlinks:");

                foreach (var backlink in Backlinks[key].OrderBy(x => x))
                    builder.AppendLine("    - " + backlink);
            }

            if (Quotes.ContainsKey(key))
            {
                builder.AppendLine("  quotes:");
                foreach (var quote in Quotes[key].OrderBy(x => x))
                    builder.AppendLine("    - " + quote);
            }
        }

        var filePath = FileSystem.DataGen.File("relations.yaml");
        filePath.WriteAllText(builder.ToString());
    }
}