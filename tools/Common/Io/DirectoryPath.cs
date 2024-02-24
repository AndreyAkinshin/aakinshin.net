using Common.Extensions;

namespace Common.Io;

public class DirectoryPath(string fullPath) : IEquatable<DirectoryPath>
{
    public static readonly DirectoryPath Empty = new("");

    public string FullPath { get; } = fullPath;
    public string Name => Path.GetFileName(FullPath);
    public DirectoryPath? Parent => ToDirectoryPath(Directory.GetParent(FullPath)?.FullName);
    public bool Exists => Directory.Exists(FullPath);
    public bool IsEmpty => FullPath.IsEmpty();

    public IEnumerable<DirectoryPath> EnumerateDirectories() => Directory
        .EnumerateDirectories(FullPath)
        .Select(path => new DirectoryPath(path));

    public IEnumerable<DirectoryPath> EnumerateDirectoriesRecursively() => Directory
        .EnumerateDirectories(FullPath, "*", SearchOption.AllDirectories)
        .Select(path => new DirectoryPath(path));

    public IEnumerable<FilePath> EnumerateFiles(string searchPattern = "")
    {
        var files = searchPattern.IsBlank()
            ? Directory.EnumerateFiles(FullPath)
            : Directory.EnumerateFiles(FullPath, searchPattern);
        return files.Select(path => new FilePath(path));
    }

    public IEnumerable<FilePath> EnumerateFilesRecursively(string searchPattern = "")
    {
        var files = searchPattern.IsBlank()
            ? Directory.EnumerateFiles(FullPath, "*", SearchOption.AllDirectories)
            : Directory.EnumerateFiles(FullPath, searchPattern, SearchOption.AllDirectories);
        return files.Select(path => new FilePath(path));
    }

    public DirectoryPath EnsureExists()
    {
        if (Exists)
            return this;
        Directory.CreateDirectory(FullPath);
        return this;
    }

    public DirectoryPath InitBlank()
    {
        if (Exists)
            Delete();
        return EnsureExists();
    }

    public void Delete(bool recursive = true)
    {
        if (Exists)
            Directory.Delete(FullPath, recursive);
    }

    public void Create()
    {
        if (!Exists)
            Directory.CreateDirectory(FullPath);
    }

    public void CopyTo(DirectoryPath destination)
    {
        if (!Exists)
            throw new DirectoryNotFoundException($"Directory '{FullPath}' does not exist");

        if (!destination.Exists)
            destination.EnsureExists();
        foreach (var sourceFilePath in EnumerateFiles())
            sourceFilePath.CopyTo(destination.File(sourceFilePath.Name));
        foreach (var sourceSubDirPath in EnumerateDirectories())
            sourceSubDirPath.CopyTo(destination.SubDirectory(sourceSubDirPath.Name));
    }

    public DirectoryPath SubDirectory(string name) => Path.Combine(FullPath, name);
    public DirectoryPath SubDirectory(params string[] names) => Path.Combine(FullPath, Path.Combine(names));
    public FilePath File(string name) => Path.Combine(FullPath, name);

    public static implicit operator DirectoryPath(string fullPath) => new(fullPath);
    public static implicit operator string(DirectoryPath directoryPath) => directoryPath.FullPath;
    public override string ToString() => FullPath;

    public static DirectoryPath? ToDirectoryPath(string? fullPath) =>
        fullPath == null ? null : new DirectoryPath(fullPath);

    public static DirectoryPath Home => new(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile));

    public bool Equals(DirectoryPath? other)
    {
        if (ReferenceEquals(null, other)) return false;
        if (ReferenceEquals(this, other)) return true;
        return FullPath == other.FullPath;
    }

    public override bool Equals(object? obj)
    {
        if (ReferenceEquals(null, obj)) return false;
        if (ReferenceEquals(this, obj)) return true;
        if (obj.GetType() != this.GetType()) return false;
        return Equals((DirectoryPath)obj);
    }

    public override int GetHashCode() => FullPath.GetHashCode();

    public static bool operator !=(DirectoryPath? left, DirectoryPath? right) => !Equals(left, right);
    public static bool operator ==(DirectoryPath? left, DirectoryPath? right) => Equals(left, right);
}