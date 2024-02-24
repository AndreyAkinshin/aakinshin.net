using Generate.Common;
using YamlDotNet.RepresentationModel;

namespace Generate.Media;

public class MediaParser : YamlParser
{
    public static readonly MediaParser En = new MediaParser("en");
    public static readonly MediaParser Ru = new MediaParser("ru");

    private MediaParser(string lang) : base(lang)
    {
    }

    public List<MediaItem> Parse(List<YamlMappingNode> yamlNodes)
    {
        return yamlNodes.Select(item => Parse((YamlMappingNode) item)).ToList();
    }

    public MediaItem Parse(YamlMappingNode yaml) => new MediaItem()
    {
        Date = GetDate(yaml, "date"),
        Type = GetStr(yaml, "type"),
        Kind = GetStr(yaml, "kind"),
        Host = GetStr(yaml, "host"),
        Title = GetStr(yaml, "title"),
        Lang = GetStr(yaml, "lang"),
        Url = GetStr(yaml, "url")
    };
}