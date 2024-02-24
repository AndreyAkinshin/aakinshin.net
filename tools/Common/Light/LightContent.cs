using System.Text;
using Common.Extensions;
using Common.Io;

namespace Common.Light;

public class LightContent(string id, LightYaml yaml, LightMd md)
{
    public static LightContent CreateEmpty() => new("", LightYaml.CreateEmpty(), LightMd.CreateEmpty());

    public string Id { get; } = id;
    public LightYaml Yaml { get; } = yaml;
    public LightMd Md { get; } = md;

    public static LightContent Parse(FilePath filePath) =>
        Parse(filePath.NameWithoutExtension, filePath.ReadAllLines());

    public static LightContent Parse(string name, string[] lines)
    {
        var index = 0;
        var separatorCount = 0;
        while (index < lines.Length && separatorCount < 2)
        {
            if (lines[index++] == "---")
                separatorCount++;
        }

        if (index <= lines.Length)
        {
            var yaml = LightYaml.Parse(lines.Take(index).ToArray());
            var md = LightMd.Parse(lines.Skip(index).ToArray());
            return new LightContent(name, yaml, md);
        }

        return new LightContent(name, LightYaml.CreateEmpty(), LightMd.Parse(lines));
    }

    public string Format()
    {
        var builder = new StringBuilder();

        builder.AppendLine(Yaml.Format());
        var mdFormatted = Md.Format();
        if (mdFormatted.IsNotBlank())
        {
            builder.AppendLine();
            builder.AppendLine(mdFormatted);
        }

        return builder.ToString();
    }

    public void Apply(LightContent newContent)
    {
        Yaml.Apply(newContent.Yaml);
        Md.Apply(newContent.Md);
    }
}