using Common.Io;
using Common.Utils;
using Generate.Common;
using YamlDotNet.RepresentationModel;

namespace Generate.OpenSource;

public class OpenSourceDataProvider
{
    public static OpenSourceData ReadOpenSource()
    {
        var yaml = new YamlStream();
        yaml.Load(new StreamReader(Path.Combine(FileSystem.Raw, "opensource.yaml")));
        var yamlRoot = (YamlMappingNode) yaml.Documents[0].RootNode;
        var githubYamlList = ((YamlSequenceNode) yamlRoot.Children.Values.First())
            .Children.Cast<YamlMappingNode>().ToList();
        var ru = githubYamlList.Select(it => OpenSourceParser.Ru.ParseRepoGroup(it)).ToList();
        var en = githubYamlList.Select(it => OpenSourceParser.En.ParseRepoGroup(it)).ToList();
        return new OpenSourceData(ru, en);
    }

    public static OpenSourceActivitiesData ReadActivities()
    {
        var yaml = new YamlStream();
        yaml.Load(new StreamReader("activities.yaml"));
        var yamlRoot = (YamlMappingNode) yaml.Documents[0].RootNode;
        var githubYamlList = ((YamlSequenceNode) yamlRoot.Children.Values.First())
            .Children.Cast<YamlMappingNode>().ToList();
        var ru = githubYamlList.Select(it => OpenSourceParser.Ru.ParseActivityGroup(it)).ToList();
        var en = githubYamlList.Select(it => OpenSourceParser.En.ParseActivityGroup(it)).ToList();
        return new OpenSourceActivitiesData(ru, en);
    }
}