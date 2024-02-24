using Common.Extensions;
using Common.Helpers;
using Common.Io;
using Common.Light;
using YamlDotNet.RepresentationModel;

namespace Generate.Talks;

public class TalkStorage : LightStorage<TalkFile, TalkEntry>
{
    public TalkStorage() : base(FileSystem.Talks)
    {
        var yamlStream = new YamlStream();
        yamlStream.Load(new StreamReader(Path.Combine(FileSystem.Raw, "talks.yaml")));
        var yamlRoot = (YamlMappingNode)yamlStream.Documents[0].RootNode;
        var talkYamlList = ((YamlSequenceNode)yamlRoot.Children.Values.First())
            .Children.Cast<YamlMappingNode>().ToList();

        var talkListEn = TalkParser.En.Parse(talkYamlList);
        var talkListRu = TalkParser.Ru.Parse(talkYamlList);
        var ids = new HashSet<string>();
        for (int i = 0; i < talkListEn.Count; i++)
        {
            var talkEn = talkListEn[i];
            var talkRu = talkListRu[i];
            var yaml = LightYaml.CreateEmpty();

            void Set(string key, Func<Talk, string> value)
            {
                var valueEn = value(talkEn);
                var valueRu = value(talkRu);
                yaml.Set(key, valueEn);
                if (valueRu != valueEn)
                    yaml.Set(key + "_ru", valueRu);
            }

            Set("date", talk => talk.Date?.FormatNice() ?? "");
            Set("date2", talk => talk.Date2?.FormatNice() ?? "");
            Set("event", talk => talk.Event);
            Set("event_hint", talk => talk.EventHint);
            if (talkEn.Title.IsNotBlank())
                Set("title", talk => talk.Title);
            else
                Set("title", talk => $"Talk at '{talk.Event}'");
            Set("location", talk => talk.Location);
            Set("language", talk => talk.Lang);
            Set("year", talk => talk.Year.ToString());

            // TODO: links
            yaml.Set("urls", talkEn.Links.Select(link => link.Url).ToArray());
            var youtube = talkEn.Links.FirstOrDefault(link => link.Key.EqualsIgnoreCase("youtube"));
            if (youtube != null && youtube.Url.StartsWith("https://www.youtube.com/watch?v="))
            {
                yaml.Set("youtube", youtube.Url.Substring("https://www.youtube.com/watch?v=".Length));
                yaml.Set("tags", ["YouTube"]);
            }

            var md = LightMd.CreateEmpty();
            if (talkEn.Abstract.IsNotBlank())
                md.SetContent("", talkEn.Abstract);

            var year = talkEn.Year.ToString();
            var ev = talkEn.Event.ToSlug();
            if (ev.Contains(year))
                ev = ev
                    .Replace($"-{year}", "")
                    .Replace(year, "");
            var id = "talk-" + year + "-" + ev;
            id = id
                .Replace("ä", "a")
                .Replace("---", "-")
                .Replace("--", "-");

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

            var entry = new TalkEntry(new LightContent(id, yaml, md));
            Files.Add(new TalkFile(entry));
        }
    }
}