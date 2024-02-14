using DataProcessor.Media;
using DataProcessor.OpenSource;
using DataProcessor.Publications;
using DataProcessor.Publications.Papers;
using DataProcessor.Talks;

namespace DataProcessor
{
    class Program
    {
        static void Main(string[] args)
        {
            if (args.Length == 2 && args[0] == "import")
            {
                PublicationImporter.Instance.Import(args[1]);
                return;
            }

            new TalkProcessor().Run();
            new MediaProcessor().Run();
            new PublicationProcessor().Run();
            new OpenSourceProcessor().Run();

            PaperStorage.Refresh();
        }
    }
}