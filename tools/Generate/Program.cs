using Common.Papers;
using Common.Publications;
using Generate.Media;
using Generate.OpenSource;
using Generate.Talks;

namespace Generate;

class Program
{
    static void Main()
    {
        new TalkProcessor().Run();
        new MediaProcessor().Run();
        new PublicationProcessor().Run();
        new OpenSourceProcessor().Run();
        PaperStorage.Refresh();
    }
}