using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using DataProcessor.Common;

namespace DataProcessor.Publications
{
    public class PublicationEntry
    {
        public PublicationEntryType Type { get; }
        public string Key { get; }
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
            builder.AppendLine($"@{Type}{{{this.GetNiceKey()},");
            foreach (var property in Properties)
                if (property.Key != "file")
                    builder.AppendLine($"  {property.Key} = {{{property.Value.Trim()}}},");
            builder.AppendLine("}");
            return builder.ToString().TrimEnd();
        }

        public string FormatYaml(string[] tags)
        {
            var title = this.GetTitle()
                .Replace("\\&\\#039;", "'")
                .Replace("\\&", "&")
                .Replace("\\textgreater", ">")
                .Replace("\\textless", "<")
                .Replace("\\", "\\\\")
                .Replace("\"", "\\\"");

            var builder = new StringBuilder();
            builder.AppendLine("---");
            builder.AppendLine("title: \"" + title + "\"");
            builder.AppendLine("authors:");
            foreach (var author in this.GetAuthors().Concat(this.GetEditors()))
            {
                var authorText = author.ToText();
                if (authorText == "others")
                    continue;
                builder.AppendLine("- " + authorText);
            }

            builder.AppendLine("year: " + this.GetYear());
            if (!string.IsNullOrEmpty(this.GetDoi()))
                builder.AppendLine("doi: " + this.GetDoi());
            if (this.GetUrls().Any())
            {
                builder.AppendLine("urls:");
                foreach (var url in this.GetUrls())
                    builder.AppendLine("- \"" + url.Replace("\"", "\\\"") + "\"");
            }

            if (tags.Any())
            {
                builder.AppendLine("tags:");
                foreach (var tag in tags)
                    builder.AppendLine($"- {tag}");
            }

            builder.AppendLine("---");
            return builder.ToString().TrimEnd();
        }

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
                fileName = Path.Combine(DirectoryDetector.GetDataRawDirectory(), fileName);
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
}