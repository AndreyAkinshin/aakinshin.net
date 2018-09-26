---
layout: post
title: DateTime under the hood
date: "2016-08-19"
lang: en
type: post
tags:
- .NET
- Timers
- Internals
redirect_from:
- /en/blog/dotnet/datetime/
- /blog/post/datetime/
---

[DateTime](https://msdn.microsoft.com/library/system.datetime.aspx) is a widely used .NET type. A lot of developers use it all the time, but not all of them really know how it works. In this post, I discuss [DateTime.UtcNow](https://msdn.microsoft.com/library/system.datetime.utcnow.aspx): how it's implemented, what the latency and the resolution of `DateTime` on Windows and Linux, how the resolution can be changed, and how it can affect your application. This post is an overview, so you probably will not see super detailed explanations of some topics, but you will find a lot of useful links for further reading.

<!--more-->

---

### Source

In the .NET Framework, the `DateTime` struct is represented by a `long` value called [Ticks](https://msdn.microsoft.com/library/system.datetime.ticks.aspx). One tick equals to `100 ns`, ticks are counted starting from 12:00 AM January 1, year 1 A.D. (Gregorian Calendar).

In Windows, there is another structure for time called [FILETIME](https://msdn.microsoft.com/library/windows/desktop/ms724284.aspx). It also uses `100 ns`-ticks, but the starting point is January 1, 1601 (UTC). You can get current `FILETIME` via [GetSystemTimeAsFileTime](https://msdn.microsoft.com/en-us/library/windows/desktop/ms724397.aspx).

Now, let's look at the source code of `DateTime` in the coreclr repo: [DateTime.cs](https://github.com/dotnet/coreclr/blob/v1.0.0/src/mscorlib/src/System/DateTime.cs) ([the corresponded class](http://referencesource.microsoft.com/#mscorlib/system/datetime.cs) in the Full .NET Framework looks almost the same; Mono uses code from the full framework directly). The implementation is based on `GetSystemTimeAsFileTime` and use [FileTimeOffset](https://github.com/dotnet/coreclr/blob/v1.0.0/src/mscorlib/src/System/DateTime.cs#L93) for conversion. A simplified version of `UtcNow` from [DateTime.cs](https://github.com/dotnet/coreclr/blob/v1.0.0/src/mscorlib/src/System/DateTime.cs#L915):
```cs
public static DateTime UtcNow {
    get {
        long ticks = 0;
        ticks = GetSystemTimeAsFileTime();
        return new DateTime( ((UInt64)(ticks + FileTimeOffset)) | KindUtc);
    }
}

[MethodImplAttribute(MethodImplOptions.InternalCall)]
internal static extern long GetSystemTimeAsFileTime();
```

You may have noticed `KindUtc` in the constructor argument. In fact, `DateTime` keeps actual `Ticks` only in bits 01-62 of the [dateData](https://github.com/dotnet/coreclr/blob/v1.0.0/src/mscorlib/src/System/DateTime.cs#L137) field; bits 63-64 are used for [DateTimeKind](https://msdn.microsoft.com/en-us/library/shx7s921.aspx) (`Local`, `Utc`, or `Unspecified`).

`extern long GetSystemTimeAsFileTime()` is implemented as follows: on Windows, it uses the [GetSystemTimeAsFileTime](https://msdn.microsoft.com/library/windows/desktop/ms724397.aspx) function from [windows.h](https://en.wikipedia.org/wiki/Windows.h), on Unix it uses [gettimeofday](http://man7.org/linux/man-pages/man2/gettimeofday.2.html) and transforms the received value from the [Unix epoch](https://en.wikipedia.org/wiki/Unix_time) (*January 1, 1970*) to the Win32 epoch (*January 1, 1601*).

Let's dive deeper into the source code for CoreCLR and Mono (you can skip the next two sections if you are not interested in the implementation details).

#### CoreCLR v1.0.0

[src/vm/ecalllist.h](https://github.com/dotnet/coreclr/blob/v1.0.0/src/vm/ecalllist.h#L2219):
```cpp
FCClassElement("DateTime", "System", gDateTimeFuncs)
```

[src/vm/ecalllist.h](https://github.com/dotnet/coreclr/blob/v1.0.0/src/vm/ecalllist.h#L279):
```cpp
FCFuncStart(gDateTimeFuncs)
    FCFuncElement("GetSystemTimeAsFileTime", SystemNative::__GetSystemTimeAsFileTime)
```

[classlibnative/bcltype/system.cpp/system.cpp](https://github.com/dotnet/coreclr/blob/v1.0.0/src/classlibnative/bcltype/system.cpp#L48):
```cpp
FCIMPL0(INT64, SystemNative::__GetSystemTimeAsFileTime)
{
    FCALL_CONTRACT;

    INT64 timestamp;

    ::GetSystemTimeAsFileTime((FILETIME*)&timestamp);

#if BIGENDIAN
    timestamp = (INT64)(((UINT64)timestamp >> 32) | ((UINT64)timestamp << 32));
#endif

    return timestamp;
}
FCIMPLEND;
```

You can find the definition of `FCIMPL0` in [src/vm/fcall.h](https://github.com/dotnet/coreclr/blob/v1.0.0/src/vm/fcall.h).

[pal/src/file/filetime.cpp](https://github.com/dotnet/coreclr/blob/v1.0.0/src/pal/src/file/filetime.cpp#L502):
```cpp
VOID
PALAPI
GetSystemTimeAsFileTime(
            OUT LPFILETIME lpSystemTimeAsFileTime)
{
    struct timeval Time;

    PERF_ENTRY(GetSystemTimeAsFileTime);
    ENTRY("GetSystemTimeAsFileTime(lpSystemTimeAsFileTime=%p)\n", 
          lpSystemTimeAsFileTime);

    if ( gettimeofday( &Time, NULL ) != 0 )
    {
        ASSERT("gettimeofday() failed");
        /* no way to indicate failure, so set time to zero */
        *lpSystemTimeAsFileTime = FILEUnixTimeToFileTime( 0, 0 );
    }
    else
    {
        /* use (tv_usec * 1000) because 2nd arg is in nanoseconds */
        *lpSystemTimeAsFileTime = FILEUnixTimeToFileTime( Time.tv_sec,
                                                          Time.tv_usec * 1000 );
    }

    LOGEXIT("GetSystemTimeAsFileTime returns.\n");
    PERF_EXIT(GetSystemTimeAsFileTime);
}

/*++
Convert a time_t value to a win32 FILETIME structure, as described in
MSDN documentation. time_t is the number of seconds elapsed since 
00:00 01 January 1970 UTC (Unix epoch), while FILETIME represents a 
64-bit number of 100-nanosecond intervals that have passed since 00:00 
01 January 1601 UTC (win32 epoch).
--*/
FILETIME FILEUnixTimeToFileTime( time_t sec, long nsec )
{
    __int64 Result;
    FILETIME Ret;

    Result = ((__int64)sec + SECS_BETWEEN_1601_AND_1970_EPOCHS) * SECS_TO_100NS +
        (nsec / 100);

    Ret.dwLowDateTime = (DWORD)Result;
    Ret.dwHighDateTime = (DWORD)(Result >> 32);

    TRACE("Unix time = [%ld.%09ld] converts to Win32 FILETIME = [%#x:%#x]\n", 
          sec, nsec, Ret.dwHighDateTime, Ret.dwLowDateTime);

    return Ret;
}
```

#### Mono 4.4.2.11

[icall-def.h](https://github.com/mono/mono/blob/mono-4.4.2.11/mono/metadata/icall-def.h#L135):

```cpp
ICALL_TYPE(DTIME, "System.DateTime", DTIME_1)
ICALL(DTIME_1, "GetSystemTimeAsFileTime", mono_100ns_datetime)
```

[mono-time.c](https://github.com/mono/mono/blob/mono-4.4.2.11/mono/utils/mono-time.c):

```cpp
#ifdef HOST_WIN32
#include <windows.h>
//...

/* Returns the number of 100ns ticks since Jan 1, 1601, UTC timezone */
gint64
mono_100ns_datetime (void)
{
    ULARGE_INTEGER ft;

    if (sizeof(ft) != sizeof(FILETIME))
        g_assert_not_reached ();

    GetSystemTimeAsFileTime ((FILETIME*) &ft);
    return ft.QuadPart;
}

#else

// ...

/*
 * Magic number to convert unix epoch start to windows epoch start
 * Jan 1, 1970 into a value which is relative to Jan 1, 1601.
 */
#define EPOCH_ADJUST    ((guint64)11644473600LL)

/* Returns the number of 100ns ticks since 1/1/1601, UTC timezone */
gint64
mono_100ns_datetime (void)
{
    struct timeval tv;
    if (gettimeofday (&tv, NULL) == 0)
        return mono_100ns_datetime_from_timeval (tv);
    return 0;
}

gint64
mono_100ns_datetime_from_timeval (struct timeval tv)
{
    return (((gint64)tv.tv_sec + EPOCH_ADJUST) * 1000000 + tv.tv_usec) * 10;
}

#endif
```

---

### Resolution

#### Windows

As I mentioned previously, the WinAPI function for getting current time is `GetSystemTimeAsFileTime`. If you want to get the `FILETIME` with with the highest possible level of precision, you should use [GetSystemTimePreciseAsFileTime](https://msdn.microsoft.com/library/windows/desktop/hh706895.aspx). There is also the [GetSystemTime](https://msdn.microsoft.com/en-us/library/windows/desktop/ms724390.aspx) function which returns [SYSTEMTIME](https://msdn.microsoft.com/en-us/library/windows/desktop/ms724950.aspx): it works slowly but it returns current time in a well-suited format. You can convert `FILETIME` to `SYSTEMTIME` manually with help of the [FileTimeToSystemTime](https://msdn.microsoft.com/en-us/library/windows/desktop/ms724280.aspx) function.

In this section, only `GetSystemTimeAsFileTime` will be discussed. The resolution of this function may take different values. You can easily get the configuration of your OS with the help of the [ClockRes](https://technet.microsoft.com/en-us/sysinternals/bb897568.aspx) utility from the [Sysinternals Suite](https://technet.microsoft.com/en-us/sysinternals/bb842062.aspx). Here is a typical output on my laptop:

```
> Clockres.exe
Clockres v2.1 - Clock resolution display utility
Copyright (C) 2016 Mark Russinovich
Sysinternals

Maximum timer interval: 15.625 ms
Minimum timer interval: 0.500 ms
Current timer interval: 1.000 ms
```

First of all, look at the maximum timer interval: it equals to `15.625 ms` (this corresponds to a frequency of 64 [Hz](https://en.wikipedia.org/wiki/Hertz)). It's my default DateTime resolution when I don't have any non-system running applications. This value can be changed programmatically by *any application*. For example, my current timer interval is `1 ms`  (frequency = `1000 Hz`). However, there is a limit: my minimum timer interval equals to `0.5 ms` (frequency = `2000 Hz`). The current timer interval may only take value from the specified range.

It's a typical configuration for the modern version of Windows. However, you can observe other resolution values on the older version of Windows. For example, [according](https://msdn.microsoft.com/library/system.datetime.utcnow.aspx#Anchor_1) to MSDN, default resolution of `DateTime` on Windows 98 is about `55ms`. You can also find a lot of useful information about different configuration here: [The Windows Timestamp Project](http://www.windowstimestamp.com/description).

#### Windows Resolution API

So, how it can be changed? There are some Windows API which can be used: [timeBeginPeriod](https://msdn.microsoft.com/en-us/library/dd757624.aspx)/[timeEndPeriod](https://msdn.microsoft.com/en-us/library/dd757626.aspx) from `winmm.dll` and `NtQueryTimerResolution`/`NtSetTimerResolution` from `ntdll.dll`. You can use it directly from C\#, here is a helper class for you:

```cs
public struct ResolutionInfo
{
  public uint Min;
  public uint Max;
  public uint Current;
}

public static class WinApi
{
  [DllImport("winmm.dll", EntryPoint = "timeBeginPeriod", SetLastError = true)]
  public static extern uint TimeBeginPeriod(uint uMilliseconds);

  [DllImport("winmm.dll", EntryPoint = "timeEndPeriod", SetLastError = true)]
  public static extern uint TimeEndPeriod(uint uMilliseconds);

  [DllImport("ntdll.dll", SetLastError = true)]
  private static extern uint NtQueryTimerResolution(out uint min, out uint max, out uint current);

  [DllImport("ntdll.dll", SetLastError = true)]
  private static extern uint NtSetTimerResolution(uint desiredResolution, bool setResolution,
    ref uint currentResolution);

  public static ResolutionInfo QueryTimerResolution()
  {
    var info = new ResolutionInfo();
    NtQueryTimerResolution(out info.Min, out info.Max, out info.Current);
    return info;
  }

  public static ulong SetTimerResolution(uint ticks)
  {
    uint currentRes = 0;
    NtSetTimerResolution(ticks, true, ref currentRes);
    return currentRes;
  }
}
```

Now let's play a little bit with this class. First of all, we can write own `ClockRes` based on the described API:

```cs
var resolutioInfo = WinApi.QueryTimerResolution();
Console.WriteLine($"Min     = {resolutioInfo.Min}");
Console.WriteLine($"Max     = {resolutioInfo.Max}");
Console.WriteLine($"Current = {resolutioInfo.Current}");
```

Output (without any running apps):

```
Min     = 156250
Max     = 5000
Current = 156250
```

Now, let's manually check that `resolutioInfo.Current` is the actual resolution of `DateTime`. Here is a very simple code which shows observed `DateTime` behaviour:

```cs
for (int i = 0; i < 10; i++)
{
  var current = DateTime.UtcNow;
  var last = current;
  while (last == current)
    current = DateTime.UtcNow;
  var diff = current - last;
  Console.WriteLine(diff.Ticks);
}
```

Typical output:

```
155934
156101
156237
156256
156237
```

As you can see, the received numbers are not exactly equal to `156250`. So, the difference between two sequential different `DateTime` values is approximately equal to the current timer interval. 

#### powercfg

For example, your current timer interval is not the maximum timer interval. How do you know who's to blame? Which program increased the system timer frequency? You can check it with the help of [powercfg](https://en.wikipedia.org/wiki/Powercfg). For example, run the following command as administrator:

```
powercfg -energy duration 10
```

This command will monitor you system for 10 seconds and generate an html report (`energy-report.html` in the current directory) with a lot of useful information include information about Platform Timer Resolution:

```
Platform Timer Resolution:Platform Timer Resolution
The default platform timer resolution is 15.6ms (15625000ns) and should be used whenever the system is idle.
If the timer resolution is increased, processor power management technologies may not be effective.
The timer resolution may be increased due to multimedia playback or graphical animations.
  Current Timer Resolution (100ns units) 5003 
  Maximum Timer Period (100ns units) 156250 

Platform Timer Resolution:Outstanding Timer Request
A program or service has requested a timer resolution smaller than the platform maximum timer resolution.
  Requested Period 5000 
  Requesting Process ID 6676 
  Requesting Process Path \Device\HarddiskVolume4\Users\akinshin\ConsoleApplication1.exe 

Platform Timer Resolution:Outstanding Timer Request
A program or service has requested a timer resolution smaller than the platform maximum timer resolution.
  Requested Period 10000 
  Requesting Process ID 10860 
  Requesting Process Path \Device\HarddiskVolume4\Program Files (x86)\Mozilla Firefox\firefox.exe 
```

As you can see, default interval is 15.6ms, Firefox requires 1.0ms interval, and `ConsoleApplication1.exe` in my home directory (which just call `WinApi.SetTimerResolution(5000)`) requires 0.5ms interval. `ConsoleApplication1.exe` won, now I have the maximal possible platform timer frequency.

#### Thread.Sleep

Ok, it sounds interesting, but why we should care about the system timer resolution?
Here I want to ask you a question: what the following call does?

```
Thread.Sleep(1);
```

Somebody can answer: it suspend the current thread for `1 ms`. Unfortunately, it's a wrong answer. The documentation [states](https://msdn.microsoft.com/library/windows/desktop/ms686298.aspx) the following:

> The actual timeout might not be exactly the specified timeout, because the specified timeout will be adjusted to coincide with clock ticks. 

In fact, the elapsed time depends on system timer resolution. Let's write another naive benchmark (we don't need any accuracy here, we just want to show the `Sleep` behavior in a simple way; so, we don't need usual benchmarking routine here like a warmup, statistics, and so on):

```cs
for (int i = 0; i < 5; i++)
{
  var sw = Stopwatch.StartNew();
  Thread.Sleep(1);
  sw.Stop();
  var time = sw.ElapsedTicks * 1000.0 / Stopwatch.Frequency;
  Console.WriteLine(time + " ms");
}
```

Typical output (for current timer interval = `15.625ms`):

```
14.8772437280584 ms
15.5369201880125 ms
18.6300283418281 ms
15.5728431635545 ms
15.6129649284456 ms
```

As you can see, the elapsed intervals are much more than `1 ms`. Now, let's run Firefox (which sets the interval to `1ms`) and repeat our stupid benchmark:

```
1.72057056881932 ms
1.48123957592228 ms
1.47983997947259 ms
1.47237546507424 ms
1.49756820116866 ms
```

Firefox affected the `Sleep` call and reduced elapsed interval by ~ten times. You can find a good explanation of the `Sleep` behavior in [The Windows Timestamp Project](http://www.windowstimestamp.com/description):

> Say the *ActualResolution* is set to 156250, the interrupt heartbeat of the system will run at 15.625 ms periods or 64 Hz, and a call to Sleep is made with the desired delay of 1 ms. Two scenarios are to be looked at:
> * The call was made < 1ms (ΔT) ahead of the next interrupt. The next interrupt will not confirm that the desired period of time has expired. Only the following interrupt will cause the call to return. The resulting sleep delay will be ΔT + 15.625ms.
> * The call was made ≥ 1ms (ΔT) ahead of the next interrupt. The next interrupt will force the call to return. The resulting sleep delay will be ΔT.

There are many others `Sleep` “features”, but they are beyond the scope of this post. You can read another interesting read about the subject here: [Random ASCII: Sleep Variation Investigated (2013)](https://randomascii.wordpress.com/2013/04/02/sleep-variation-investigated/)

Of course, there are another Windows API which depends on the system timer resolution (e.g. [Waitable Timer ](https://msdn.microsoft.com/en-us/library/windows/desktop/ms687012.aspx)). We will not discuss this class in detail, I just want to recommend you once again to read this great text: [The Windows Timestamp Project](http://www.windowstimestamp.com/description)

---

#### Linux

As I mentioned before, on Linux, `DateTime.UtcNow` uses the [gettimeofday](http://man7.org/linux/man-pages/man2/gettimeofday.2.html) function. There are a lot of interesting posts on the internet about how it's work (see the [Links](#links) section), so I will not repeat them, I will just put some short summary here.

`gettimeofday` allows you to get time in microseconds. Thus, `1us` is the minimal possible resolution. The actual resolution depends on linux version and hardware, but nowadays `1us` is also your actual resolution (this is not guaranteed). Internally it's usually based on a high-precision hardware timer and use [vsyscall/vDSO](https://lwn.net/Articles/446528/) to reduce latency (you can find some asm code [here](http://stackoverflow.com/a/7269039/184842)).

---

### Benchmarks

Let's write simple benchmarks with the help of [BenchmarkDotNet](https://github.com/PerfDotNet/BenchmarkDotNet) (*v0.9.9*):

```cs
[ClrJob, CoreJob, MonoJob]
public class DateTimeBenchmarks
{
  [Benchmark]
  public long Latency() => DateTime.UtcNow.Ticks;

  [Benchmark]
  public long Resolution()
  {
    long lastTicks = DateTime.UtcNow.Ticks;
    while (DateTime.UtcNow.Ticks == lastTicks)
    {
    }
    return lastTicks;
  }
}
```

#### Windows

```ini
BenchmarkDotNet=v0.9.9.0
OS=Microsoft Windows NT 6.2.9200.0 (Windows 10 anniversary update)
Processor=Intel(R) Core(TM) i7-4702MQ CPU 2.20GHz, ProcessorCount=8
Frequency=2143473 ticks, Resolution=466.5326 ns, Timer=TSC
CLR1=CORE, Arch=64-bit ? [RyuJIT]
CLR2=MS.NET 4.0.30319.42000
CLR3=Mono JIT compiler version 4.2.3
JitModules=clrjit-v4.6.1586.0
dotnet cli version: 1.0.0-preview2-003121
```
  

Current Timer Interval = `15.625ms`:

|     Method | Runtime |             Median |        StdDev |
|----------- |-------- |-------------------:|--------------:|
|    Latency |     Clr |          7.0471 ns |     0.0342 ns |
| Resolution |     Clr | 15,599,814.5300 ns | 2,754.4628 ns |
|    Latency |    Core |          7.0481 ns |     0.0367 ns |
| Resolution |    Core | 15,597,438.1294 ns | 2,655.8045 ns |
|    Latency |    Mono |         30.4011 ns |     0.2043 ns |
| Resolution |    Mono | 15,550,311.0491 ns | 6,562.2114 ns |


Current Timer Interval = `0.5ms` (running AIMP):

|     Method | Runtime |          Median |        StdDev |
|----------- |-------- |----------------:|--------------:|
|    Latency |     Clr |       7.3655 ns |     0.1102 ns |
| Resolution |     Clr | 499,666.4219 ns |   811.5021 ns |
|    Latency |    Core |       7.3545 ns |     0.0602 ns |
| Resolution |    Core | 499,357.0707 ns | 1,021.2058 ns |
|    Latency |    Mono |      31.5868 ns |     0.2685 ns |
| Resolution |    Mono | 499,696.0358 ns |   673.2927 ns |


#### Linux

Xubuntu 16.04.01, the same hardware:

```ini
BenchmarkDotNet=v0.9.9.0
OS=Unix 4.4.0.34
Processor=Intel(R) Core(TM) i7-4702MQ CPU 2.20GHz, ProcessorCount=8
CLR1=CORE, Arch=64-bit ? [RyuJIT]
CLR2=Mono 4.4.2 (Stable 4.4.2.11/f72fe45 Fri Jul 29 09:58:49 UTC 2016), Arch=64-bit RELEASE
dotnet cli version: 1.0.0-preview2-003121
```

|     Method | Runtime |        Median |    StdDev |
|----------- |-------- |--------------:|----------:|
|    Latency |    Core |    27.2925 ns | 0.4665 ns |
| Resolution |    Core | 1,000.7250 ns | 0.5176 ns |
|    Latency |    Mono |    26.6243 ns | 1.3973 ns |
| Resolution |    Mono |   998.2508 ns | 1.4941 ns |

---

### Summary

Now we know that the resolution and the latency of `DateTime` may be tricky. On Windows, the resolutions depend on Windows System Timer; it can be changed programmatically by any application. Usually, it's about `0.5 ms`..`15.625 ms`. On Linux, the resolution is typical `1 us`. However, the latency on Windows is usually several times smaller that the latency on Linux (but you should not care about it in most cases).

Typically, `DateTime` is a good choice when you want to know the current time (e.g. for logging) and you don't need high precision. However, beware of DateTime-specific phenomena (see [Falsehoods programmers believe about time](http://infiniteundo.com/post/25326999628/falsehoods-programmers-believe-about-time) and [More falsehoods programmers believe about time](http://infiniteundo.com/post/25509354022/more-falsehoods-programmers-believe-about-time)). If you need to measure some time interval (not just put an approximate timestamp into a log file), you probably need a better tool. In the next post, I will tell about `Stopwatch`: how it's implemented, what the latency and the resolution of `Stopwatch`, how it works on different operating systems and runtimes, and why we should use `Stopwatch` on .NET, rather than alternative measurements tools.  

---

### Links

#### MSDN

* [MSDN: DateTime](https://msdn.microsoft.com/library/system.datetime.aspx)
* [MSDN: DateTime.UtcNow](https://msdn.microsoft.com/library/system.datetime.utcnow.aspx)
* [MSDN: DateTime.Ticks](https://msdn.microsoft.com/library/system.datetime.ticks.aspx)
* [MSDN: DateTime — Resolution](https://msdn.microsoft.com/library/system.datetime.aspx#Resolution)
* [MSDN: GetSystemTimePreciseAsFileTime](https://msdn.microsoft.com/library/windows/desktop/hh706895.aspx)
* [MSDN: timeBeginPeriod](https://msdn.microsoft.com/en-us/library/dd757624.aspx)
* [MSDN: timeEndPeriod](https://msdn.microsoft.com/en-us/library/dd757626.aspx)
* [MSDN: Acquiring high-resolution time stamps](https://msdn.microsoft.com/library/windows/desktop/dn553408.aspx)

#### Sources
* [ReferenceSource: system/datetime.cs](http://referencesource.microsoft.com/#mscorlib/system/datetime.cs)
* [coreclr-v1.0.0: mscorlib/src/System/DateTime.cs](https://github.com/dotnet/coreclr/blob/v1.0.0/src/mscorlib/src/System/DateTime.cs)
* [coreclr-v1.0.0: pal/src/file/filetime.cpp](https://github.com/dotnet/coreclr/blob/v1.0.0/src/pal/src/file/filetime.cpp)
* [coreclr-v1.0.0: classlibnative/bcltype/system.cpp](https://github.com/dotnet/coreclr/blob/v1.0.0/src/classlibnative/bcltype/system.cpp#L48)
* [mono-4.4.2.11: mono-time.c](https://github.com/mono/mono/blob/mono-4.4.2.11/mono/utils/mono-time.c)
* [mono-4.4.2.11: icall-def.h](https://github.com/mono/mono/blob/mono-4.4.2.11/mono/metadata/icall-def.h)

#### Useful software

* [ClockRes](https://technet.microsoft.com/en-us/sysinternals/bb897568.aspx)
* [Sysinternals Suite](https://technet.microsoft.com/en-us/sysinternals/bb842062.aspx)

#### Misc
* [The Windows Timestamp Project](http://www.windowstimestamp.com/description)
* [Wiki: System time](https://en.wikipedia.org/wiki/System_time)
* [man7.org: gettimeofday(2)](http://man7.org/linux/man-pages/man2/gettimeofday.2.html)
* [lwn.net: On vsyscalls and the vDSO](https://lwn.net/Articles/446528/)
* [The Clock Mini-HOWTO (2000)](http://tldp.org/HOWTO/Clock.html)

#### Blog posts
* [Infinite Undo!: Falsehoods programmers believe about time (2012)](http://infiniteundo.com/post/25326999628/falsehoods-programmers-believe-about-time)
* [Infinite Undo!: More falsehoods programmers believe about time (2012)](http://infiniteundo.com/post/25509354022/more-falsehoods-programmers-believe-about-time)
* [Random ASCII: Windows Timer Resolution: Megawatts Wasted (2013)](https://randomascii.wordpress.com/2013/07/08/windows-timer-resolution-megawatts-wasted/)
* [Random ASCII: Sleep Variation Investigated (2013)](https://randomascii.wordpress.com/2013/04/02/sleep-variation-investigated/)
* [MathPirate: Temporal Mechanics: Changing the Speed of Time, Part II (2010)](http://www.mathpirate.net/log/2010/03/20/temporal-mechanics-changing-the-speed-of-time-part-ii/)
* [The accuracy of gettimeofday in ARM architecture](http://www.programgo.com/article/91674336979/)

#### StackOverflow

* [StackOverflow: Windows 7 timing functions - How to use GetSystemTimeAdjustment correctly?](http://stackoverflow.com/q/7685762/184842)
* [StackOverflow: How frequent is DateTime.Now updated?](http://stackoverflow.com/q/307582/184842)
* [StackOverflow: How is the CLR faster than me when calling Windows API](http://stackoverflow.com/q/37898579/184842)
* [StackOverflow: How is the microsecond time of linux gettimeofday() obtained and what is its accuracy?](http://stackoverflow.com/q/13230719/184842)
* [StackOverflow: Measure time in Linux - time vs clock vs getrusage vs clock_gettime vs gettimeofday vs timespec_get?](http://stackoverflow.com/q/12392278/184842)
* [StackOverflow: Anyone can understand how gettimeofday works?](http://stackoverflow.com/q/7266813/184842)
* [StackOverflow: What are vdso and vsyscall?](http://stackoverflow.com/q/19938324/184842)
