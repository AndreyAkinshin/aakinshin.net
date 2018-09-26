---
layout: post
title: "Visual Studio and ProjectTypeGuids.cs"
date: "2016-02-27"
lang: en
type: post
tags:
- ".NET"
- C#
- VisualStudio
- Hate
- Rider
redirect_from:
- /en/blog/dotnet/projecttypeguids/
- /blog/post/projecttypeguids/
---

It's a story about how I tried to open a project in Visual Studio for a few hours. The other day, I was going to do some work. I pulled last commits from a repo, opened Visual Studio, and prepared to start coding. However, one of a project in my solution failed to open with a strange message:

```
error  : The operation could not be completed.
```

In the Solution Explorer, I had *"load failed"* as a project status and the following message instead of the file tree: *"The project requires user input. Reload the project for more information."* Hmm, ok, I reloaded the project and got a few more errors:

```
error  : The operation could not be completed.
error  : The operation could not be completed.
```
<!--more-->

Long story short, I did the following things:

* `del /s *.suo *.user`
* `git clean -xfd`
* `shutdown -r`

Northing helps. Then I started to investigate which commit broke project loading. Long live `git bisect`, the commit was found. But it did not contain anything suspicious. Just a new unremarkable file called `ProjectTypeGuids.cs` and the following file in `.csproj`:

```xml
<Compile Include="ProjectTypeGuids.cs" />
```

What can be possible wrong with such commit? Further investigation revealed the following non-obvious fact: Visual Studio can't load a project that contains the `ProjectTypeGuids.cs`. I'm serious. Try it yourself:

1. Open Visual Studio (2013 or 2015).
2. Create a console application or a class library.
3. Add new file: `ProjectTypeGuids.cs`.
4. Save all.
5. Close the solution.
6. Try to open this solution.

There is a corresponded bug on connect.microsoft.com: [Visual Studio Project Load bug](http://connect.microsoft.com/VisualStudio/feedbackdetail/view/763638/visual-studio-project-load-bug)

> There is a bug in Visual studio console project loader module.
> Usually the project file for most applications (e.g. silverlight) has certain XML attributes like "ProjectTypeGuids" and "OutputType" among several others. Some don't have them e.g. console.
> If i create a console project and add a file which is named similar (case sensitive) to one of the attributes (e.g. Add ProjectTypeGuids.cs to the console project), Unload it and then try to reload it; the project fails to load.
> "The project type is not supported by this installation" is the error that is thrown.
> If the case of file name is altered manually in csproj file, the correct file does get picked up and the project reloads succesfully.

Unfortunately, the bug status is "Closed as Won't Fix". So, we should just live with that. I just renamed this file in my project and now everything works fine.

By the way, [Rider](https://blog.jetbrains.com/dotnet/2016/01/13/project-rider-a-csharp-ide/) open such projects very well. =)

### See also

* [Happy Monday!](/en/blog/dotnet/happy-monday/)