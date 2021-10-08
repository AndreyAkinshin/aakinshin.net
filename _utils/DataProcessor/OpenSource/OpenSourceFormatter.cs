using System;
using System.Collections.Generic;
using System.Text;

namespace DataProcessor.OpenSource
{
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
                foreach (var repo in repoGroup.Repos)
                {
                    var href = "https://github.com/" + repo.Url;
                    var caption = GetHtmlCaption(repo);
                    var hrefCommit = href + "/commits?author=AndreyAkinshin";
                    var html = $"<a href='{href}'>{caption}</a> (<a href='{hrefCommit}'>commits</a>)<br /><i>{repo.Title}</i>";

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
            var parts = openSourceRepo.Url.Split(new[] {'/'}, StringSplitOptions.RemoveEmptyEntries);
            return parts[0] + "/<b>" + parts[1] + "</b>";
        }
    }
}