using System;
using YamlDotNet.RepresentationModel;

namespace DataProcessor.Common
{
    public class YamlParser
    {
        protected readonly string Lang;

        protected YamlParser(string lang)
        {
            Lang = lang;
        }

        protected YamlNode Get(YamlMappingNode yaml, string name)
        {
            var generalKey = new YamlScalarNode(name);
            var langKey = new YamlScalarNode($"{name}_{Lang}");
            if (yaml.Children.ContainsKey(generalKey))
                return yaml.Children[generalKey];
            if (yaml.Children.ContainsKey(langKey))
                return yaml.Children[langKey];
            return null;
        }

        protected string GetStr(YamlMappingNode yaml, string name)
        {
            return Get(yaml, name)?.ToString().Trim() ?? string.Empty;
        }

        protected int GetInt(YamlMappingNode yaml, string name)
        {
            return int.Parse(GetStr(yaml, name));
        }

        protected DateTime? GetDate(YamlMappingNode yaml, string name)
        {
            var str = GetStr(yaml, name);
            return string.IsNullOrEmpty(str) ? (DateTime?) null : DateTime.Parse(str);
        }
    }
}