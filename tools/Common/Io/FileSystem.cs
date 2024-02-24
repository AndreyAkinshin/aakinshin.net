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

    public static DirectoryPath Papers => Hugo.SubDirectory("hugo", "en", "papers");
}