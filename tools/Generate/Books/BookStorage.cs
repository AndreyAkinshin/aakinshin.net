using Common.Io;
using Common.Light;

namespace Generate.Books;

public class BookStorage() : LightStorage<BookFile, BookEntry>(FileSystem.Books)
{
    public override async Task FetchAsync()
    {
        foreach (var file in Files)
            await file.FetchAsync();
    }
}