---
layout: post
title: "InvalidDataException in Process.GetProcesses"
date: "2017-02-10"
lang: en
type: post
tags:
- .NET
- Rider
- Bugs
- Xplat
- CoreCLR
redirect_from:
- /en/blog/dotnet/invaliddataexception-in-getprocesses/
- /blog/post/invaliddataexception-in-getprocesses/
---

Consider the following program:

```cs
public static void Main(string[] args)
{
    try
    {
        Process.GetProcesses();
    }
    catch (Exception e)
    {
        Console.WriteLine(e);
    }
}
```

It seems that all exceptions should be caught.
However, *sometimes*, I had the following exception on Linux with `dotnet cli-1.0.0-preview2`:

```
$ dotnet run
System.IO.InvalidDataException: Found invalid data while decoding.
   at System.IO.StringParser.ParseNextChar()
   at Interop.procfs.TryParseStatFile(String statFilePath, ParsedStat& result, ReusableTextReader reusableReader)
   at System.Diagnostics.ProcessManager.CreateProcessInfo(ParsedStat procFsStat, ReusableTextReader reusableReader)
   at System.Diagnostics.ProcessManager.CreateProcessInfo(Int32 pid, ReusableTextReader reusableReader)
   at System.Diagnostics.ProcessManager.GetProcessInfos(String machineName)
   at System.Diagnostics.Process.GetProcesses(String machineName)
   at System.Diagnostics.Process.GetProcesses()
   at DotNetCoreConsoleApplication.Program.Main(String[] args) in /home/akinshin/Program.cs:line 12
```

How is that possible?

<!--more-->

### Preamble
I'm the guy who writes unit testing support in [Rider](https://www.jetbrains.com/rider/).
And it works fine with classic unit tests on the full .NET framework and mono.
I know that there are many bugs here (Rider is still in the EAP stage), but at least it works:
  you can discover tests, run them, and even debug them.
However, we also have to support new dotnet cli test toolchain.
And there are many troubles with coreclr (probably because it is also in the preview stage).
Even if our communication logic with `dotnet test` works on Windows, it doesn't mean that it works on Linux and MacOS.
Today I want to tell you a story about one bug investigation.
In fact, we have a lot of such stories, but this one is in my favorite bug list.
This story happened in October 2016, so I will tell you about `dotnet cli-1.0.0-preview2` (in `preview4` bug was fixed).

### Situation
Do you know what happens when you click 'Run' on a unit test from a modern C# project (e.g. based on project.json) in Rider?
It starts a new process like this:
```
$ dotnet test --port 36513 --parentProcessId 3624 --no-build --framework net451
```

And it works perfectly on Windows. On Linux, I had the following exception:
```
dotnet-test Error: 0 : System.IO.InvalidDataException: Found invalid data while decoding.
   at System.IO.StringParser.ParseNextChar()
   at Interop.procfs.TryParseStatFile(String statFilePath, ParsedStat& result, ReusableTextReader reusableReader)
   at System.Diagnostics.ProcessManager.CreateProcessInfo(ParsedStat procFsStat, ReusableTextReader reusableReader)
   at System.Diagnostics.ProcessManager.CreateProcessInfo(Int32 pid, ReusableTextReader reusableReader)
   at System.Diagnostics.ProcessManager.GetProcessInfos(String machineName)
   at System.Diagnostics.Process.GetProcesses(String machineName)
   at System.Diagnostics.Process.GetProcesses()
   at Microsoft.DotNet.Tools.Test.TestCommand.RegisterForParentProcessExit(Int32 id)
   at Microsoft.DotNet.Tools.Test.TestCommand.DoRun(String[] args)
```

