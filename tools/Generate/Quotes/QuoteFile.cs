using Common.Io;
using Common.Light;

namespace Generate.Quotes;

public class QuoteFile(QuoteEntry entry) : LightFile<QuoteEntry>(entry)
{
    public override DirectoryPath GetRoot() => FileSystem.Quotes;
}