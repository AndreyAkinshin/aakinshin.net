using System.Diagnostics;
using System.Text;
using Common.Io;

namespace Common.Publications;

[DebuggerDisplay("{Key}")]
public class PublicationEntry
{
    public PublicationEntryType Type { get; }
    public string Key { get; set; }
    public PublicationLanguage OutputLanguage { get; }
    public Dictionary<string, string> Properties { get; }

    public PublicationEntry(PublicationEntryType type, string key, PublicationLanguage outputLanguage,
        Dictionary<string, string> properties)
    {
        Type = type;
        Key = key;
        OutputLanguage = outputLanguage;
        Properties = properties;
    }

    public string FormatBib()
    {
        var builder = new StringBuilder();
        builder.AppendLine($"@{Type}{{{Key},");
        var printedProperties = Properties.Where(property => property.Key != "file").ToList();
        for (var index = 0; index < printedProperties.Count; index++)
        {
            var property = printedProperties[index];
            var name = property.Key;
            var value = property.Value.Trim();
            if (name == "title")
                value = value
                    .TrimEnd('.')
                    .Replace("  ", " ");
            builder.Append($"  {name} = {{{value}}}");
            builder.AppendLine(index == printedProperties.Count - 1 ? "" : ",");
        }

        builder.AppendLine("}");
        return builder.ToString().TrimEnd();
    }

    public static PublicationEntry Read(string text) =>
        Read(PublicationLanguage.English, new StreamReader(new MemoryStream(Encoding.UTF8.GetBytes(text))));

    public static PublicationEntry Read(PublicationLanguage outputLanguage, StreamReader reader)
    {
        if (reader.Peek() == -1)
            return null;
        var firstLine = reader.ReadLine();
        if (string.IsNullOrWhiteSpace(firstLine))
            return null;
        var firstLineSplit = firstLine.Substring(1, firstLine.Length - 2).Split('{');
        var type = (PublicationEntryType)Enum.Parse(typeof(PublicationEntryType), firstLineSplit[0], true);
        var key = firstLineSplit[1];
        var properties = new Dictionary<string, string>();
        while (true)
        {
            var line = reader.ReadLine();
            if (string.IsNullOrWhiteSpace(line) || line == "}")
                return new PublicationEntry(type, key, outputLanguage, properties);
            var equalIndex = line.IndexOf("=", StringComparison.Ordinal);
            if (equalIndex == -1)
                continue;
            var propertyName = line.Substring(0, equalIndex).Trim().ToLowerInvariant();
            var propertyValue = line.Substring(equalIndex + 1)
                .Trim(' ', ',')
                .Replace("{", "")
                .Replace("}", "")
                .Replace("{\\_}", "_")
                .Replace("{\\%}", "%")
                .Replace("{\\&}", "&");
            properties[propertyName] = propertyValue;
        }
    }

    public static List<PublicationEntry> ReadAll(PublicationLanguage outputLanguage, string fileName)
    {
        var entries = new List<PublicationEntry>();
        if (!Path.IsPathRooted(fileName))
            fileName = Path.Combine(FileSystem.Raw, fileName);
        using (var reader = new StreamReader(fileName))
        {
            while (reader.Peek() != -1)
            {
                var entry = Read(outputLanguage, reader);
                if (entry != null)
                    entries.Add(entry);
            }
        }

        return entries;
    }

    public static List<PublicationEntry> ReadAll(PublicationLanguage outputLanguage, params string[] fileNames)
    {
        var entries = new List<PublicationEntry>();
        foreach (var fileName in fileNames)
            entries.AddRange(ReadAll(outputLanguage, fileName));
        return entries;
    }
}