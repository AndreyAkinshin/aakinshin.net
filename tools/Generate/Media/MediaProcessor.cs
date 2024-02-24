using Common.Io;
using Common.Utils;
using Generate.Common;
using YamlDotNet.RepresentationModel;

namespace Generate.Media;

public class MediaProcessor
{
    public void Run()
    {
        var yaml = new YamlStream();
        yaml.Load(new StreamReader(Path.Combine(FileSystem.Raw, "media.yaml")));
        var yamlRoot = (YamlMappingNode) yaml.Documents[0].RootNode;
        List<YamlMappingNode> mediaYamlList = ((YamlSequenceNode) yamlRoot.Children.Values.First())
            .Children.Cast<YamlMappingNode>().ToList();

        var mediaListEn = MediaParser.En.Parse(mediaYamlList);
        var mediaListRu = MediaParser.Ru.Parse(mediaYamlList);

        var tomlEn = MediaFormatter.En.ToToml(mediaListEn);
        var tomlRu = MediaFormatter.Ru.ToToml(mediaListRu);

        var dataGenDirectory = FileSystem.DataGen;
        if (!Directory.Exists(dataGenDirectory))
            Directory.CreateDirectory(dataGenDirectory);

        File.WriteAllText(Path.Combine(dataGenDirectory, "media_en.toml"), tomlEn);
        File.WriteAllText(Path.Combine(dataGenDirectory, "media_ru.toml"), tomlRu);
    }
}