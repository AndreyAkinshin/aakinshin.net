using System.Diagnostics;

namespace Common.Io;

public record FilePath(string FullPath)
{
    public string Name => Path.GetFileName(FullPath);
    public string NameWithoutExtension => Path.GetFileNameWithoutExtension(FullPath);
    public bool Exists => File.Exists(FullPath);
    public DirectoryPath? Parent => DirectoryPath.ToDirectoryPath(Directory.GetParent(FullPath)?.FullName);

    public void WriteAllText(string content)
    {
        EnsureParentExists();
        File.WriteAllText(FullPath, content);
    }

    public void WriteAllLines(IEnumerable<string> lines)
    {
        EnsureParentExists();
        File.WriteAllLines(FullPath, lines);
    }

    public async Task WriteAllBytesAsync(byte[] bytes) => await File.WriteAllBytesAsync(FullPath, bytes);
    public string ReadAllText() => File.ReadAllText(FullPath);
    public string[] ReadAllLines() => File.ReadAllLines(FullPath);
    public void Delete() => File.Delete(FullPath);
    public DateTime GetLastWriteTime() => File.GetLastAccessTime(FullPath);

    public void EnsureParentExists()
    {
        var parentDirPath = Parent;
        if (parentDirPath is { Exists: false })
            parentDirPath.EnsureExists();
    }

    public Task<string> ReadAllTextAsync() => File.ReadAllTextAsync(FullPath);

    public void CopyTo(FilePath destFilePath, bool overwrite = true) =>
        File.Copy(FullPath, destFilePath.FullPath, overwrite);

    public FilePath CopyTo(DirectoryPath destDirectoryPath, bool overwrite = true)
    {
        var destFilePath = destDirectoryPath.File(Name);
        CopyTo(destFilePath, overwrite);
        return destFilePath;
    }

    public static implicit operator FilePath(string fullPath) => new(fullPath);
    public static implicit operator string(FilePath filePath) => filePath.FullPath;
    public override string ToString() => FullPath;

    public void OpenInVsCode() => Process.Start("code", FullPath);

    public void RenameTo(FilePath newFilePath) => File.Move(FullPath, newFilePath);
}