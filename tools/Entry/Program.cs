using Common.Utils;
using Generate;

namespace Entry;

internal class Program
{
    public static int Main(string[] args)
    {
        if (args.Length == 0)
        {
            Logger.Error("No verb specified.");
            return -1;
        }

        var runner = Runner.Instance;

        if (args.Length == 1)
        {
            switch (args[0])
            {
                case "update":
                case "u":
                    runner.Update();
                    return 0;
                case "download":
                    runner.Download();
                    return 0;
                case "fetch":
                case "f":
                    new GlobalStorage().FetchAsync().Wait();
                    return 0;
            }
        }

        if (args.Length == 2)
        {
            switch (args[0])
            {
                case "import":
                    runner.ImportBib(args[1]);
                    return 0;
                case "doi":
                    runner.Doi(args[1]);
                    return 0;
                case "quote":
                case "q":
                    runner.Quote(args[1]);
                    return 0;
                case "web":
                case "w":
                    runner.Web(args[1]);
                    return 0;
            }
        }

        if (args.Length == 3)
        {
            switch (args[0])
            {
                case "rename":
                    runner.Rename(args[1], args[2]);
                    return 0;
            }
        }

        Logger.Error("Unknown verb: " + args[0]);
        return -1;
    }
}