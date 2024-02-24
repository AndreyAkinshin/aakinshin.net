using Common.Io;
using Common.Light;

namespace Generate.Web;

public class WebFile(WebEntry entry) : LightFile<WebEntry>(entry)
{
    public override DirectoryPath GetRoot() => FileSystem.Web;
}