using System.Text.RegularExpressions;

namespace Common.Utils;

public static class Util
{
    public static string Escape(string content)
    {
        return Regex.Replace(
            content
                .Replace("\r", "")
                .Replace("\n", " ")
                .Replace("\\", "&#92;")
                .Replace("\"", "'"),
            @"\s+", " ").Trim();
    }
}