using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;
using Common.Extensions;
using Common.Helpers;
using Common.Light;
using Common.Utils;

namespace Generate.Web;

public class WebEntry(LightContent content) : LightEntry(content)
{
    public override string Id { get; } = GenerateId(content.Yaml);

    private static string GenerateId(LightYaml yaml)
    {
        if (yaml.Has("id"))
            return yaml.GetScalar("id") ?? "_";

        if (!yaml.Has("weburl"))
        {
            Logger.Error($"No weburl found in the WebEntry ({yaml.Format().Replace("\n", "|")})");
            return "_";
        }

        return GenerateId(yaml.GetScalar("weburl") ?? "");
    }

    public static string GenerateId(string url)
    {
        url = url.TrimEnd('/');
        if (url.StartsWith("http://")) url = url.Substring(7);
        if (url.StartsWith("https://")) url = url.Substring(8);
        var hashBytes = SHA256.HashData(Encoding.UTF8.GetBytes(url));
        return BitConverter.ToString(hashBytes).Replace("-", "").ToLower().Substring(0, 32);
    }

    public static async Task<WebEntry> ImportAsync(string url)
    {
        var html = await WebHelper.DownloadStringAsync(url);

        var titleMatch = Regex.Match(html, @"<title>\s*(.+?)\s*</title>", RegexOptions.IgnoreCase);
        var title = titleMatch.Success ? titleMatch.Groups[1].Value : string.Empty;

        var descriptionMatch = Regex.Match(html, @"<meta\s+name=[""]description[""]\s+content=[""](.+?)[""]>",
            RegexOptions.IgnoreCase);
        var description = descriptionMatch.Success ? descriptionMatch.Groups[1].Value : string.Empty;

        var authorMatch = Regex.Match(html, @"<meta\s+name=[""]author[""]\s+content=[""](.+?)[""]>",
            RegexOptions.IgnoreCase);
        var author = authorMatch.Success ? authorMatch.Groups[1].Value : string.Empty;

        var values = new Dictionary<string, object>();
        values["weburl"] = url;
        if (title.IsNotBlank())
            values["title"] = title
                .Replace("&#39;", "'")
                .Replace("&#34;", "'");
        if (description.IsNotBlank())
            values["description"] = description;
        if (author.IsNotBlank())
            values["author"] = new[] { author };
        var yaml = new LightYaml(values);
        var id = GenerateId(url);
        var content = new LightContent(id, yaml, LightMd.CreateEmpty());
        return new WebEntry(content);
    }
}