### Investigation
It seems that the problem is in `Process.GetProcesses()`.
It was easy to write a minimal repro which produces this bug (you can find it at the beginning of the post).
Usually, I do a final check for such bugs in a sterile environment: I close all applications and run it from the terminal.
Guess what?
My little program works without any exception now.
Hmmm...
Ok, open this wonderful program in Rider and run it: the `InvalidDataException` is back.
Hmmm...
Ok, another experiment: keep Rider opened and run the program from the terminal: we again see `InvalidDataException`.
Huh!
It seems that if we want to reproduce the bug, we have to run the program while Rider is running too.

At this point, I decided to create an issue on GitHub: [dotnet/corefx#12755](https://github.com/dotnet/corefx/issues/12755).
Thanks to [@@stephentoub](https://github.com/stephentoub), he helped me to understand what is going on here.

### Explanation
Rider is based on the [IntelliJ](https://www.jetbrains.com/idea/) platform and [ReSharper](https://www.jetbrains.com/resharper/).
So, we have two main processes: a JVM process and a CLR process.
The name if the CLR process is `JetBrains.ReSharper.Host.exe` which includes a lot of threads.
ReSharper is very complicated multithreading application, and we have our own pool of threads (each one has its own name).
Here is a bug [explanation](https://github.com/dotnet/corefx/issues/12755#issuecomment-254853345) by [@@stephentoub](https://github.com/stephentoub):

> The JetBrains.ReSharper.Host.exe process has a thread in it with a name that includes spaces: "JetPool (S) Reg".
> When we're parsing the processes' task list looking for its threads, we parse the stat file for each task, and in doing so, we misinterpret the space in the name as a space separator for the other items in the line.
> The fix in System.Diagnostics.Process is likely to track the parens and ensure we treat the whole parenthesized unit as the name.
> In the meantime, as a workaround, if you have control over the thread/task's name (something somewhere is probably calling a function like pthread_setname_np, or using prctl with PR_SET_NAME), you could try using a name that doesn't include spaces.

### Workaround
Now the bug if fixed, it is a part of
  [.NET Core 2.0](https://github.com/dotnet/corefx/pull/12791) and
  [dotnet cli 1.0.0-preview4](https://github.com/dotnet/cli/issues/4452).
However, many people still use dotnet cli 1.0.0-preview2 and Rider should support it for some time.
We came up with a workaround which allows running unit tests with preview2:
  we just don't specify `--parentProcessId` on Linux/MacOS:

```cs
var commonArgs = string.Format("test --port {0} --no-build{1}",
    server.PortNumber, frameworkArg);
var windowsArgs = string.Format("test --port {0} --parentProcessId {1} --no-build{2}",
    server.PortNumber, Process.GetCurrentProcess().Id, frameworkArg);
var args = PlatformUtil.IsRunningUnderWindows ? windowsArgs : commonArgs;
```

In this case, `dotnet` doesn't call `Process.GetProcesses()` and everything works fine.
Rider is able to establish a connection even when the `--parentProcessId` parameter is omitted.

Of course, we could also rename our threads, but I wanted to fix the bug without any changes in the ReSharper core libraries.

### Conclusion
In Rider, we should support many bleeding edge technologies which contain a lot of bugs.
Hopefully, a big part of such technologies will die soon (and will be replaced by stable version).
However, people can't update all their projects on the same day with the next release of its dependencies.
So, we have to maintain a lot of hacks and ugly pieces of code for several months after the date when another preview was released.
It's not easy, and it conflicts with our sense of beauty,
  but we still try to do everything to make our users happy regardless of which version of runtime they use.

### Links
* [dotnet/corefx#12755: InvalidDataException in Process.GetProcesses on Linux](https://github.com/dotnet/corefx/issues/12755)
* [dotnet/corefx#12791: Fix parsing of procfs stat files when comm name contains spaces](https://github.com/dotnet/corefx/pull/12791)
* [dotnet/corefx#12834: Linux: System.Diagnostics.Process.GetProcesses can throw if reading from /proc for any process fails](https://github.com/dotnet/corefx/issues/12834)
* [dotnet/cli#4452: "dotnet test" crashes if another process or thread has a name with a space](https://github.com/dotnet/cli/issues/4452)
