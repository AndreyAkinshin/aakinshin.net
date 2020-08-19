using System.Collections.Generic;
using System.Linq;
using DataProcessor.Common;
using YamlDotNet.RepresentationModel;

namespace DataProcessor.OpenSource
{
    public class OpenSourceParser : YamlParser
    {
        public static readonly OpenSourceParser En = new OpenSourceParser("en");
        public static readonly OpenSourceParser Ru = new OpenSourceParser("ru");

        private OpenSourceParser(string lang) : base(lang)
        {
        }

        private OpenSourceRepo ParseRepo(YamlMappingNode yaml) => new OpenSourceRepo
        {
            Url = GetStr(yaml, "url"),
            Title = GetStr(yaml, "title")
        };

        private List<OpenSourceRepo> ParseRepos(YamlMappingNode yaml)
        {
            var yamlList = Get(yaml, "repos") as YamlSequenceNode;
            if (yamlList == null)
                return new List<OpenSourceRepo>();
            return yamlList.Children
                .Select(repo => ParseRepo((YamlMappingNode) repo))
                .ToList();
        }

        public OpenSourceRepoGroup ParseRepoGroup(YamlMappingNode yaml) => new OpenSourceRepoGroup
        {
            Role = GetStr(yaml, "role"),
            Repos = ParseRepos(yaml)
        };

        public OpenSourceActivityGroup ParseActivityGroup(YamlMappingNode yaml) => new OpenSourceActivityGroup
        {
            Month = GetStr(yaml, "month"),
            Repos = ParseRepos(yaml)
        };
    }
}