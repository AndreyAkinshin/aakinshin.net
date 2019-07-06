using System;
using System.Collections.Generic;
using System.Linq;
using Utils;
using YamlDotNet.RepresentationModel;

namespace Media
{
    public class MediaItem
    {
        public DateTime? Date { get; set; }
        public string Type { get; set; }
        public string Host { get; set; }
        public string Title { get; set; }
        public string Lang { get; set; }
        public string Url { get; set; }
    }
    public class Parser : YamlParser
    {
        public static readonly Parser En = new Parser("en");
        public static readonly Parser Ru = new Parser("ru");

        private Parser(string lang) : base(lang)
        {
        }

        public List<MediaItem> Parse(List<YamlMappingNode> yamlNodes)
        {
            return yamlNodes.Select(item => Parse(item)).ToList();
        }

        public MediaItem Parse(YamlMappingNode yaml) => new MediaItem()
        {
            Date = GetDate(yaml, "date"),
            Type = GetStr(yaml, "type"),
            Host = GetStr(yaml, "host"),
            Title = GetStr(yaml, "title"),
            Lang = GetStr(yaml, "lang"),
            Url = GetStr(yaml, "url")
        };
    }
}