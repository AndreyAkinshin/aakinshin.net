using Common.Io;
using Common.Light;

namespace Generate.Media;

public class MediaFile(LightEntry entry) : LightFile<LightEntry>(entry)
{
    public override DirectoryPath GetRoot() => FileSystem.Media;
}