---
layout: post
title: "A bug story about named mutex on Mono"
date: "2017-02-13"
lang: en
type: post
tags:
- .NET
- Rider
- Bugs
- Xplat
- Mono
- CoreCLR
redirect_from:
- /en/blog/dotnet/namedmutex-on-mono/
- /blog/post/namedmutex-on-mono/
---

When you write some multithreading magic on .NET,
  you can use a cool synchronization primitive called [Mutex](https://msdn.microsoft.com/en-us/library/system.threading.mutex(v=vs.110).aspx):
```cs
var mutex = new Mutex(false, "Global\\MyNamedMutex");
```

You also can make it [named](https://msdn.microsoft.com/en-us/library/f55ddskf(v=vs.110).aspx) (and share the mutex between processes)
  which works perfectly on Windows:

<div class="mx-auto">
  <img class="mx-auto d-block" width="600" src="/img/posts/dotnet/namedmutex-on-mono/front.png" />
</div>

However, today the .NET Framework is cross-platform, so this code should work on any operation system.
What will happen if you use named mutex on Linux or MacOS with the help of Mono or CoreCLR?
Is it possible to create some tricky bug based on this case?
Of course, it does.
Today I want to tell you a story about such bug in [Rider](https://www.jetbrains.com/rider/) which was a headache for several weeks.

<!--more-->

### Preamble

The easiest way to avoid troubles with named mutex is the following: don't use them at all.
However, it's not always possible because you may use 3rd party libraries that use named mutex.
Recently, we had such situation in Rider.
We used [NuGet.Client-3.4.3](https://www.nuget.org/packages/NuGet.Client/3.4.3) which contained the `Settings.LoadDefaultSettings` method.
This method reads the content of the [NuGet.Config](https://docs.microsoft.com/en-us/nuget/consume-packages/configuring-nuget-behavior) files with useful information about package feeds and some other NuGet settings.
Of course, other threads or processes can also write to this file (or read from it) at the same time.
So, we have to protect the access to `NuGet.Config` with a synchronization primitive.
NuGet.Client-3.4.3 uses a named mutex for this purpose.
It worked fine in Rider when you used it as a client application.
We also have many integration tests for the NuGet logic and run them on [TeamCity](https://www.jetbrains.com/teamcity/) after each commit.
Sometimes, one of these tests was failing on Linux with the following exception:

```
at <unknown> <0xffffffff>
at (wrapper managed-to-native) System.Threading.WaitHandle.WaitOne_internal (System.Threading.WaitHandle,intptr,int,bool) <0xffffffff>
at System.Threading.WaitHandle.WaitOne (System.TimeSpan,bool) <0x0009b>
at System.Threading.WaitHandle.WaitOne (System.TimeSpan) <0x0001d>
at NuGet.Configuration.Settings.ExecuteSynchronizedCore (System.Action) <0x00143>
at NuGet.Configuration.Settings.ExecuteSynchronized (System.Action) <0x00019>
at NuGet.Configuration.Settings..ctor (string,string,bool) <0x0032b>
at NuGet.Configuration.Settings.ReadSettings (string,string,bool) <0x0008a>
at NuGet.Configuration.Settings.LoadUserSpecificSettings (System.Collections.Generic.List`1<NuGet.Configuration.Settings>,string,string,NuGet.Configuration.IMachineWideSettings,bool) <0x00418>
at NuGet.Configuration.Settings.LoadDefaultSettings (string,string,NuGet.Configuration.IMachineWideSettings,bool,bool) <0x0031e>
at NuGet.Configuration.Settings.LoadDefaultSettings (string,string,NuGet.Configuration.IMachineWideSettings) <0x00026>

Native stacktrace:

0   mono-sgen                           0x000000010e7c976a mono_handle_native_sigsegv + 282
1   libsystem_platform.dylib            0x00007fff8e929f1a _sigtramp + 26
2   mono-sgen                           0x000000010eab167f tmp_dir + 5471
3   libsystem_c.dylib                   0x00007fff86e909b3 abort + 129
4   mono-sgen                           0x000000010e96f7f3 monoeg_log_default_handler + 211
5   mono-sgen                           0x000000010e96f702 monoeg_g_logv + 114
6   mono-sgen                           0x000000010e96fb04 monoeg_assertion_message + 356
7   mono-sgen                           0x000000010e951740 own_if_owned + 0
8   mono-sgen                           0x000000010e8b8430 ves_icall_System_Threading_WaitHandle_WaitOne_internal + 96
9   ???                                 0x0000000113feccb4 0x0 + 4630432948
10  mscorlib.dll.dylib                  0x0000000110ac347e System_Threading_WaitHandle_WaitOne_System_TimeSpan + 30
11  ???                                 0x00000001264dffda 0x0 + 4937613274
```

It was awful because we couldn't obtain a permanent green build status.
Here is the [origin](https://github.com/NuGet/NuGet.Client/blob/58bd2dffe9cee8bf62b601f1610df4e9bbb91106/src/NuGet.Core/NuGet.Configuration/Settings/Settings.cs#L1134) of this exception:

``` cs
// Global: ensure mutex is honored across TS sessions 
using (var mutex = new Mutex(false, $"Global\\{EncryptionUtility.GenerateUniqueToken(fileName)}"))
{
    var owner = false;
    try
    {
        // operations on NuGet.config should be very short lived
        owner = mutex.WaitOne(TimeSpan.FromMinutes(1));
        // decision here is to proceed even if we were not able to get mutex ownership
        // and let the potential IO errors bubble up. Reasoning is that failure to get
        // ownership probably means faulty hardware and in this case it's better to report
        // back than hang
        ioOperation();
    }
```

It seems that the culprit is a named mutex.

### Investigation

We have a bug in NuGet here, so I created an issue: [NuGet/Home#2860](https://github.com/NuGet/Home/issues/2860).
This bug is based on a Mono bug with named mutex.
It was almost impossible to reproduce bug locally, so we started to try to create a minimal repro.
After a few weeks (yep, it wasn't easy), we finally did it (here is the bug report: [bugzilla.xamarin#41914](https://bugzilla.xamarin.com/show_bug.cgi?id=41914)):
```cs
internal class Program
{
    public static void Main(string[] args)
    {
        var a = "";
        for (var i = 0; i < 100; i++)
        {
            new Thread(Crasher).Start();
        }
        Console.WriteLine(a);
        Console.ReadLine();
    }

    private static void Crasher()
    {
        var rnd = new Random();
        while (true)
        {
            Thread.Sleep(rnd.Next(100, 10000));
            using (var mutex = new Mutex(false, "Global\\TEST"))
            {
                var owner = false;
                try
                {
                    owner = mutex.WaitOne(TimeSpan.FromMinutes(1));
                }
                finally
                {
                    if (owner)
                    {
                        mutex.ReleaseMutex();
                    }
                }
                Console.WriteLine("PING");
            }
            Thread.Sleep(rnd.Next(100, 10000));
        }
    }
}
```

Mono 4.4 crashed with the following output:
```
namedmutex_create: error creating mutex handle
PING
PING
PING
PING
PING
PING
PING
PING
PING
PING
PING
PING
PING
PING
_wapi_handle_unref_full: Attempting to unref unused handle 0x4e0
PING
PING
namedmutex_create: error creating mutex handle
PING
PING
PING
PING
PING
PING
_wapi_handle_ref: Attempting to ref unused handle 0x4e3
* Assertion at ../../mono/utils/mono-os-mutex.h:135, condition `res != EINVAL' not met

Stacktrace:

  at <unknown> <0xffffffff>
  at (wrapper managed-to-native) System.Threading.WaitHandle.WaitOne_internal (System.Threading.WaitHandle,intptr,int,bool) <0x00073>
  at System.Threading.WaitHandle.WaitOne (System.TimeSpan,bool) <0x0009b>
  at System.Threading.WaitHandle.WaitOne (System.TimeSpan) <0x0001d>
  at Crasher.Program.Crasher () <0x000f0>
  at System.Threading.ThreadHelper.ThreadStart_Context (object) <0x0009a>
  at System.Threading.ExecutionContext.RunInternal (System.Threading.ExecutionContext,System.Threading.ContextCallback,object,bool) <0x001c6>
  at System.Threading.ExecutionContext.Run (System.Threading.ExecutionContext,System.Threading.ContextCallback,object,bool) <0x00020>
  at System.Threading.ExecutionContext.Run (System.Threading.ExecutionContext,System.Threading.ContextCallback,object) <0x00059>
  at System.Threading.ThreadHelper.ThreadStart () <0x0002e>
  at (wrapper runtime-invoke) object.runtime_invoke_void__this__ (object,intptr,intptr,intptr) <0x000e0>

Native stacktrace:

        0   mono                                0x0000000103f9b0ca mono_handle_native_sigsegv + 271
        1   libsystem_platform.dylib            0x00007fff854c252a _sigtramp + 26
        2   mono                                0x00000001042036a4 tmp_dir + 5316
        3   libsystem_c.dylib                   0x00007fff935536e7 abort + 129
        4   mono                                0x000000010410d1f0 monoeg_g_log + 0
        5   mono                                0x000000010410d175 monoeg_g_logv + 83
        6   mono                                0x000000010410d31a monoeg_assertion_message + 143
        7   mono                                0x00000001040e453d _wapi_handle_timedwait_signal_handle + 1153
        8   mono                                0x00000001040f4aec wapi_WaitForSingleObjectEx + 606
        9   mono                                0x000000010406c01c mono_wait_uninterrupted + 130
        10  mono                                0x000000010406c1ff ves_icall_System_Threading_WaitHandle_WaitOne_internal + 73
        11  ???                                 0x0000000108130b54 0x0 + 4430433108
        12  mscorlib.dll.dylib                  0x00000001062ed7ae System_Threading_WaitHandle_WaitOne_System_TimeSpan + 30
        13  mscorlib.dll.dylib                  0x0000000106140e5b System_Threading_ThreadHelper_ThreadStart_Context_object + 155
        14  mscorlib.dll.dylib                  0x000000010613f331 System_Threading_ExecutionContext_Run_System_Threading_ExecutionContext_System_Threading_ContextCallback_object_bool + 33
        15  mono                                0x0000000103f04876 mono_jit_runtime_invoke + 1578
        16  mono                                0x0000000104090c23 mono_runtime_invoke + 130
        17  mono                                0x0000000104070409 start_wrapper + 424
        18  mono                                0x0000000104106cb1 inner_start_thread + 305
        19  libsystem_pthread.dylib             0x00007fff989c399d _pthread_body + 131
        20  libsystem_pthread.dylib             0x00007fff989c391a _pthread_body + 0
        21  libsystem_pthread.dylib             0x00007fff989c1351 thread_start + 13
```

So, we have troubles with both NuGet and Mono. Let's talk about each bug story.

### NuGet
After a few weeks, we received a useful [comment](https://github.com/NuGet/Home/issues/2860#issuecomment-228174849) by [@@migueldeicaza](https://github.com/migueldeicaza):
> Named mutexes in Mono are process-local, they are not global like they are on Windows, so on the Mono case, it should use the same setup.
> In the past, many years ago, mono supported global mutexes across a processes in the user namespace, but that support was very brittle and we removed the code some 4-5 years ago.

The first idea was to avoid named mutexes.
It was implemented in [NuGet/NuGet.Client#720](https://github.com/NuGet/NuGet.Client/pull/720):
  NuGet uses a named mutex only on Windows;
  otherwise, it uses a process-wide global mutex.
However, it wasn't a perfect solution because our global mutex isn't shared between processes.
So, this commit was reverted and replaced by another approach:
  [NuGet/NuGet.Client#725: use a common locking mechanism (filestream) for all platforms while writing to settings file](https://github.com/NuGet/NuGet.Client/pull/725).
A [comment](https://github.com/NuGet/NuGet.Client/pull/725#issue-163279546) by [@@rohit21agrawal](https://github.com/rohit21agrawal):
> This makes use of a synchronized version of file locking by acquiring a filestream handle on a lock file.
> This approach works across all platforms and can do inter-process synchronization too.

You can find the current implementation in the [NuGet.Client-4.0.0-rc4/ConcurrencyUtilities.cs](https://github.com/NuGet/NuGet.Client/blob/release-4.0.0-rc4/src/NuGet.Core/NuGet.Common/ConcurrencyUtilities.cs) file.
Thus, the issue was resolved.
Due to the fact that we always try to use the latest published version of [NuGet.Client](https://github.com/NuGet/NuGet.Client),
  our integration tests were fixed after a dependencies update.
However, there is still a bug in Mono which should also be fixed.

### Mono
As I mentioned before, we create an [issue](https://bugzilla.xamarin.com/show_bug.cgi?id=41914) in mono bug tracking system (2016-06-16).
Over time (2016-09-14), it was fixed
  ([mono/mono#3560: [w32handle] Fix race condition when creating named mutex/event/semaphore](https://github.com/mono/mono/pull/3560));
  the most interesting changes are in the [w32handle.c](https://github.com/mono/mono/pull/3560/files#diff-2fa9d2ef24b4fd347ae97a87829a5f59).
So, we don't have the described race condition anymore.
However, mutexes in Mono are still process-local, you can't use it across processes.
Also, the MOBILE profile does not support named mutexes at all: [mono-4.6.2.16/Mutex.cs#L164](https://github.com/mono/mono/blob/mono-4.6.2.16/mcs/class/corlib/System.Threading/Mutex.cs#L164),
 it just throws a [NotSupportedException](https://msdn.microsoft.com/en-us/library/system.notsupportedexception(v=vs.110).aspx)
 (see also [bugzilla.xamarin#26067](https://bugzilla.xamarin.com/show_bug.cgi?id=26067)).
Be careful!

### CoreCLR
Mono is not the only xplat .NET runtime; we also have [CoreCLR](https://github.com/dotnet/coreclr)!
How are things going with named mutexes on Linux and MacOS here?

Early versions of CoreCLR just throw a [PlatformNotSupportedException](https://msdn.microsoft.com/en-us/library/system.platformnotsupportedexception(v=vs.110).aspx)
  when users try to create named primitives (see [coreclr#1387](https://github.com/dotnet/coreclr/pull/1387), [corefx#2796](https://github.com/dotnet/corefx/pull/2796)).
It wasn't great because there is a lot of legacy code which already uses named mutexes.
So, after some discussions
  (e.g., see [coreclr#1237](https://github.com/dotnet/coreclr/issues/1237), [coreclr#3422](https://github.com/dotnet/coreclr/issues/3422)),
  the cross-process named mutexes were implemented.
Here is an awesome PR by [@@kouvel](https://github.com/kouvel): [coreclr#5030](https://github.com/dotnet/coreclr/pull/5030).
A fragment from the issue summary:
> * On systems that support pthread process-shared robust recursive mutexes, they will be used
> * On other systems, file locks are used. File locks unfortunately don't have a timeout in the blocking wait call, and I didn't find any other sync object with a timed wait with the necessary properties, so polling is done for timed waits.

### Conclusion
When you write cross-platform .NET applications, think twice before using any OS-specific API.
Always check how it's implemented on your favorite runtime (Mono or CoreCLR).
Even if you are sure that *your code* is completely cross-platform,
  you still should be ready that there are some xplat bugs in libraries which you are using
  (especially if these libraries were originally written for Windows + the full .NET Framework).
Don't forget about unit and integration tests for multithreading code which execute your methods under load.
And make sure that your CI build server runs these tests on all target operation systems.

### Links
* [NuGet/Home#2860: Bug in ExecuteSynchronizedCore on Linux/MacOS + Mono](https://github.com/NuGet/Home/issues/2860)
* [NuGet/NuGet.Client#720: make mono use global mutex instead of named mutex, like in CoreCLR](https://github.com/NuGet/NuGet.Client/pull/720)
* [NuGet/NuGet.Client#725: use a common locking mechanism (filestream) for all platforms while writing to settings file](https://github.com/NuGet/NuGet.Client/pull/725)
* [NuGet.Client-4.0.0-rc4/ConcurrencyUtilities.cs](https://github.com/NuGet/NuGet.Client/blob/release-4.0.0-rc4/src/NuGet.Core/NuGet.Common/ConcurrencyUtilities.cs)
* [bugzilla.xamarin#26067: Mutexes cannot be created with names without resulting in error](https://bugzilla.xamarin.com/show_bug.cgi?id=26067)
* [bugzilla.xamarin#41914: Race condition in named mutex](https://bugzilla.xamarin.com/show_bug.cgi?id=41914)
* [mono/mono#3560: [w32handle] Fix race condition when creating named mutex/event/semaphore](https://github.com/mono/mono/pull/3560)
* [mono/mono#3828: Change clock source to CLOCK_MONOTONIC in 'pthread_cond_timedwait'](https://github.com/mono/mono/pull/3828)
* [dotnet/coreclr#1237: Implement named synchronization primitives to be system wide](https://github.com/dotnet/coreclr/issues/1237)
* [dotnet/coreclr#1387: Throw PlatformNotSupported for named sync primitives on Unix](https://github.com/dotnet/coreclr/pull/1387)
* [dotnet/coreclr#3422: Named mutex not supported on Unix](https://github.com/dotnet/coreclr/issues/3422)
* [dotnet/coreclr#5030: Add named mutex for cross-process synchronization ](https://github.com/dotnet/coreclr/pull/5030)
* [dotnet/corefx#2796: Throw PlatformNotSupportedException for named Semaphore on Unix](https://github.com/dotnet/corefx/pull/2796)
