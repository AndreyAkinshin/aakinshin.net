using Common.Io;
using Common.Light;

namespace Generate.Books;

public class BooksStorage() : LightStorage<BookFile, BookEntry>(FileSystem.Books)
{
    public override async Task FetchAsync()
    {
        foreach (var file in Files)
            await file.FetchAsync();
    }
}