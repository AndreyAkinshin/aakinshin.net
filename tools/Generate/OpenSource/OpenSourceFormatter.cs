using System.Text;

namespace Generate.OpenSource;

public class OpenSourceFormatter
{
    public static readonly OpenSourceFormatter Instance = new OpenSourceFormatter();

    public string ToToml(List<OpenSourceRepoGroup> groups)
    {
        var builder = new StringBuilder();
        builder.AppendLine("Indexer = false");
        builder.AppendLine();

        foreach (var repoGroup in groups)
        {
            var repos = repoGroup.Repos;
            if (repoGroup.Sort != null && repoGroup.Sort.Equals("url", StringComparison.OrdinalIgnoreCase))
                repos.Sort((x, y) => string.Compare(x.Url, y.Url, StringComparison.Ordinal));
            foreach (var repo in repos)
            {
                var href = "https://github.com/" + repo.Url;
                var caption = GetHtmlCaption(repo);
                var hrefCommit = href + "/commits?author=AndreyAkinshin";
                var html = $"<a href='{href}'>{caption}</a> " +
                           $"(<a href='{hrefCommit}'>commits</a>) " +
                           $"<i>{repo.Title}</i>";

                builder.AppendLine("[[item]]");
                builder.AppendLine($"Group = \"{repoGroup.Role}\"");
                builder.AppendLine($"Html = \"{html}\"");

                // builder.AppendLine("  [[item.link]]");
                // builder.AppendLine("  Label = \"GitHub\"");
                // builder.AppendLine($"  Url = \"{href}\"");
                //
                // builder.AppendLine("  [[item.link]]");
                // builder.AppendLine("  Label = \"Commits\"");
                // builder.AppendLine($"  Url = \"{hrefCommit}\"");

                builder.AppendLine();
            }
        }

        return builder.ToString();
    }

    private static string GetHtmlCaption(OpenSourceRepo openSourceRepo)
    {
        var parts = openSourceRepo.Url.Split(new[] { '/' }, StringSplitOptions.RemoveEmptyEntries);
        return parts[0] + "/<b>" + parts[1] + "</b>";
    }
}