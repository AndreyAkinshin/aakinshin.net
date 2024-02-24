using Common.Io;

namespace Common.Light;

public static class LightFileHelper
{
    public static bool IsServiceFile(FilePath filePath) =>
        filePath.Name.StartsWith('_') ||
        filePath.Name == "index.md" ||
        filePath.Name == ".md";

}