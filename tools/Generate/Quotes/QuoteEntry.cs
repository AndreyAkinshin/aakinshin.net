using Common.Light;

namespace Generate.Quotes;

public class QuoteEntry(LightContent content) : LightEntry(content)
{
    protected override void Patch()
    {
        base.Patch();
        var hasNotes = false;
        foreach (var name in Content.Md.GetAllSectionNames())
        {
            var content = (Content.Md.GetContent(name) ?? "").Split('\n').Select(line => line.Trim());
            if (content.Any(line => !line.StartsWith(">")))
                hasNotes = true;
        }

        Content.Yaml.Set("hasNotes", hasNotes.ToString().ToLowerInvariant());
    }
}