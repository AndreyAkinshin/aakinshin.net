using System.IO;
using System.Linq;
using DataProcessor.Common;
using YamlDotNet.RepresentationModel;

namespace DataProcessor.Talks
{
    public class TalkProcessor
    {
        public void Run()
        {
            var yaml = new YamlStream();
            yaml.Load(new StreamReader(Path.Combine(DirectoryDetector.GetDataRawDirectory(), "talks.yaml")));
            var yamlRoot = (YamlMappingNode) yaml.Documents[0].RootNode;
            var talkYamlList = ((YamlSequenceNode) yamlRoot.Children.Values.First())
                .Children.Cast<YamlMappingNode>().ToList();

            var talkListEn = TalkParser.En.Parse(talkYamlList);
            var talkListRu = TalkParser.Ru.Parse(talkYamlList);

            var tomlEn = TalkFormatter.En.ToToml(talkListEn);
            var tomlRu = TalkFormatter.Ru.ToToml(talkListRu);

            var dataGenDirectory = DirectoryDetector.GetDataGenDirectory();
            if (!Directory.Exists(dataGenDirectory))
                Directory.CreateDirectory(dataGenDirectory);
            
            File.WriteAllText(Path.Combine(dataGenDirectory, "talks_en.toml"), tomlEn);
            File.WriteAllText(Path.Combine(dataGenDirectory, "talks_ru.toml"), tomlRu);
        }
    }
}