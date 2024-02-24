using Common.Io;
using Common.Light;

namespace Generate.Web;

public class WebStorage() : LightStorage<WebFile, WebEntry>(FileSystem.Web)
{
    public WebFile Import(string url) => ImportAsync(url).Result;

    public async Task<WebFile> ImportAsync(string url)
    {
        var entry = await WebEntry.ImportAsync(url);
        var file = Add(new WebFile(entry));
        file.Save();
        return file;
    }
}