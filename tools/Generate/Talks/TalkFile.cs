using Common.Io;
using Common.Light;

namespace Generate.Talks;

public class TalkFile(TalkEntry entry) : LightFile<TalkEntry>(entry)
{
    public override DirectoryPath GetRoot() => FileSystem.Talks;
}