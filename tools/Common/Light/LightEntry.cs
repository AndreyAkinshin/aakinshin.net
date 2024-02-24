using System.Diagnostics.CodeAnalysis;
using Common.Extensions;
using Common.Helpers;
using Common.Io;
using Common.Utils;

namespace Common.Light;

public class LightEntry
{
    public LightEntry() : this(LightContent.CreateEmpty())
    {
    }

    [SuppressMessage("ReSharper", "VirtualMemberCallInConstructor")]
    public LightEntry(LightContent content)
    {
        Content = content;
        Patch();
    }

    public LightContent Content { get; }

    public virtual string Id => Content.Id;

    protected virtual void Patch()
    {
        var tags = Content.Yaml.GetArray("tags")?.ToList();
        if (tags != null && tags.ContainsIgnoreCase("Statistics"))
            tags.Insert(tags.IndexOfIgnoreCase("Statistics"), "Mathematics");

        var title = Content.Yaml.GetScalar("title");
        if (title != null && title.IsNotBlank())
            Content.Yaml.Set("title", StringHelper.Captialize(title));

        Content.Yaml.Set("hasNotes", Content.Md.IsNotBlank().ToString().ToLowerInvariant());
    }

    public string Format() => Content.Format();

    public void ApplyFromFile(FilePath filePath) =>
        Apply(LightContent.Parse(filePath.NameWithoutExtension, filePath.ReadAllLines()));

    public void Apply(LightContent newContent)
    {
        Content.Apply(newContent);
        Patch();
    }

    public void LogInfo(string message) => Logger.Info($"[{Id}] {message}");
    public void LogTrace(string message) => Logger.Trace($"[{Id}] {message}");
    public void LogError(string message) => Logger.Error($"[{Id}] {message}");
    public void LogError(Exception e) => Logger.Error($"[{Id}] {e.Message}");
}