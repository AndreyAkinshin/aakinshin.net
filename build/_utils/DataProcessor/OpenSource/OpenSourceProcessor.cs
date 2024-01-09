using System.IO;
using DataProcessor.Common;

namespace DataProcessor.OpenSource
{
    public class OpenSourceProcessor
    {
        public void Run()
        {
            var openSource = OpenSourceDataProvider.ReadOpenSource();

            var tomlEn = OpenSourceFormatter.Instance.ToToml(openSource.En);
            var tomlRu = OpenSourceFormatter.Instance.ToToml(openSource.Ru);

            var dataGenDirectory = DirectoryDetector.GetDataGenDirectory();
            if (!Directory.Exists(dataGenDirectory))
                Directory.CreateDirectory(dataGenDirectory);

            File.WriteAllText(Path.Combine(dataGenDirectory, "opensource_en.toml"), tomlEn);
            File.WriteAllText(Path.Combine(dataGenDirectory, "opensource_ru.toml"), tomlRu);
        }
    }
}