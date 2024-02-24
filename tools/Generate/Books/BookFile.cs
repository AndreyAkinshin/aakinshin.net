using Common.Io;
using Common.Light;

namespace Generate.Books;

public class BookFile(BookEntry entry) : LightFile<BookEntry>(entry)
{
    public override DirectoryPath GetRoot() => FileSystem.Books;

    public override async Task FetchAsync()
    {
        await entry.FetchAsync();
        Save();
    }
}