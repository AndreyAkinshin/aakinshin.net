using System.IO;
using DataProcessor.Common;

namespace DataProcessor.Publications
{
    public class PublicationProcessor
    {
        private const string MetaEncoding = "<meta charset=\"utf-8\">\n";

        public void Run()
        {
            var listEn = PublicationEntry.ReadAll( PublicationLanguage.English,"Akinshin.En.bib", "Akinshin.InRussian.bib", "Akinshin.Translation.bib");
            var listRu = PublicationEntry.ReadAll(PublicationLanguage.Russian,"Akinshin.En.bib", "Akinshin.Ru.bib", "Akinshin.Translation.bib");

            var tomlEn = listEn.ToToml();
            var tomlRu = listRu.ToToml(PublicationLanguage.Russian);

            var dataGenDirectory = DirectoryDetector.GetDataGenDirectory();
            if (!Directory.Exists(dataGenDirectory))
                Directory.CreateDirectory(dataGenDirectory);

            File.WriteAllText(Path.Combine(dataGenDirectory, "publications_en.toml"), tomlEn);
            File.WriteAllText(Path.Combine(dataGenDirectory, "publications_ru.toml"), tomlRu);
        }
    }
}