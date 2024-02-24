namespace Common.Io;

public static class FileSystem
{
    private static readonly Lazy<DirectoryPath> LazyRoot = new(() =>
    {
        var current = new DirectoryPath(System.Reflection.Assembly.GetExecutingAssembly().Location);
        while (current != null && current.Name != "tools")
            current = current.Parent;
        current = current?.Parent;
        if (current == null)
            throw new Exception("Failed to find the root directory");
        return current;
    });

    public static DirectoryPath Root => LazyRoot.Value;
    public static DirectoryPath Hugo => Root.SubDirectory("hugo");

    public static DirectoryPath Raw => Hugo.SubDirectory("raw");
    public static DirectoryPath DataGen => Hugo.SubDirectory("data", "gen");
    public static DirectoryPath Content => Hugo.SubDirectory("content", "en");

    public static DirectoryPath Papers => Hugo.SubDirectory(Content, "papers");
    public static DirectoryPath Quotes => Hugo.SubDirectory(Content, "quotes");
    public static DirectoryPath Web => Hugo.SubDirectory(Content, "web");
    public static DirectoryPath Talks => Hugo.SubDirectory(Content, "talks");
    public static DirectoryPath Media => Hugo.SubDirectory(Content, "media");
    public static DirectoryPath Books => Hugo.SubDirectory(Content, "books");

    public static DirectoryPath PdfRoot => DirectoryPath.Home.SubDirectory("Dropbox", "Library");
    public static DirectoryPath PdfPapers => PdfRoot.SubDirectory("Papers");
}