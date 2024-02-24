using Common.Io;
using Common.Utils;
using Generate.Common;
using YamlDotNet.RepresentationModel;

namespace Generate.Talks;

public class TalkProcessor
{
    public void Run()
    {
        var yaml = new YamlStream();
        yaml.Load(new StreamReader(Path.Combine(FileSystem.Raw, "talks.yaml")));
        var yamlRoot = (YamlMappingNode) yaml.Documents[0].RootNode;
        var talkYamlList = ((YamlSequenceNode) yamlRoot.Children.Values.First())
            .Children.Cast<YamlMappingNode>().ToList();

        var talkListEn = TalkParser.En.Parse(talkYamlList);
        var talkListRu = TalkParser.Ru.Parse(talkYamlList);

        var tomlEn = TalkFormatter.En.ToToml(talkListEn);
        var tomlRu = TalkFormatter.Ru.ToToml(talkListRu);

        var dataGenDirectory = FileSystem.DataGen;
        if (!Directory.Exists(dataGenDirectory))
            Directory.CreateDirectory(dataGenDirectory);
            
        File.WriteAllText(Path.Combine(dataGenDirectory, "talks_en.toml"), tomlEn);
        File.WriteAllText(Path.Combine(dataGenDirectory, "talks_ru.toml"), tomlRu);
    }
}