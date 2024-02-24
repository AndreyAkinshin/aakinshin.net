namespace Generate.Talks;

public class TalkLink
{
    private static readonly Dictionary<string, string> faDictionary = new Dictionary<string, string>()
    {
        {"youtube", "youtube"},
        {"pdf", "file-pdf"},
        {"slideshare", "slideshare"},
        {"photos", "camera-retro"},
        {"org", "building"}
    };

    private static readonly Dictionary<string, string> keyLegend = new Dictionary<string, string>
    {
        {"youtube", "Video (YouTube)"},
        {"slides-web", "Presentation (Web)"},
        {"pdf", "Presentation (Pdf)"},
        {"slideshare", "Presentation (SlideShare)"},
        {"talk", "Abstract"},
        {"google-slides", "Presentation (GoogleSlides)"},
    };

    public string Key { get; set; }
    public string Url { get; set; }
    public string Caption { get; set; }
    public string Title { get; set; }

    private static string Capitalize(string s) => s.First().ToString().ToUpper() + s.Substring(1);

    public string ToHtml()
    {
        var label = GetLabel();
        return $"<a href=\"{Url}\" class=\"badge badge-light\">{label}</a>";
    }

    public string GetLabel()
    {
        var label = Title;
        if (string.IsNullOrWhiteSpace(label))
        {
            label = keyLegend.ContainsKey(Key) ? keyLegend[Key] : Capitalize(Key);
            if (faDictionary.ContainsKey(Key))
                label = $"<svg class='fai'><use xlink:href='/img/fa/all.svg#{faDictionary[Key]}'></use></svg> {label}";
            if (!string.IsNullOrWhiteSpace(Caption))
                label += " (" + Caption + ")";
        }

        return label;
    }
}