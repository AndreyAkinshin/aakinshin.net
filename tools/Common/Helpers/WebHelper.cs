using Common.Io;

namespace Common.Helpers;

public static class WebHelper
{
    private static readonly HttpClient Client = new();

    public static async Task<byte[]> DownloadBytesAsync(string url) => await Client.GetByteArrayAsync(url);
    public static async Task<string> DownloadStringAsync(string url) => await Client.GetStringAsync(url);

    public static async Task DownloadFileAsync(string url, FilePath filePath)
    {
        var bytes = await DownloadBytesAsync(url);
        filePath.Parent?.EnsureExists();
        await File.WriteAllBytesAsync(filePath, bytes);
    }
}