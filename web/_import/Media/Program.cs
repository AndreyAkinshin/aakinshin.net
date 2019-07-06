using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using YamlDotNet.Core;
using YamlDotNet.RepresentationModel;

namespace Media
{
    class Program
    {
        static void Main(string[] args)
        {
            var yaml = new YamlStream();
            yaml.Load(new StreamReader("media.yaml"));
            var yamlRoot = (YamlMappingNode) yaml.Documents[0].RootNode;
            List<YamlMappingNode> mediaYamlList = ((YamlSequenceNode) yamlRoot.Children.Values.First())
                .Children.Cast<YamlMappingNode>().ToList();

            var mediaListEn = Parser.En.Parse(mediaYamlList);
            var mediaListRu = Parser.Ru.Parse(mediaYamlList);

            var htmlEn = Formatter.En.ToHtml(mediaListEn);
            var htmlRu = Formatter.Ru.ToHtml(mediaListRu);

            if (!Directory.Exists("_generated"))
                Directory.CreateDirectory("_generated");

            File.WriteAllText(Path.Combine("_generated", "media.html"), htmlEn);
            File.WriteAllText(Path.Combine("_generated", "media-ru.html"), htmlRu);
            File.WriteAllText(Path.Combine("_generated", "media-count.txt"), mediaListEn.Count.ToString());
            File.WriteAllText(Path.Combine("_generated", "media-ru-count.txt"), mediaListRu.Count.ToString());

            // Console.WriteLine(htmlEn);
            // Console.WriteLine("-------------");
            // Console.WriteLine(htmlRu);
        }
    }
}