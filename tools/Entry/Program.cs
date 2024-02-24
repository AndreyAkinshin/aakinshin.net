using Common.Papers;
using Common.Publications;
using Generate.Media;
using Generate.OpenSource;
using Generate.Talks;

namespace Entry;

internal class Program
{
    public static int Main(string[] args)
    {
        if (args.Length == 0)
        {
            Error("No verb specified.");
            return -1;
        }

        if (args[0] == "import" && args.Length > 1)
        {
            PublicationImporter.Instance.Import(args[1]);
            return 0;
        }

        if (args[0] == "generate" || args[0] == "gen")
        {
            new TalkProcessor().Run();
            new MediaProcessor().Run();
            new PublicationProcessor().Run();
            new OpenSourceProcessor().Run();
            PaperStorage.Refresh();
            return 0;
        }

        Error("Unknown verb: " + args[0]);
        return -1;
    }

    private static void Error(string message)
    {
        Console.ForegroundColor = ConsoleColor.Red;
        Console.Error.WriteLine(message);
        Console.ResetColor();
    }
}