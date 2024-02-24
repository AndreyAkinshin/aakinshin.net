using System.Text;
using Common.Extensions;

namespace Common.Light;

public class LightYaml(Dictionary<string, object> values, int length = -1)
{
    private readonly Dictionary<string, object> values = new(values, StringComparer.OrdinalIgnoreCase);
    public static LightYaml CreateEmpty() => new([], 0);
    public bool Has(string key) => values.ContainsKey(key);
    public string? GetScalar(string key) => values.TryGetValue(key, out var value) ? value as string : null;
    public string? GetScalarEn(string key) => GetScalar(key) ?? GetScalar("_en");
    public string[]? GetArray(string key) => values.TryGetValue(key, out var value) ? value as string[] : null;

    public void Set(string key, string value)
    {
        if (key.IsNotBlank() && value.IsNotBlank())
            values[key] = value;
    }

    public void Set(string key, string[] items)
    {
        if (key.IsNotBlank() && values.Any())
            values[key] = items;
    }

    public static LightYaml Parse(string[] lines)
    {
        Dictionary<string, object> values = new();

        var i = 0;
        while (i < lines.Length && lines[i] != "---")
            i++;

        i++; // Skip the "---" line

        while (i < lines.Length && lines[i] != "---")
        {
            var line = lines[i++].Trim();
            if (line.EndsWith(':'))
            {
                var key = line[..^1].Trim();
                var items = new List<string>();
                while (i < lines.Length && lines[i].StartsWith("- "))
                    items.Add(ParseValue(lines[i++][2..].Trim()));
                values[key] = items.ToArray();
            }
            else
            {
                var index = line.IndexOf(':');
                if (index == -1) continue;

                var name = line[..index].Trim();
                var value = ParseValue(line[(index + 1)..].Trim());
                values[name] = value;
            }
        }

        var length = lines.Sum(line => line.Length) + (lines.Length - 1) * 2;
        return new LightYaml(values, length);
    }

    private static string ParseValue(string value)
    {
        if (value.StartsWith('\"') && value.EndsWith('\"'))
            value = value.Substring(1, value.Length - 2).Trim();
        value = value.Replace("\\\"", "\"");
        return value;
    }

    public string Format()
    {
        var builder = new StringBuilder(length + 42);
        builder.AppendLine("---");
        AppendBody(builder);
        builder.Append("---");
        return builder.ToString();
    }

    private void AppendBody(StringBuilder builder)
    {
        var keys = values.Keys.ToList();
        keys.Sort((a, b) => GetKeyOrder(a).CompareTo(GetKeyOrder(b)));
        foreach (var key in keys)
        {
            switch (values[key])
            {
                case string valueString:
                {
                    if (valueString.IsNotBlank())
                    {
                        builder.Append(key);
                        builder.Append(": ");
                        AppendValue(builder, valueString);
                        builder.AppendLine();
                    }

                    break;
                }
                case string[] valueArray:
                {
                    if (valueArray.Any())
                    {
                        builder.Append(key);
                        builder.AppendLine(":");
                        foreach (var item in valueArray)
                        {
                            builder.Append("- ");
                            AppendValue(builder, item);
                            builder.AppendLine();
                        }
                    }

                    break;
                }
            }
        }
    }

    private static void AppendValue(StringBuilder builder, string value)
    {
        var escapedValue = value.Replace("\\", "\\\\").Replace("\"", "\\\"");
        if (value.Contains('\"') || value.Contains(':') || value.Contains('\'') || value.Contains('#'))
        {
            builder.Append('\"');
            builder.Append(escapedValue);
            builder.Append('\"');
        }
        else
        {
            builder.Append(escapedValue);
        }
    }

    private static readonly IReadOnlyDictionary<string, int> KeyOrders = new Dictionary<string, int>
    {
        // Meta
        { "id", 0 },
        { "title", 1 },
        { "description", 2 },
        { "year", 3 },
        { "date", 4 },

        // Id
        { "weburl", 10 },
        { "doi", 11 },
        { "arxiv", 12 },
        { "goodreads", 10 },

        // Urls
        { "urls", 20 },
        { "urlCover", 21},

        // Custom 1
        { "authors", 30 },
        { "tags", 31 },

        // Custom 2
        { "rating", 40 },

        // Generated
        { "hasNotes", 101 },
    };

    private static int GetKeyOrder(string name) => KeyOrders.GetValueOrDefault(name, 50);

    public void Apply(LightYaml newYaml)
    {
        foreach (var (key, value) in newYaml.values)
            values[key] = value;
    }
}