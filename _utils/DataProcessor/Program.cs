using DataProcessor.Media;
using DataProcessor.OpenSource;
using DataProcessor.Publications;
using DataProcessor.Talks;

namespace DataProcessor
{
    class Program
    {
        static void Main(string[] args)
        {
            new TalkProcessor().Run();
            new MediaProcessor().Run();
            new PublicationProcessor().Run();
            new OpenSourceProcessor().Run();
        }
    }
}