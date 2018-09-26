---
layout: post
title: "NuGet2 and a DirectorySeparatorChar bug"
date: "2017-02-06"
lang: en
type: post
tags:
- .NET
- Rider
- Bugs
- Performance
- NuGet
redirect_from:
- /en/blog/dotnet/nuget2-and-directoryseparatorchar/
- /blog/post/nuget2-and-directoryseparatorchar/
---

In [Rider](https://www.jetbrains.com/rider/), we care a lot about performance.
I like to improve the application responsiveness and do interesting optimizations all the time.
Rider is already well-optimized, and it's often hard to make significant performance improvements, so usually I do micro-optimizations which do not have a very big impact on the whole application.
However, sometimes it's possible to improve the speed of a feature 100 times with just a few lines of code.

Rider is based on [ReSharper](https://www.jetbrains.com/resharper/), so we have a lot of cool features out of the box.
One of these features is [Solution-Wide Analysis](https://www.jetbrains.com/help/resharper/2016.3/Code_Analysis__Solution-Wide_Analysis.html)
  which lets you constantly keep track of issues in your solution.
Sometimes, solution-wide analysis takes a lot of time to run because there are many files which should be analyzed.
Of course, it works super fast on small and projects.

Let's talk about a performance bug ([#RIDER-3742](https://youtrack.jetbrains.com/issue/RIDER-3742)) that we recently had.
* *Repro:* Open Rider, create a new "ASP .NET MVC Application", enable solution wide-analysis.
* *Expected:* The analysis should take 1 second.
* *Actual:* The analysis takes 1 second on Windows and **2 minutes** on Linux and MacOS.

<!--more-->

The solution-wide analysis builds a list of files which should be analyzed.
New asp.net applications depend on eleven NuGet packages include `bootstrap` and `jQuery`.
Thus, we have many css and JavaScript files in our project model.
Obviously, such files don't include any user code and should be ignored during the analysis.
On Windows, we have a nice optimization which checks the content of NuGet packages and creates an ignore list.
It turned out that for some reason the ignore list is empty on Linux and MacOS, so all the project model files are added into the analysis list.
As a result, the solution-wide analysis takes 2 minutes (instead of 1 second) to process all these files.

We use NuGet.Client 4.x for all new features in ReSharper and Rider.
However, we still have a huge amount of legacy code which uses NuGet.Core 2.x.
In particular, the solution-wide analysis still uses NuGet 2.13.
It's hard to rewrite our entire codebase to make use of the new NuGet API at once, so we still have to use the older one for some time.
Hopefully, it will be completely rewritten soon, but for now, we have issues with a higher priority.

So, the main question here is the following: why can't we read the content of the NuGet packages and get the complete content file list.
Let's look at the corresponding logic:

```cs
foreach (var contentFile in package.GetContentFiles())
    newContent.Add(GetEffectivePath(contentFile));
```

Here is the NuGet [source code](https://github.com/NuGet/NuGet2/blob/2.13/src/Core/Extensions/PackageExtensions.cs#L64) (v2.13):
```cs
public static class Constants
{
    /// <summary>
    /// Represents the content directory in the package.
    /// </summary>
    public static readonly string ContentDirectory = "content";
}

public static class PackageExtensions
{
    public static IEnumerable<IPackageFile> GetContentFiles(this IPackage package)
    {
        return package.GetFiles(Constants.ContentDirectory);
    }
    
    public static IEnumerable<IPackageFile> GetFiles(this IPackage package, string directory)
    {
        string folderPrefix = directory + Path.DirectorySeparatorChar;
        return package.GetFiles().Where(file => file.Path.StartsWith(folderPrefix, StringComparison.OrdinalIgnoreCase));
    }  
}
```

The next interesting thing here is what `file.Path` looks like.
Let's download the `bootstrap.4.0.0-alpha6` package and extract metadata (`.nuspec`).
Here is the `files` section:

```cs
<files>
    <file src="content\Content\bootstrap-grid.css" target="content\Content\bootstrap-grid.css" />
    <file src="content\Content\bootstrap-grid.css.map" target="content\Content\bootstrap-grid.css.map" />
    <file src="content\Content\bootstrap-grid.min.css" target="content\Content\bootstrap-grid.min.css" />
    <file src="content\Content\bootstrap-grid.min.css.map" target="content\Content\bootstrap-grid.min.css.map" />
    <file src="content\Content\bootstrap-reboot.css" target="content\Content\bootstrap-reboot.css" />
    <file src="content\Content\bootstrap-reboot.css.map" target="content\Content\bootstrap-reboot.css.map" />
    <file src="content\Content\bootstrap-reboot.min.css" target="content\Content\bootstrap-reboot.min.css" />
    <file src="content\Content\bootstrap-reboot.min.css.map" target="content\Content\bootstrap-reboot.min.css.map" />
    <file src="content\Content\bootstrap.css" target="content\Content\bootstrap.css" />
    <file src="content\Content\bootstrap.css.map" target="content\Content\bootstrap.css.map" />
    <file src="content\Content\bootstrap.min.css" target="content\Content\bootstrap.min.css" />
    <file src="content\Content\bootstrap.min.css.map" target="content\Content\bootstrap.min.css.map" />
    <file src="content\Scripts\bootstrap.js" target="content\Scripts\bootstrap.js" />
    <file src="content\Scripts\bootstrap.min.js" target="content\Scripts\bootstrap.min.js" />
</files>
```

You can see those file paths in the `nuspec` files use the Windows path separator `\`
  (see [Representations of paths by operating system and shell](https://en.wikipedia.org/wiki/Path_(computing)#Representations_of_paths_by_operating_system_and_shell)).
In the source code, we form a `folderPrefix` with the help of
  [Path.DirectorySeparatorChar](https://msdn.microsoft.com/en-us/library/system.io.path.directoryseparatorchar(v=vs.110).aspx):
```cs
string folderPrefix = directory + Path.DirectorySeparatorChar;
```

The `Path.DirectorySeparatorChar` equals to `/` on Linux and MacOS and doesn't equal to the actual `nuspec` separator.
So, `PackageExtensions.GetContentFiles` returns an empty list.
Let's do an experiment and rewrite `GetContentFiles` in the following way:
```cs
private static IEnumerable<IPackageFile> GetContentFilesXPlat(IPackage package)
{
  // In a nuspec file we can use any path separator, it's impossible to say which one is used in advance.
  var folderPrefix1 = Constants.ContentDirectory + @@"/";
  var folderPrefix2 = Constants.ContentDirectory + @@"\";
  return package.GetFiles().Where(file =>
    file.Path.StartsWith(folderPrefix1, StringComparison.OrdinalIgnoreCase) ||
    file.Path.StartsWith(folderPrefix2, StringComparison.OrdinalIgnoreCase));
}
```

Now we can use `GetContentFilesXPlat` in our code and get the actual list of content files.
I checked that this method now works fine, so I made a commit, pushed it, closed the issue, and started to solve our next performance puzzle.

The next day, I saw that the issue was reopened.
Our QA engineer told me that the bug is still here.

Hmm, ok, let's debug this logic again.
If you read the first code snippet carefully, you may notice that we are working with "effective paths":
```cs
newContent.Add(GetEffectivePath(contentFile));
```

Each `IPackageFile` package has `Path` and `EffectivePath`:
```cs
public interface IPackageFile : IFrameworkTargetable
{
    string Path { get; }
    string EffectivePath { get; }
    FrameworkName TargetFramework { get; }
    Stream GetStream();
}

```

I did a few more debugging sessions and discovered the following values for the `bootstrap-theme` package file:

| OS      | Path                                | EffectivePath                       |
|-------- |------------------------------------ |------------------------------------ |
| Windows | content\Content\bootstrap-theme.css | Content\bootstrap-theme.css         |
| Linux   | content\Content\bootstrap-theme.css | content\Content\bootstrap-theme.css |

You can see that we have the wrong effective path on Linux (`content\Content\bootstrap-theme.css` instead of `Content\bootstrap-theme.css`).
So, how does NuGet calculate the effective paths? Let's look at the source code again.
[NuGet-2.13, VersionUtility.cs](https://github.com/NuGet/NuGet2/blob/2.13/src/Core/Utility/VersionUtility.cs#L773):
```cs
public static FrameworkName ParseFrameworkNameFromFilePath(string filePath, out string effectivePath)
{
    var knownFolders = new string[]
    {
        Constants.ContentDirectory,
        Constants.LibDirectory,
        Constants.ToolsDirectory,
        Constants.BuildDirectory
    };
    for (int i = 0; i < knownFolders.Length; i++)
    {
        string folderPrefix = knownFolders[i] + System.IO.Path.DirectorySeparatorChar;
        if (filePath.Length > folderPrefix.Length &&
            filePath.StartsWith(folderPrefix, StringComparison.OrdinalIgnoreCase))
        {
            string frameworkPart = filePath.Substring(folderPrefix.Length);
            try
            {
                return VersionUtility.ParseFrameworkFolderName(
                    frameworkPart,
                    strictParsing: knownFolders[i] == Constants.LibDirectory,
                    effectivePath: out effectivePath);
            }
            catch (ArgumentException)
            {
                // if the parsing fails, we treat it as if this file
                // doesn't have target framework.
                effectivePath = frameworkPart;
                return null;
            }
        }
    }
    effectivePath = filePath;
    return null;
}
```

And again, we have a `DirectorySeparatorChar` bug here:
```cs
string folderPrefix = knownFolders[i] + System.IO.Path.DirectorySeparatorChar;
```
I rewrote this method too; now everything works fine.
I built Rider, checked, and double-checked that the solution-wide analysis takes only 1 second on Linux and MacOS.

Usually, we send pull requests to 3rd projects with our fixes.
However, it turned out that there are 53 usages of `DirectorySeparatorChar` in the NuGet2 source code.
So, I just created an issue: [NuGet/Home#4509](https://github.com/NuGet/Home/issues/4509).

Of course, it wasn't the first bug with `\` and `/`: we fight with them all the time.
I suspect that we will meet a lot of such bugs in the future.
For now, we have a significant performance improvement for the solution-wide analysis for new asp.net projects on Linux and MacOS
  (this fix will be included in Rider EAP17).