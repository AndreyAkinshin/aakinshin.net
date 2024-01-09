using System.Collections.Generic;
using System.Linq;
using DataProcessor.Common;
using YamlDotNet.RepresentationModel;

namespace DataProcessor.Talks
{
    public class TalkParser : YamlParser
    {
        public static readonly TalkParser En = new TalkParser("en");
        public static readonly TalkParser Ru = new TalkParser("ru");

        private TalkParser(string lang) : base(lang)
        {
        }

        private TalkLink ParseLink(YamlMappingNode yaml)
        {
            var link = new TalkLink
            {
                Key = GetStr(yaml, "key"),
                Url = GetStr(yaml, "url"),
                Caption = GetStr(yaml, "caption"),
                Title = GetStr(yaml, "title")
            };
            if (link.Key.Contains("_"))
            {
                if (link.Key.EndsWith("_" + Lang))
                    link.Key = link.Key.Replace("_" + Lang, "");
                else
                    link = null;
            }

            return link;
        }

        private List<TalkLink> GetLinks(YamlMappingNode yaml, string name)
        {
            var yamlList = Get(yaml, name) as YamlSequenceNode;
            if (yamlList == null)
                return new List<TalkLink>();
            return yamlList.Children
                .Select(link => ParseLink((YamlMappingNode) link))
                .Where(link => link != null)
                .ToList();
        }

        public List<Talk> Parse(List<YamlMappingNode> yamlNodes)
        {
            return yamlNodes.Select(conf => Parse(conf)).ToList();
        }

        public Talk Parse(YamlMappingNode yaml) => new Talk
        {
            Date = GetDate(yaml, "date"),
            Date2 = GetDate(yaml, "date2"),
            Event = GetStr(yaml, "event"),
            EventHint = GetStr(yaml, "event-hint"),
            Title = GetStr(yaml, "title"),
            Location = GetStr(yaml, "location"),
            Lang = GetStr(yaml, "lang"),
            Year = GetDate(yaml, "date")?.Year ?? GetInt(yaml, "year"),
            Links = GetLinks(yaml, "links")
        };
    }
}