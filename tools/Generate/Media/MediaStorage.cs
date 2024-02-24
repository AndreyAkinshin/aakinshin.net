using Common.Helpers;
using Common.Io;
using Common.Light;
using YamlDotNet.RepresentationModel;

namespace Generate.Media;

public class MediaStorage : LightStorage<MediaFile, LightEntry>
{
    public MediaStorage() : base(FileSystem.Media)
    {
        var yamlStream = new YamlStream();
        yamlStream.Load(new StreamReader(Path.Combine(FileSystem.Raw, "media.yaml")));
        var yamlRoot = (YamlMappingNode)yamlStream.Documents[0].RootNode;
        var mediaYamlList = ((YamlSequenceNode)yamlRoot.Children.Values.First())
            .Children.Cast<YamlMappingNode>().ToList();

        var mediaListEn = MediaParser.En.Parse(mediaYamlList).OrderBy(x => x.Date).ToList();
        var mediaListRu = MediaParser.Ru.Parse(mediaYamlList).OrderBy(x => x.Date).ToList();
        var ids = new HashSet<string>();
        for (int i = 0; i < mediaListEn.Count; i++)
        {
            var mediaEn = mediaListEn[i];
            var mediaRu = mediaListRu[i];
            var yaml = LightYaml.CreateEmpty();

            void Set(string key, Func<MediaItem, string> value)
            {
                var valueEn = value(mediaEn);
                var valueRu = value(mediaRu);
                yaml.Set(key, valueEn);
                if (valueRu != valueEn)
                    yaml.Set(key + "_ru", valueRu);
            }

            Set("date", media => media.Date!.Value.FormatNice() ?? "");
            Set("title", media => media.Title);
            Set("contentType", media => media.Type);
            Set("contentKind", media => media.Kind);
            Set("contentHost", media => media.Host);
            Set("language", talk => talk.Lang);
            yaml.Set("urls", [mediaEn.Url]);

            var url = mediaEn.Url;
            if (url.StartsWith("https://www.youtube.com/watch?v="))
            {
                yaml.Set("youtube", url.Substring("https://www.youtube.com/watch?v=".Length));
                yaml.Set("tags", ["YouTube"]);
            }

            var year = mediaEn.Date!.Value.Year.ToString();
            var id = "media-" + year + "-" + mediaEn.Host.ToSlug();

            if (ids.Contains(id))
            {
                for (var c = 'a'; c <= 'z'; c++)
                    if (!ids.Contains(id + "-" + c))
                    {
                        id += "-" + c;
                        break;
                    }

                if (ids.Contains(id))
                    throw new Exception("Duplicate id: " + id);
            }

            ids.Add(id);

            var entry = new LightEntry(new LightContent(id, yaml, LightMd.CreateEmpty()));
            Files.Add(new MediaFile(entry));
        }
    }
}