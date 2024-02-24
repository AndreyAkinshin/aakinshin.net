using System.Text;
using Common.Io;
using Common.Publications;
using Common.Utils;

namespace Common.Papers;

public class PaperFile(string filePath, PublicationEntry entry, string notes, string[] tags)
{
    public string FilePath { get; } = filePath;
    public PublicationEntry Entry { get; } = entry;
    public string Notes { get; } = notes;
    public string[] Tags { get; } = tags;

    public string ToContent()
    {
        var builder = new StringBuilder();
        builder.AppendLine(Entry.FormatYaml(Tags));
        builder.AppendLine();
        builder.AppendLine(Entry.ToHtml());
        builder.AppendLine();
        if (!string.IsNullOrWhiteSpace(Entry.GetAbstract()))
        {
            builder.AppendLine("## Abstract");
            builder.AppendLine("");
            builder.AppendLine(Entry.GetAbstract());
            builder.AppendLine("");
        }

        builder.AppendLine("## Bib");
        builder.AppendLine();
        builder.AppendLine("```bib");
        builder.AppendLine(Entry.FormatBib());
        builder.AppendLine("```");

        if (!string.IsNullOrWhiteSpace(Notes))
        {
            builder.AppendLine();
            builder.AppendLine("## Notes");
            builder.AppendLine();
            builder.AppendLine(Notes.Trim());
        }

        return builder.ToString();
    }

    public void Save()
    {
        var filePath = Path.Combine(FileSystem.Papers, Entry.GetNiceKey() + ".md");
        File.WriteAllText(filePath, ToContent());
    }

    public static PaperFile Read(string filePath)
    {
        var lines = File.ReadAllLines(filePath);
        PublicationEntry? entry = null;
        string notes = "";
        List<string> tags = [];
        for (int i = 0; i < lines.Length; i++)
        {
            if (lines[i] == "tags:")
            {
                i++;
                while (i < lines.Length && lines[i].StartsWith("-"))
                {
                    var tag = lines[i].Trim(' ', '-');
                    if (!string.IsNullOrWhiteSpace(tag))
                        tags.Add(tag);
                    i++;
                }

                continue;
            }

            if (lines[i] == "```bib")
            {
                i++;
                var bibBuilder = new StringBuilder();
                while (i < lines.Length && lines[i] != "```")
                {
                    bibBuilder.AppendLine(lines[i]);
                    i++;
                }

                var bibReader = new StreamReader(new MemoryStream(Encoding.UTF8.GetBytes(bibBuilder.ToString())));
                entry = PublicationEntry.Read(PublicationLanguage.English, bibReader);
                continue;
            }

            if (lines[i] == "## Notes")
            {
                i++;
                var notesBuilder = new StringBuilder();
                while (i < lines.Length)
                {
                    notesBuilder.AppendLine(lines[i]);
                    i++;
                }

                notes = notesBuilder.ToString().Trim();
                continue;
            }
        }

        if (entry == null)
            throw new Exception("Failed to read entry from file: " + filePath);

        return new PaperFile(filePath, entry, notes, tags.ToArray());
    }
}