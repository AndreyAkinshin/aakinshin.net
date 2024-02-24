using Common.Extensions;

namespace Common.Helpers;

public static class YamlHelper
{
    public static string ToLine(string key, string value) =>
        value.IsBlank() ? "" : $"{key}: \"{value.Replace("\"", "\\\"")}\"";
}