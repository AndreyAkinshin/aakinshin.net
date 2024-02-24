using Common.Papers;

namespace Import;

internal class Program
{
    public static void Main(string[] args)
    {
        PublicationImporter.Instance.Import(args[0]);
    }
}