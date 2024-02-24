using System.Collections.Specialized;
using System.Text;
using Common.Collections;
using Common.Extensions;

namespace Common.Light;

public class LightMd(OrderedDictionary<string, string> sections)
{
    private readonly OrderedDictionary<string, string> sections = sections;
    public static LightMd CreateEmpty() => new(new OrderedDictionary<string, string>());
    public string? GetContent(string name) => sections.GetValueOrDefault(name);

    public bool Has(string name) => sections.ContainsKey(name);

    public void SetContent(string name, string value)
    {
        if (value.IsNotBlank())
            sections[name] = value;
    }

    public void DeleteContent(string name) => sections.Remove(name);

    public bool IsBlank() => sections.GetKeys()
        .Where(key => GetNameOrder(key) < 100)
        .All(key => sections[key].IsBlank());

    public bool IsNotBlank() => !IsBlank();

    public IEnumerable<string> GetAllSectionNames()
    {
        var names = new List<string>();
        names.AddRange(sections.Keys);
        names.Sort((a, b) => GetNameOrder(a).CompareTo(GetNameOrder(b)));
        return names;
    }

    private static readonly IReadOnlyDictionary<string, int> SectionOrders = new Dictionary<string, int>
    {
        { "", 0 },
        { "Reference", 101 },
        { "Abstract", 102 },
        { "Bib", 103 },
    };

    private static int GetNameOrder(string name) => SectionOrders.GetValueOrDefault(name, 1);

    public static LightMd Parse(IEnumerable<string> lines)
    {
        var sectionBuilders = new OrderedDictionary<string, StringBuilder>();

        var currentName = "";
        foreach (var line in lines)
        {
            if (line.StartsWith("#"))
            {
                currentName = line[2..].TrimStart('#', ' ').TrimEnd();
            }
            else
            {
                if (!sectionBuilders.ContainsKey(currentName))
                    sectionBuilders[currentName] = new StringBuilder();
                sectionBuilders[currentName].AppendLine(line);
            }
        }

        var sections = new OrderedDictionary<string, string>();
        foreach (var key in sectionBuilders.GetKeys())
        {
            var content = sectionBuilders[key].ToString().Trim();
            if (content.IsNotBlank())
                sections[key] = content;
        }

        return new LightMd(sections);
    }

    public string Format()
    {
        var builder = new StringBuilder();
        foreach (var name in GetAllSectionNames())
        {
            if (name.IsNotBlank())
            {
                builder.AppendLine($"## {name}");
                builder.AppendLine();
            }

            builder.AppendLine(GetContent(name));
            builder.AppendLine();
        }

        return builder.ToString().Trim();
    }

    public void Apply(LightMd newMd)
    {
        foreach (var key in newMd.sections.Keys)
            sections[key] = newMd.sections[key];
    }
}