---
layout: post-toc
title: Stopwatch under the hood
date: "2016-09-09"
lang: en
type: post
tags:
- .NET
- Hardware
- Timers
- Internals
redirect_from:
- /en/blog/dotnet/stopwatch/
- /blog/post/stopwatch/
---

In [the previous post](/en/blog/dotnet/datetime/), we discussed `DateTime`.
This structure can be used in situations when you don't need a good level of precision.
If you want to do high-precision time measurements, you need a better tool because `DateTime` has a small resolution and a big latency.
Also, time is tricky, you can create wonderful bugs if you don't understand how it works (see [Falsehoods programmers believe about time](http://infiniteundo.com/post/25326999628/falsehoods-programmers-believe-about-time) and [More falsehoods programmers believe about time](http://infiniteundo.com/post/25509354022/more-falsehoods-programmers-believe-about-time)).

In this post, we will briefly talk about the [Stopwatch](https://msdn.microsoft.com/library/system.diagnostics.stopwatch.aspx) class:

* Which kind of hardware timers could be a base for `Stopwatch`
* High precision timestamp API on Windows and Linux
* Latency and Resolution of `Stopwatch` in different environments
* Common pitfalls: which kind of problems could we get trying to measure small time intervals

If you are not a .NET developer, you can also find a lot of useful information in this post: mainly we will discuss low-level details of high-resolution timestamping (probably your favorite language also uses the same API).
As usual, you can also find useful links for further reading. 

<!--more-->

<div id="toc"></div>

---

### Hardware timers

#### TSC

**TSC** — [Time Stamp Counter](https://en.wikipedia.org/wiki/Time_Stamp_Counter).
It is an internal 64-bit register present on all x86 processors since the Pentium.
Can be read into `EDX:EAX` using the instruction `RDTSC`.

You can fine a lot of useful information in [Intel: Intel® 64 and IA-32 Architectures Software Developer’s Manual](http://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-manual-325462.pdf). In this section, I will often refer to this manual and will call it just “the manual”.

Opcode for `RDTSC` is `0F 31` (the manual, Vol. 2B 4-545).
On Windows, it can be read directly from C# code with help of the following asm injection:

```cs
const uint PAGE_EXECUTE_READWRITE = 0x40;
const uint MEM_COMMIT = 0x1000;

[DllImport("kernel32.dll", SetLastError = true)]
static extern IntPtr VirtualAlloc(IntPtr lpAddress, uint dwSize, 
                                  uint flAllocationType, uint flProtect);

static IntPtr Alloc(byte[] asm)
{
    var ptr = VirtualAlloc(IntPtr.Zero, (uint)asm.Length, 
                           MEM_COMMIT, PAGE_EXECUTE_READWRITE);
    Marshal.Copy(asm, 0, ptr, asm.Length);
    return ptr;
}

delegate long RdtscDelegate();

static readonly byte[] rdtscAsm =
{
    0x0F, 0x31, // rdtsc
    0xC3        // ret
};

static void Main()
{
    var rdtsc = Marshal.GetDelegateForFunctionPointer<RdtscDelegate>(Alloc(rdtscAsm));
    Console.WriteLine(rdtsc());
}
```

On modern hardware and modern operation systems, TSC works well, but it has a long history and people often consider TSC as an unreliable source of timestamps.
Let's discuss different generations of TSC and problems which we could get with TSC (you can find more information about it in the manual, Vol. 3B 17-40, section 17.15).

**Variant TSC**

The first version of TSC (see the list of the processors families in the manual, Vol. 3B 17-40, section 17.15) was very simple: it just counts internal processor clock cycle. 

It's not a good way to measure time on modern hardware because the processor can dynamically change own frequency (e.g. see [SpeedStep](https://en.wikipedia.org/wiki/SpeedStep)).

There is another problem: each processor core has own TSC, and these TSCs are not synchronized.
If a thread starts measurement on one core and ends on another core, the obtained result can't be reliable.
For example, there is a nice bug report on `support.microsoft.com` (see [Programs that use the QueryPerformanceCounter function may perform poorly](https://support.microsoft.com/en-us/kb/895980)):

```
C:\>ping x.x.x.x

Pinging x.x.x.x with 32 bytes of data:

Reply from x.x.x.x: bytes=32 time=-59ms TTL=128
Reply from x.x.x.x: bytes=32 time=-59ms TTL=128
Reply from x.x.x.x: bytes=32 time=-59ms TTL=128
Reply from x.x.x.x: bytes=32 time=-59ms TTL=128
```

The cause: 

> This problem occurs when the computer has the AMD Cool'n'Quiet technology (AMD dual cores) enabled in the BIOS or some Intel multi core processors. Multi core or multiprocessor systems may encounter Time Stamp Counter (TSC) drift when the time between different cores is not synchronized. The operating systems which use TSC as a timekeeping resource may experience the issue. 

If you want to use TSC on old hardware/software, you should probably set processor affinity for you thread (see [`SetThreadAffinityMask`](https://msdn.microsoft.com/library/windows/desktop/ms686247.aspx) for Windows, [`sched_setaffinity`](http://linux.die.net/man/2/sched_setaffinity) for Linux).

**Constant TSC**

`Constant TSC` is the next generation of TSC which solves the dynamic frequency problem: this kind of TSC increments at a constant rate. It's a good step forward, but `Constant TSC` still has some issues (e.g. it could be stopped when CPU run into deep C-state, see also [Power Management States: P-States, C-States, and Package C-States](https://software.intel.com/en-us/articles/power-management-states-p-states-c-states-and-package-c-states)). 

**Invariant TSC**

`Invariant TSC` is the latest version of the counter which works well.
From the manual:

> The invariant TSC will run at a constant rate in all ACPI P-, C-. and T-states. This is the architectural behavior moving forward. On processors with invariant TSC support, the OS may use the TSC for wall clock timer services (instead of ACPI or HPET timers).
 
You can check which kind of `TSC` do you have with the help of the [CPUID](https://en.wikipedia.org/wiki/CPUID) opcode.
For example, processors support for invariant TSC is indicated by `CPUID.80000007H:EDX[8]` (the manual, Vol. 2A 3-190, Table 3-17).

On Windows, you can also check it via the [Coreinfo](https://technet.microsoft.com/en-us/sysinternals/cc835722) utility:

```dos
> Coreinfo.exe | grep -i "tsc"
```

The output on my laptop:

```
Coreinfo v3.31 - Dump information on system CPU and memory topology
Copyright (C) 2008-2014 Mark Russinovich
Sysinternals - www.sysinternals.com
RDTSCP          *       Supports RDTSCP instruction
TSC             *       Supports RDTSC instruction
TSC-DEADLINE    *       Local APIC supports one-shot deadline timer
TSC-INVARIANT   *       TSC runs at constant rate
````

(You can read more about `TSC-DEADLINE` in the same manual, Vol. 3A 10-17, section 10.5.4.1)

You can do the same thing on Linux with the following command:

```
$ cat /proc/cpuinfo | tr ' ' '\n' | sort -u | grep -i "tsc"
```

Output on my laptop:

```
constant_tsc
nonstop_tsc
rdtscp
tsc
tsc_adjust
tsc_deadline_timer
```

`Invariant TSC` is specified by a combination of `constant_tsc` and `nonstop_tsc` flags.  

In the most cases, you can trust `Invariant TSC` and use it for high-precision measurements (however, there are still some problems, e.g. synchronization problems on large multi-processor systems).

**TSC and out-of-order execution**

There is another interesting fact which you should consider if you want to read the TSC value directly via the `RDTSC` instruction: processor can reorder your instruction and spoil your measurements.

From the manual, Vol. 3B 17-41, section 17.15:

> The RDTSC instruction is not serializing or ordered with other instructions. It does not necessarily wait until all previous instructions have been executed before reading the counter. Similarly, subsequent instructions may begin execution before the RDTSC instruction operation is performed.

From [Optimizing subroutines in assembly language](http://www.agner.org/optimize/optimizing_assembly.pdf) by Agner Fog (section 18.1):

> On all processors with out-of-order execution, you have to insert `XOR EAX,EAX`/`CPUID` before and after each read of the counter to prevent it from executing in parallel with anything else. `CPUID` is a serializing instruction, which means that it flushes the pipeline and waits for all pending operations to finish before proceeding. This is very useful for testing purposes.

So, we can't just call `RDTSC` and be sure that there is no out-of-order execution here.
How can we call it the right way?
Here is a C++ example by Agner Fog (see [Optimizing software in C++. An optimization guide for Windows, Linux and Mac platforms](http://www.agner.org/optimize/optimizing_cpp.pdf), section 16 "Testing speed"):

```cpp
// Example 16.1
#include <intrin.h>         // Or #include <ia32intrin.h> etc.
long long ReadTSC() {       // Returns time stamp counter
    int dummy[4];           // For unused returns
    volatile int DontSkip;  // Volatile to prevent optimizing
    long long clock;        // Time
    __cpuid(dummy, 0);      // Serialize
    DontSkip = dummy[0];    // Prevent optimizing away cpuid
    clock = __rdtsc();      // Read time
    return clock;
}
```

There is another interesting instruction: `RDTSCP`, it reads time stamp counter and processor ID (see the manual, Vol. 2B 4-547):

> Reads the current value of the processor’s time-stamp counter (a 64-bit `MSR`) into the `EDX:EAX` registers and also
  reads the value of the `IA32_TSC_AUX MSR` (address `C0000103H`) into the `ECX` register.
 
> The `RDTSCP` instruction **waits until all previous instructions have been executed before reading the counter**.

From the manual, Vol. 2B 4-545:

> If software requires RDTSC to be executed only after all previous instructions have completed locally, it can either use `RDTSCP` (if the processor supports that instruction) or execute the sequence `LFENCE`;`RDTSC`.

Thus, you can use `RDTSCP` instead of `RDTSC` (if your hardware supports this instruction) and not to be afraid of out-of-order execution.

**Latency and resolution**

Here is a list of reciprocal throughputs (CPU clock cycles) of `RDTSC` from [Instruction tables by Agner Fog](http://www.agner.org/optimize/instruction_tables.pdf) *(2016-01-09)* for different processors:

Processor Name                      | Reciprocal throughput
----------------------------------- |----------------------
AMD K7                              | 11
AMD K8                              | 7
AMD K10                             | 67
AMD Bulldozer                       | 42
AMD Pilediver                       | 42
AMD Steamroller                     | 78
AMD Bobcat                          | 87
AMD Jaguar                          | 41
Intel Pentium II/III                | 42
Intel Core 2 (Merom)                | 64
Intel Core 2 (Wolfdale)             | 32
Intel Nehalem                       | 24
Intel Sandy Bridge                  | 28
Intel Ivy Bridge                    | 27
Intel Haswell                       | 24
Intel Broadwell                     | 24
Intel Skylake                       | 25
Intel Pentium 4                     | 80
Intel Pentium 4 w. EM64T (Prescott) | 100
VIA Nano 2000 series                | 39
VIA Nano 3000 series                | 37

How can we interpret these numbers?
Let's say that we have Intel Haswell (our reciprocal throughput is `24`) with fixed CPU frequency = `2.2GHz`.
So, `1` CPU clock cycle is about `0.45ns` (it's our resolution).
We can say that single `RDTSC` invocation takes approximately `24 x 0.45ns ≈ 10.8ns` (for `RDTSC` we can assume that latency is approximate equals to reciprocal throughput).

You can also evaluate throughput of `RDTSC` on your machine. Download [`testp.zip`](www.agner.org/optimize/testp.zip) from the Anger Fog site, build it, and run `misc_int.sh1`.
Here are results on my laptop (Intel Haswell):
```
rdtsc Throughput

Processor 0
     Clock   Core cyc   Instruct       Uops     uop p0     uop p1     uop p2 
      1686       2384        100       1500        255        399          0 
      1686       2384        100       1500        255        399          0 
      1686       2384        100       1500        255        399          0 
      1686       2384        100       1500        254        399          0 
      1686       2384        100       1500        255        399          0 
      1686       2384        100       1500        255        399          0 
      1686       2384        100       1500        255        399          0 
      1686       2384        100       1500        254        399          0 
      1686       2384        100       1500        255        399          0 
      1686       2384        100       1500        255        399          0 
```

Here we have 2384 CPU cycles per 100 `RDTSC` instructions which mean approximately 24 cycles per instruction.

**Summary**

As we can see, TSC has a high resolution and low latency.
However, you don't want to use it in general because there are a lot of problems with TSC.
Here is a brief summary:

* Some old processors don't have TSC registers.
* The processor can change the frequency and affect the old version of TSC.
* There are synchronization problems on multi-core systems.
* Even if we have `Invariant TSC`, there are still synchronization problems on large multi-processor systems.
* Some processors can execute `RDTSC` out of order.

There is another detailed problems summary in MSDN: [Acquiring high-resolution time stamps, "TSC Register" section](https://msdn.microsoft.com/library/windows/desktop/dn553408.aspx#AppendixB). Also, you can find a nice problems overview in this article: [Pitfalls of TSC usage](http://oliveryang.net/2015/09/pitfalls-of-TSC-usage/).

Thus, TSC is not a good choice for time measurements in general case because you can't be sure in advance that it produces reliable measurements.
Fortunately, modern operation systems provide nice API which allows getting the most reliable timestamps for current hardware.

---

#### ACPI PM and HPET

**ACPI PM**

*ACPI* is Advanced Configuration and Power Interface. It defines a power management timer that provides accurate time values. By [specification](http://www.uefi.org/sites/default/files/resources/ACPI_6.0.pdf) (*v6.0, April 2015*), frequency of the Power Management Timer should be `3.579545 MHz` (see section *4.8.2.1*):

> The power management timer is a 24-bit or 32-bit fixed rate free running count-up timer that runs off a `3.579545 MHz` clock. The ACPI OS checks the `FADT` to determine whether the PM Timer is a 32-bit or 24-bit timer. The programming model for the PM Timer consists of event logic and a read port to the counter value. The event logic consists of an event status and enables bit. The status bit is set any time the last bit of the timer (bit 23 or bit 31) goes from set to clear or clear to set. If the `TMR_EN` bit is set, then the setting of the `TMR_STS` will generate an ACPI event in the `PM1_EVT` register grouping (referred to as `PMTMR_PME` in the diagram). The event logic is only used to emulate a larger timer.

But why do we have exactly `3.579545 MHz` (which equals to `5×7×9/(8×11) MHz`)?
Historically, this number comes from The National Television System Committee ([NTSC](https://en.wikipedia.org/wiki/NTSC)),
  here is [a nice explanation](https://en.wikipedia.org/wiki/NTSC#History) from Wikipedia: 

> In January 1950, the Committee was reconstituted to standardize color television. In December 1953, it unanimously approved what is now called the NTSC color television standard (later defined as RS-170a). The "compatible color" standard retained full backward compatibility with existing black-and-white television sets. Color information was added to the black-and-white image by introducing a color subcarrier of precisely `3.579545 MHz` (nominally `3.58 MHz`). The precise frequency was chosen so that horizontal line-rate modulation components of the chrominance signal would fall exactly in between the horizontal line-rate modulation components of the luminance signal, thereby enabling the chrominance signal to be filtered out of the luminance signal with minor degradation of the luminance signal. Due to limitations of frequency divider circuits at the time the color standard was promulgated, the color subcarrier frequency was constructed as composite frequency assembled from small integers, in this case, 5×7×9/(8×11) MHz. The horizontal line rate was reduced to approximately 15,734 lines per second (`3.579545×2/455 MHz`) from 15,750 lines per second, and the frame rate was reduced to approximately 29.970 frames per second (the horizontal line rate divided by 525 lines/frame) from 30 frames per second. These changes amounted to 0.1 percent and were readily tolerated by existing television receivers.

**HPET**

From [Wikipedia](https://en.wikipedia.org/wiki/High_Precision_Event_Timer):

> The High Precision Event Timer (HPET) is a hardware timer used in personal computers. It was developed jointly by AMD and Microsoft and has been incorporated in PC chipsets since circa 2005. 

According to ([IA-PC HPET Specification Rev 1.0a](http://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/software-developers-hpet-spec-1-0a.pdf), section 2.2), minimum HPET clock frequency is `10 MHz`.
However, default HPET frequency is `14.31818 MHz` or 4x the ACPI clock
  (it allows to use the same crystal oscillator in HPET and ACPI PM, see also [wiki/Colorburst#Crystals](https://en.wikipedia.org/wiki/Colorburst#Crystals)).

On Windows you can enable or disable HPET with the help of the following commands:

```bash
:: Enable HPET (reboot is required): 
bcdedit /set useplatformclock true
:: Disable HPET (reboot is required):
bcdedit /deletevalue useplatformclock
:: View all Windows Boot Manager/Loader values:
bcdedit /enum
```

There are some useful commands on Linux:

```bash
# Get available clocksource:
$ cat /sys/devices/system/clocksource/clocksource0/available_clocksource
tsc hpet acpi_pm 

# Get current clocksource:
$ cat /sys/devices/system/clocksource/clocksource0/current_clocksource 
tsc

# Set current clocksource:
$ sudo /bin/sh -c 'echo hpet > /sys/devices/system/clocksource/clocksource0/current_clocksource'
```

Usually, HPET is disabled by default on modern hardware because of large latency (see the [Benchmarks](#benchmarks) section).

---

### Operation Systems

#### Windows

The best article about time stamps on Windows is [Acquiring high-resolution time stamps](https://msdn.microsoft.com/library/windows/desktop/dn553408.aspx).
Brief summary:

On Windows, the primary API for high-resolution time stamps is [QueryPerformanceCounter (QPC)](https://msdn.microsoft.com/library/windows/desktop/ms644904.aspx).
For device drivers, the kernel-mode API is [KeQueryPerformanceCounter](https://msdn.microsoft.com/library/windows/desktop/ff553053.aspx).
If you need high-resolution time-of-day measurements, use [GetSystemTimePreciseAsFileTime](https://msdn.microsoft.com/library/windows/desktop/hh706895.aspx) (available since Windows 8 / Windows Server 2012).

`QPC` is completely independent of the system time and UTC (it is not affected by daylight savings time, leap seconds, time zones).
It is also not affected by processor frequency changes.
Thus, it is th best option, if you want to measure duration of an operation. If you want to know high-precision DateTime, use `GetSystemTimePreciseAsFileTime`.

* QPC is available on *Windows XP and Windows 2000* and works well on most systems. However, some hardware systems BIOS did not indicate the hardware CPU characteristics correctly (a non-invariant TSC), and some multi-core or multi-processor systems used processors with TSCs that could not be synchronized across cores. Systems with flawed firmware that run these versions of Windows might not provide the same QPC reading on different cores if they used the TSC as the basis for QPC.
* All computers that shipped with *Windows Vista and Windows Server 2008* used the HPET or the ACPI PM as the basis for QPC.
* The majority of *Windows 7 and Windows Server 2008 R2* computers have processors with constant-rate TSCs and use these counters as the basis for QPC.
* *Windows 8, Windows 8.1, Windows Server 2012, and Windows Server 2012 R2* use TSCs as the basis for the performance counter.

There are two main functions for high-resolution time stamps in `kernel32.dll`:

```cs
[DllImport("kernel32.dll")]
private static extern bool QueryPerformanceCounter(out long value);

[DllImport("kernel32.dll")]
private static extern bool QueryPerformanceFrequency(out long value);
```


Thus, we can get tick counter via `QueryPerformanceCounter`.
But how does it work?
Let's write a simple program:

```cs
static void Main(string[] args)
{
    long ticks;
    QueryPerformanceCounter(out ticks);
}

[DllImport("kernel32.dll")]
private static extern bool QueryPerformanceCounter(out long value);
```

build it (Release-x64) and open the executable in WinDbg.
There is a difference between x86 and x64 asm code, but x64 asm code will be enough to understand what's going on.
Let's go to to the `KERNEL32!QueryPerformanceCounter` (we even don't need `sos.dll` here):

```
> bp KERNEL32!QueryPerformanceCounter
> g
```
```x86asm
KERNEL32!QueryPerformanceCounter:
00007ffe6ccbb720  jmp     qword ptr [KERNEL32!QuirkIsEnabled2Worker+0x9ec8 (00007ffe6cd16378)] 
                                    ds:00007ffe6cd16378={ntdll!RtlQueryPerformanceCounter (00007ffe6d83a7b0)}
```

If you are not able to set a breakpoint to `KERNEL32!QueryPerformanceCounter`, you can try to use `KERNEL32!QueryPerformanceCounterStub`
  (I have observed both situations on Windows 10):

```
> bp KERNEL32!QueryPerformanceCounterStub
> g
```
```x86asm
KERNEL32!QueryPerformanceCounterStub:
00007fff431f5750 jmp      qword ptr [KERNEL32!_imp_QueryPerformanceCounter (00007fff`43255290)]
                                    ds:00007fff43255290={ntdll!RtlQueryPerformanceCounter (00007fff`45300ff0)}
```

`KERNEL32!QueryPerformanceCounter` (or `KERNEL32!QueryPerformanceCounterStub`) just redirects us to `ntdll!RtlQueryPerformanceCounter`.
Let's look at the disassembly of this method:

```
> uf ntdll!RtlQueryPerformanceCounter
```
```x86asm
ntdll!RtlQueryPerformanceCounter:
00007ffe6d83a7b0  push    rbx
00007ffe6d83a7b2  sub     rsp,20h
00007ffe6d83a7b6  mov     al,byte ptr [SharedUserData+0x3c6 (000000007ffe03c6)]
00007ffe6d83a7bd  mov     rbx,rcx
00007ffe6d83a7c0  cmp     al,1
00007ffe6d83a7c2  jne     ntdll!RtlQueryPerformanceCounter+0x44 (00007ffe6d83a7f4)

ntdll!RtlQueryPerformanceCounter+0x14:
00007ffe6d83a7c4  mov     rcx,qword ptr [SharedUserData+0x3b8 (000000007ffe03b8)]
00007ffe6d83a7cc  rdtsc
00007ffe6d83a7ce  shl     rdx,20h
00007ffe6d83a7d2  or      rax,rdx
00007ffe6d83a7d5  mov     qword ptr [rbx],rax
00007ffe6d83a7d8  lea     rdx,[rax+rcx]
00007ffe6d83a7dc  mov     cl,byte ptr [SharedUserData+0x3c7 (000000007ffe03c7)]
00007ffe6d83a7e3  shr     rdx,cl
00007ffe6d83a7e6  mov     qword ptr [rbx],rdx

ntdll!RtlQueryPerformanceCounter+0x39:
00007ffe6d83a7e9  mov     eax,1
00007ffe6d83a7ee  add     rsp,20h
00007ffe6d83a7f2  pop     rbx
00007ffe6d83a7f3  ret

ntdll!RtlQueryPerformanceCounter+0x44:
00007ffe6d83a7f4  lea     rdx,[rsp+40h]
00007ffe6d83a7f9  lea     rcx,[rsp+38h]
00007ffe6d83a7fe  call    ntdll!NtQueryPerformanceCounter (00007ffe6d8956f0)
00007ffe6d83a803  mov     rax,qword ptr [rsp+38h]
00007ffe6d83a808  mov     qword ptr [rbx],rax
00007ffe6d83a80b  jmp     ntdll!RtlQueryPerformanceCounter+0x39 (00007ffe6d83a7e9)
```

I will try to explain the situation in simple terms.
There is a special flag in `[SharedUserData+0x3c6 (000000007ffe03c6)]` that determines which QPC algorithm we will use.
If everything is fine (we are working on modern hardware with invariant TSC and we can directly use it), we are going to the fast algorithm (`ntdll!RtlQueryPerformanceCounter+0x14`). Otherwise, we are going to call `ntdll!NtQueryPerformanceCounter` which produces a `syscall`:

```
> uf ntdll!NtQueryPerformanceCounter
```
```
ntdll!NtQueryPerformanceCounter:
00007ffe6d8956f0  mov     r10,rcx
00007ffe6d8956f3  mov     eax,31h
00007ffe6d8956f8  test    byte ptr [SharedUserData+0x308 (000000007ffe0308)],1
00007ffe6d895700  jne     ntdll!NtQueryPerformanceCounter+0x15 (00007ffe6d895705)

ntdll!NtQueryPerformanceCounter+0x12:
00007ffe6d895702  syscall
00007ffe6d895704  ret

ntdll!NtQueryPerformanceCounter+0x15:
00007ffe6d895705  int     2Eh
00007ffe6d895707  ret
```

An important fact about the fast algorithm (`ntdll!RtlQueryPerformanceCounter+0x14`): it directly calls `rdtsc` without any syscalls. It allows achieving low latency for simple situations (when we really can use TSC without any troubles).

Another interesting fact: `QPC` use shifted value of `rdtsc`: after it puts full value of the counter in `rdx`, it performs `shr rdx,cl` (where `cl` typically equals to `0xA`).
Thus, one `QPC` tick is 1024 `rdtsc` ticks.
We can say the same thing about `QPF`: nominal Windows frequency for high-precision measurements is 1024 times less than `rdtsc` frequency.

---

#### Linux

On Linux, there are many different time functions:
  [`time()`](http://linux.die.net/man/2/time),
  [`clock()`](http://linux.die.net/man/3/clock),
  [`clock_gettime()`](http://linux.die.net/man/3/clock_gettime),
  [`getrusage()`](http://linux.die.net/man/2/getrusage),
  [`gettimeofday()`](http://linux.die.net/man/2/gettimeofday),
  [`mach_absolute_time()`](https://developer.apple.com/library/mac/#qa/qa1398/_index.html)
  (you can find a nice overview [here](http://stackoverflow.com/a/12480485/184842)).
Both CoreCLR and Mono uses `clock_getttime` as a primary way (with fallbacks to `mach_absolute_time` and `gettimeofday`) because it's the best way to get high-precision time stamp. This function has the following signature:

```cpp
int clock_gettime(clockid_t clk_id, struct timespec *tp);
```

Here `clockid_t` is ID of the target clock. For high precision timestamping, we should use `CLOCK_MONOTONIC` (if this option is available on current hardware) but there are other clock option (like `CLOCK_REALTIME` for real-time clock or `CLOCK_THREAD_CPUTIME_ID` for thread-specific CPU-time clock). The target timestamp will be returned as a `timespec`:

```
struct timespec {
    time_t tv_sec; /* seconds */
    long tv_nsec;  /* nanoseconds */ };
```

A usage example:

```cpp
struct timespec ts;
uint64_t timestamp;
clock_gettime(CLOCK_MONOTONIC, &ts);
timestamp = (static_cast<uint64_t>(ts.tv_sec) * 1000000000) + static_cast<uint64_t>(ts.tv_nsec);
```

Thus, minimal possible resolution of `clock_gettime` is `1 ns`. Internally, `clock_gettime(CLOCK_MONOTONIC, ...)` is based on the current high precision hardware timer (usually `TSC`, but it can also be `HPET` or `ACPI_PM`).

To reduce `clock_gettime` latency, Linux kernel uses the `vsyscalls` (virtual system calls) and `VDSOs` (Virtual Dynamically linked Shared Objects) instead of direct `syscall` (you can find some useful implementation details [here](http://linuxmogeb.blogspot.co.il/2013/10/how-does-clockgettime-work.html) and [here](https://lwn.net/Articles/615809/)).

If `Invariant TSC` is available, `clock_gettime(CLOCK_MONOTONIC, ...)` will use it directly via the `rdtsc` instruction.
Of course, it adds some overhead, but in general case, you should use `clock_gettime` instead of `rdtsc` because it solves a lot of portability problems.
For example, see this nice commit: [x86: tsc prevent time going backward](https://github.com/torvalds/linux/commit/d8bb6f4c1670c8324e4135c61ef07486f7f17379).

---

### Source code

#### Full .NET Framework

Stopwatch on the Full .NET Framework simply uses QPC/QPF, let's look at the source code.

[`Stopwatch.cs`](http://referencesource.microsoft.com/#System/services/monitoring/system/diagnosticts/Stopwatch.cs,28)
```cs
public class Stopwatch
{
    private const long TicksPerMillisecond = 10000;
    private const long TicksPerSecond = TicksPerMillisecond * 1000;

    // "Frequency" stores the frequency of the high-resolution performance counter, 
    // if one exists. Otherwise it will store TicksPerSecond. 
    // The frequency cannot change while the system is running,
    // so we only need to initialize it once. 
    public static readonly long Frequency;
    public static readonly bool IsHighResolution;

    // performance-counter frequency, in counts per ticks.
    // This can speed up conversion from high frequency performance-counter 
    // to ticks. 
    private static readonly double tickFrequency;

    static Stopwatch()
    {
        bool succeeded = SafeNativeMethods.QueryPerformanceFrequency(out Frequency);
        if (!succeeded)
        {
            IsHighResolution = false;
            Frequency = TicksPerSecond;
            tickFrequency = 1;
        }
        else
        {
            IsHighResolution = true;
            tickFrequency = TicksPerSecond;
            tickFrequency /= Frequency;
        }
    }

    public static long GetTimestamp()
    {
        if (IsHighResolution)
        {
            long timestamp = 0;
            SafeNativeMethods.QueryPerformanceCounter(out timestamp);
            return timestamp;
        }
        else
        {
            return DateTime.UtcNow.Ticks;
        }
    }
}
```
<br />

[`SafeNativeMethods.cs`](http://referencesource.microsoft.com/#System/compmod/microsoft/win32/SafeNativeMethods.cs,122)
```cs
[DllImport(ExternDll.Kernel32)]
[ResourceExposure(ResourceScope.None)]
public static extern bool QueryPerformanceCounter(out long value);

[DllImport(ExternDll.Kernel32)]
[ResourceExposure(ResourceScope.None)]
public static extern bool QueryPerformanceFrequency(out long value);
```

What do you think, is it possible to get a negative elapsed time interval using Stopwatch?
There was a bug until .NET 3.5 because of which you can observe such situation.
The bug was fixed in .NET 4.0 (originally with `#if NET_4_0`..`#endif`; without these directives since .NET 4.5).
[Here is](https://github.com/dotnet/corefx/blob/v1.0.0/src/System.Runtime.Extensions/src/System/Diagnostics/Stopwatch.cs#L82) a comment with explanation:
```cs
if (_elapsed < 0)
{
    // When measuring small time periods the StopWatch.Elapsed* 
    // properties can return negative values.  This is due to 
    // bugs in the basic input/output system (BIOS) or the hardware
    // abstraction layer (HAL) on machines with variable-speed CPUs
    // (e.g. Intel SpeedStep).

    _elapsed = 0;
}
```

---

#### CoreCLR

Basically, CoreCLR 1.0.0 contains almost the same [Stopwatch.cs](https://github.com/dotnet/corefx/blob/v1.0.0/src/System.Runtime.Extensions/src/System/Diagnostics/Stopwatch.cs) as in a case of the Full .NET Framework except for some minor changes in private variable names, `SecuritySafeCritical` attribute usages, and `FEATURE_NETCORE` depended on code.
The main difference is the following: CoreCLR uses another declaration of QPC and QPF methods depend on the target platform (instead of using fixed `SafeNativeMethods.cs` implementation).

**Windows**

[`Stopwatch.Windows.cs`](https://github.com/dotnet/corefx/blob/v1.0.0/src/System.Runtime.Extensions/src/System/Diagnostics/Stopwatch.Windows.cs)
```cs
public partial class Stopwatch
{
    private static bool QueryPerformanceFrequency(out long value)
    {
        return Interop.mincore.QueryPerformanceFrequency(out value);
    }

    private static bool QueryPerformanceCounter(out long value)
    {
        return Interop.mincore.QueryPerformanceCounter(out value);
    }
}
```
<br />

[`Interop/Windows/mincore/Interop.QueryPerformanceCounter.cs`](https://github.com/dotnet/corefx/blob/v1.0.0/src/Common/src/Interop/Windows/mincore/Interop.QueryPerformanceCounter.cs)
```cs
internal partial class mincore
{
    [DllImport(Libraries.Profile)]
    internal static extern bool QueryPerformanceCounter(out long value);
}
```
<br />

[`Interop/Windows/mincore/Interop.QueryPerformanceFrequency.cs`](https://github.com/dotnet/corefx/blob/v1.0.0/src/Common/src/Interop/Windows/mincore/Interop.QueryPerformanceFrequency.cs)
```cs
internal partial class mincore
{
    [DllImport(Libraries.Profile)]
    internal static extern bool QueryPerformanceFrequency(out long value);
}
```

Thus, on Windows, we just call usual QPC/QPF API.

**Unix**

[`Stopwatch.Unix.cs`](https://github.com/dotnet/corefx/blob/v1.0.0/src/System.Runtime.Extensions/src/System/Diagnostics/Stopwatch.Unix.cs)
```cs
public partial class Stopwatch
{
    private static bool QueryPerformanceFrequency(out long value)
    {
        return Interop.Sys.GetTimestampResolution(out value);
    }

    private static bool QueryPerformanceCounter(out long value)
    {
        return Interop.Sys.GetTimestamp(out value);
    }
}
```
<br />

[`Interop/Unix/System.Native/Interop.GetTimestamp.cs`](https://github.com/dotnet/corefx/blob/v1.0.0/src/Common/src/Interop/Unix/System.Native/Interop.GetTimestamp.cs)
```cs
internal static partial class Sys
{
    [DllImport(Libraries.SystemNative, EntryPoint = "SystemNative_GetTimestampResolution")]
    internal static extern bool GetTimestampResolution(out long resolution);

    [DllImport(Libraries.SystemNative, EntryPoint = "SystemNative_GetTimestamp")]
    internal static extern bool GetTimestamp(out long timestamp);
}
```
<br />

[`Native/System.Native/pal_time.cpp`](https://github.com/dotnet/corefx/blob/v1.0.0/src/Native/System.Native/pal_time.cpp)
```cpp
extern "C" int32_t SystemNative_GetTimestampResolution(uint64_t* resolution)
{
    assert(resolution);

#if HAVE_CLOCK_MONOTONIC
    // Make sure we can call clock_gettime with MONOTONIC.  Stopwatch invokes
    // GetTimestampResolution as the very first thing, and by calling this here
    // to verify we can successfully, we don't have to branch in GetTimestamp.
    struct timespec ts;
    if (clock_gettime(CLOCK_MONOTONIC, &ts) == 0) 
    {
        *resolution = SecondsToNanoSeconds;
        return 1;
    }
    else
    {
        *resolution = 0;
        return 0;
    }

#elif HAVE_MACH_ABSOLUTE_TIME
    mach_timebase_info_data_t mtid;
    if (mach_timebase_info(&mtid) == KERN_SUCCESS)
    {
        *resolution = SecondsToNanoSeconds * (static_cast<uint64_t>(mtid.denom) / static_cast<uint64_t>(mtid.numer));
        return 1;
    }
    else
    {
        *resolution = 0;
        return 0;
    }

#else /* gettimeofday */
    *resolution = SecondsToMicroSeconds;
    return 1;

#endif
}
```

```cpp
extern "C" int32_t SystemNative_GetTimestamp(uint64_t* timestamp)
{
    assert(timestamp);

#if HAVE_CLOCK_MONOTONIC
    struct timespec ts;
    int result = clock_gettime(CLOCK_MONOTONIC, &ts);
    assert(result == 0); // only possible errors are if MONOTONIC isn't supported or &ts is an invalid address
    (void)result; // suppress unused parameter warning in release builds
    *timestamp = (static_cast<uint64_t>(ts.tv_sec) * SecondsToNanoSeconds) + static_cast<uint64_t>(ts.tv_nsec);
    return 1;

#elif HAVE_MACH_ABSOLUTE_TIME
    *timestamp = mach_absolute_time();
    return 1;

#else
    struct timeval tv;
    if (gettimeofday(&tv, NULL) == 0)
    {
        *timestamp = (static_cast<uint64_t>(tv.tv_sec) * SecondsToMicroSeconds) + static_cast<uint64_t>(tv.tv_usec);
        return 1;
    }
    else
    {
        *timestamp = 0;
        return 0;
    }

#endif
}
```

As you can see, primarily we are trying to use `clock_gettime` (in the `HAVE_CLOCK_MONOTONIC` mode),
  otherwise we are trying to use `mach_absolute_time` (in the `HAVE_MACH_ABSOLUTE_TIME` mode), otherwise we are using `gettimeofday` (with corresponded conversions).

---

#### Mono

Let's look at an implementation of `Stopwatch` in Mono (we will work with `mono-4.4.2.11` in this post).

[`Stopwatch.cs`](https://github.com/mono/mono/blob/mono-4.4.2.11/mcs/class/System/System.Diagnostics/Stopwatch.cs)
```cs
public class Stopwatch
{
    [MethodImplAttribute(MethodImplOptions.InternalCall)]
    public static extern long GetTimestamp();

    public static readonly long Frequency = 10000000;

    public static readonly bool IsHighResolution = true;
}
```

As you can see, the frequency of `Stopwatch` in Mono is a const (10'000'000).
For some historical reasons, this `Stopwatch` uses the same tick value (`100ns`) as the `DateTime`.

Now let's look at the internal implementation.

[`icall-def.h`](https://github.com/mono/mono/blob/mono-4.4.2.11/mono/metadata/icall-def.h#L218)
```cpp
ICALL_TYPE(STOPWATCH, "System.Diagnostics.Stopwatch", STOPWATCH_1)
ICALL(STOPWATCH_1, "GetTimestamp", mono_100ns_ticks)
```
<br />

[`mono-time.c#L30`](https://github.com/mono/mono/blob/mono-4.4.2.11/mono/utils/mono-time.c#L30)
```cpp
/* Returns the number of 100ns ticks from unspecified time: this should be monotonic */
gint64
mono_100ns_ticks (void)
{
    static LARGE_INTEGER freq;
    static UINT64 start_time;
    UINT64 cur_time;
    LARGE_INTEGER value;

    if (!freq.QuadPart) {
        if (!QueryPerformanceFrequency (&freq))
            return mono_100ns_datetime ();
        QueryPerformanceCounter (&value);
        start_time = value.QuadPart;
    }
    QueryPerformanceCounter (&value);
    cur_time = value.QuadPart;
    /* we use unsigned numbers and return the difference to avoid overflows */
    return (cur_time - start_time) * (double)MTICKS_PER_SEC / freq.QuadPart;
}
```
<br />

[`mono-time.c#L128`](https://github.com/mono/mono/blob/mono-4.4.2.11/mono/utils/mono-time.c#L128)
```cpp
/* Returns the number of 100ns ticks from unspecified time: this should be monotonic */
gint64
mono_100ns_ticks (void)
{
    struct timeval tv;
#ifdef CLOCK_MONOTONIC
    struct timespec tspec;
    static struct timespec tspec_freq = {0};
    static int can_use_clock = 0;
    if (!tspec_freq.tv_nsec) {
        can_use_clock = clock_getres (CLOCK_MONOTONIC, &tspec_freq) == 0;
        /*printf ("resolution: %lu.%lu\n", tspec_freq.tv_sec, tspec_freq.tv_nsec);*/
    }
    if (can_use_clock) {
        if (clock_gettime (CLOCK_MONOTONIC, &tspec) == 0) {
            /*printf ("time: %lu.%lu\n", tspec.tv_sec, tspec.tv_nsec); */
            return ((gint64)tspec.tv_sec * MTICKS_PER_SEC + tspec.tv_nsec / 100);
        }
    }
    
#elif defined(PLATFORM_MACOSX)
    /* http://developer.apple.com/library/mac/#qa/qa1398/_index.html */
    static mach_timebase_info_data_t timebase;
    guint64 now = mach_absolute_time ();
    if (timebase.denom == 0) {
        mach_timebase_info (&timebase);
        timebase.denom *= 100; /* we return 100ns ticks */
    }
    return now * timebase.numer / timebase.denom;
#endif
    if (gettimeofday (&tv, NULL) == 0)
        return ((gint64)tv.tv_sec * 1000000 + tv.tv_usec) * 10;
    return 0;
}
```

As you can see, the algorithms Mono internally uses the same API as API in CoreCLR:
  `QPC`/`clock_gettime` as a primary way,
  `mono_100ns_datetime`/`gettimeofday` as a fallback case.
   
Is it possible to get a negative elapsed interval on Mono?
It's theoretically possible on the old version on Mono and old hardware.
This bug was [fixed](https://github.com/mono/mono/commit/dbc021772a8c0a8bf97615523c73d55cf9b376c3) by me and [merged](https://github.com/mono/mono/commit/226af94a2345f88d3170823646e1c25a276ba281) into the master (Sep 23, 2015).

---

### Pitfalls

#### Small time intervals

When you are trying to measure time of an operation, it's really important to understand order of this measurement and order of `Stopwatch` resolution and latency
  (it will be covered in details in the [Benchmarks](#benchmarks) section).
If your operations take 1 second and you both latency and resolution are less than `1 μs`, everything is fine.
But if you are trying to measure an operation which takes `10 ns` and `Stopwatch` Resolution is about `300-400ns`, you will have some problems.
Of course, you can repeat the target operation several times, but there are still many microbenchmark problems (which [BenchmarkDotNet](https://github.com/PerfDotNet/BenchmarkDotNet) trying to solve).
Be careful in such situations; it's really easy to make wrong measurements of short operations.

#### Sequential reads

Let's say that we do two sequential reads of `Stopwatch.GetTimestamp()`:

```cs
var a = Stopwatch.GetTimestamp();
var b = Stopwatch.GetTimestamp();
var delta = b - a;
```

Can you say possible values of `delta`? Let's check it with help of the following program:

```cs
const int N = 1000000;
var values = new long[N];
for (int i = 0; i < N; i++)
    values[i] = Stopwatch.GetTimestamp();
var deltas = new long[N - 1];
for (int i = 0; i < N - 1; i++)
    deltas[i] = values[i + 1] - values[i];
var table =
    from d in deltas
    group d by d into g
    orderby g.Key
    select new
    {
        Ticks = g.Key,
        Microseconds = g.Key * 1000000.0 / Stopwatch.Frequency,
        Count = g.Count()
    };
Console.WriteLine("Ticks | Time(μs) | Count   ");
Console.WriteLine("------|----------|---------");
foreach (var line in table)
{
    var ticks = line.Ticks.ToString().PadRight(5);
    var us = line.Microseconds.ToString("0.0").PadRight(8);
    var count = line.Count.ToString();
    Console.WriteLine($"{ticks} | {μs} | {count}");
}
```

Here is a typical output on my laptop:

```
Ticks | Time(μs) | Count
------|----------|---------
0     | 0.0      | 931768
1     | 0.4      | 66462
2     | 0.7      | 1155
3     | 1.1      | 319
4     | 1.5      | 59
5     | 1.8      | 21
6     | 2.2      | 46
7     | 2.6      | 39
8     | 2.9      | 31
9     | 3.3      | 10
10    | 3.7      | 6
11    | 4.0      | 3
13    | 4.8      | 2
15    | 5.5      | 3
16    | 5.9      | 1
18    | 6.6      | 1
19    | 7.0      | 2
20    | 7.3      | 1
22    | 8.1      | 1
23    | 8.4      | 4
24    | 8.8      | 8
25    | 9.2      | 12
27    | 9.9      | 13
28    | 10.3     | 10
30    | 11.0     | 6
31    | 11.4     | 1
34    | 12.5     | 4
35    | 12.8     | 1
36    | 13.2     | 1
44    | 16.1     | 1
47    | 17.2     | 1
56    | 20.5     | 1
66    | 24.2     | 1
68    | 24.9     | 1
71    | 26.0     | 1
123   | 45.1     | 1
314   | 115.1    | 1
2412  | 884.1    | 1
```

As you can see, once I had a delta between two sequential `GetTimestamp` which equals to `2412 ticks` or `0.8ms` (my current `Stopwatch.Frequency = 2728068`)! This fact is not obvious for most developers. There are two popular kinds of mistakes here.

* **Handwritten benchmarks.** Here is a popular pattern for time measurements:

```cs
var sw = Stopwatch.StartNew();
// Target method
sw.Stop();
var time = sw.Elapsed;
```

This code usually works fine for target method that takes seconds and works awfully for method that takes milliseconds. Let's write another check program:
 
```cs
var maxTime = 0.0;
for (int i = 0; i < 10000000; i++)
{
    var sw = Stopwatch.StartNew();
    sw.Stop();
    maxTime = Math.Max(maxTime, sw.Elapsed.TotalMilliseconds);
}
Console.WriteLine(maxTime + " ms");
```

Usually, I get `maxTime` is about `1ms` but sometimes it equals to `6–7ms`.
But we even don't have any target method here; we are trying to measure nothing!
Of course, it is a rare situation. Usually, you get plausible measurements.
But you can never be sure!
Besides, it is methodologically wrong.
Please, don't write such benchmarks.

* **Two GetTimestamp in an expression.**

Can you say where is a bug in the following expression? 

```cs
  stopwatch.ElapsedMilliseconds > timeout ? 0 : timeout - (int)stopwatch.ElapsedMilliseconds
```

The answer: we can't be sure that two invocations of `stopwatch.ElapsedMilliseconds` will return the same value.
For example, let's say that `timeout` equals to `100`.
We are trying to evaluate `stopwatch.ElapsedMilliseconds > timeout`, `stopwatch.ElapsedMilliseconds` returns `99`, the expression value is `false`.
Next, we are going to evaluate `timeout - (int)stopwatch.ElapsedMilliseconds`.
But we have another `stopwatch.ElapsedMilliseconds` here!
Let's say, it returns `101`.
Then, result value will be equal to `-1`!
Probably, the author of this code did not expect negative values here.
 
You can say that nobody writes such code.
Or that such code never is a cause of a bug in the real application.
But it can.
This expression was taken from the [AsyncIO](https://github.com/somdoron/AsyncIO) library (this code was already [fixed](https://github.com/somdoron/AsyncIO/commit/5c838f3d30d483dcadb4181233a4437fb5e7f327)).
Once I really had a bug because this value was negative!
By the way, such kind of bugs is *really* hard to reproduce.
So, just don't write code like this.


#### Reciprocal frequency and actual resolution

A lot of developers think that these values are equal.
But they can be not equal in the general case.
In fact, we have only one guarantee here: actual resolution ≥ reciprocal frequency because we can't achieve resolution better than one tick.
However, there are a lot of cases when one tick defined by `Stopwatch.Frequency` does not correspond to actual resolution (for example, on Mono or on Hypervisors).
But what if we really want to know the actual resolution?
Unfortunately, there is no API for that.
But we can calculate an approximation of this value.
For example, if we take the table from the [Sequential reads](#sequential-reads) section and remove the first line (where `ticks=0`), we get an observable resolution distribution for an interval of time.
We can calculate a minimal observable resolution and average/median observable resolution.
But be careful: keep in mind that it's just *observable* values for a single series of measurements.
You can get a new distribution per each run.
You can not trust these values, but sometimes you can use them for some resolution approximation (may be useful in some applications).

---

### Benchmarks

Let's write the following benchmark with the help of [BenchmarkDotNet](https://github.com/PerfDotNet/BenchmarkDotNet):

```cs
[ClrJob, CoreJob, MonoJob]
public class StopwatchBenchmarks
{
    [Benchmark]
    public long Latency() => Stopwatch.GetTimestamp();

    [Benchmark]
    public long Resolution()
    {
        long lastTimestamp = Stopwatch.GetTimestamp();
        while (Stopwatch.GetTimestamp() == lastTimestamp)
        {
        }
        return lastTimestamp;
    }
}
```

Be careful: the `Resolution` methods does not produce correct value of Resolution when Latency is much bigger than actual resolution (see the Interpretation subsection).
We will omit results for such situations.

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

**TSC:**

|     Method | Runtime |      Median |    StdDev |
|----------- |-------- |------------:|----------:|
|    Latency |     Clr |  17.1918 ns | 0.2723 ns |
| Resolution |     Clr | 475.1302 ns | 7.4886 ns |
|    Latency |    Core |  15.6241 ns | 0.3809 ns |
| Resolution |    Core | 467.9744 ns | 7.1308 ns |
|    Latency |    Mono |  40.4701 ns | 0.5814 ns |
| Resolution |    Mono | 475.2795 ns | 4.4417 ns |


**HPET:**

|     Method | Runtime |        Median |     StdDev |
|----------- |-------- |--------------:|-----------:|
|    Latency |     Clr |   598.5198 ns | 78.7814 ns |
|    Latency |    Core |   603.3178 ns | 18.0963 ns |
|    Latency |    Mono |   737.9618 ns |  4.5637 ns |

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

**TSC:**

|     Method | Runtime |     Median |    StdDev |
|----------- |-------- |-----------:|----------:|
|    Latency |    Core | 31.9727 ns | 1.8880 ns |
|    Latency |    Mono | 22.4036 ns | 1.3299 ns |
| Resolution |    Mono | 97.6713 ns | 0.0971 ns |


**ACPI_PM:**

|     Method | Runtime |        Median |     StdDev |
|----------- |-------- |--------------:|-----------:|
|    Latency |    Core |   683.2088 ns | 16.5555 ns |
|    Latency |    Mono |   653.4289 ns |  1.5812 ns |

**HPET:**

|     Method | Runtime |        Median |     StdDev |
|----------- |-------- |--------------:|-----------:|
|    Latency |    Core |   536.0179 ns |  7.4501 ns |
|    Latency |    Mono |   526.4265 ns |  1.8113 ns |

#### Interpretation

Ok, we got a lot of interesting numbers, but we should interpret it in the right way.
The latency benchmark looks great; it produced a nice approximation of real timestamp latency.

But there are some troubles with the resolution benchmark because it's hard to design correct microbenchmark in this situation.

It works well only for cases where Latency is much smaller than resolution: for example, it produces believable numbers for Windows+TSC.
In this case we get `Resolution` ≈ (`1 second` / `Stopwatch.Frequency`) ≈ (`1 second` / (`rdstc Frequency` / 1024)).

In the case of `HPET`/`ACPI_PM` benchmarks show that `Resolution` ≈ 2 x `Latency` because we call `Stopwatch.GetTimestamp` at least twice per the `Resolution` method invocation.
It's hard to say something about real resolution because the value of `HPET`/`ACPI_PM` ticks is much smaller than the latency.
For practical use, you can assume that the Resolution has the same order as Latency.

Now let's consider the Linux+`TSC` case. On Mono, we have `Resolution` = `100 ns` because it is the value of `1 tick` (and it can be achieved).
On CoreCLR, `1 ticks` is `1 ns`, and it use `rdtsc` which works on frequency = `≈2.20GHz`.
Thus, we have a situation which is similar to the `HPET`/`ACPI_PM` case: latency is much bigger than resolution.
So, it's hard to evaluate it via a microbenchmark.
Let's use the program from the [Pitfalls](#pitfalls) section (where we played with sequential reads).
We will use `ns` instead of `μs` and run it on Linux+`TSC`+CoreCLR.
Result on my laptop (the middle part was cut):

```
Ticks | Time(ns) | Count   
------|----------|---------
22    | 22.0     | 2
23    | 23.0     | 485
24    | 24.0     | 1919
25    | 25.0     | 7516
26    | 26.0     | 7683
27    | 27.0     | 825
28    | 28.0     | 8
30    | 30.0     | 2
31    | 31.0     | 2296
32    | 32.0     | 20916
33    | 33.0     | 52925
34    | 34.0     | 172174
35    | 35.0     | 110923
36    | 36.0     | 100979
37    | 37.0     | 322173
38    | 38.0     | 159638
39    | 39.0     | 9510
40    | 40.0     | 2270
41    | 41.0     | 808
42    | 42.0     | 993
43    | 43.0     | 2154
44    | 44.0     | 1114
45    | 45.0     | 2551
46    | 46.0     | 3234
47    | 47.0     | 5828
48    | 48.0     | 4342
49    | 49.0     | 3695
50    | 50.0     | 162
...
807   | 807.0    | 5
809   | 809.0    | 1
810   | 810.0    | 4
811   | 811.0    | 8
812   | 812.0    | 19
813   | 813.0    | 22
814   | 814.0    | 17
815   | 815.0    | 22
816   | 816.0    | 10
817   | 817.0    | 17
818   | 818.0    | 20
819   | 819.0    | 20
820   | 820.0    | 9
821   | 821.0    | 29
822   | 822.0    | 23
823   | 823.0    | 31
824   | 824.0    | 22
825   | 825.0    | 14
826   | 826.0    | 19
827   | 827.0    | 16
828   | 828.0    | 20
829   | 829.0    | 27
830   | 830.0    | 29
831   | 831.0    | 29
832   | 832.0    | 37
833   | 833.0    | 21
834   | 834.0    | 10
835   | 835.0    | 7
836   | 836.0    | 11
837   | 837.0    | 8
838   | 838.0    | 10
839   | 839.0    | 4
840   | 840.0    | 11
841   | 841.0    | 6
842   | 842.0    | 7
843   | 843.0    | 7
844   | 844.0    | 5
845   | 845.0    | 4
846   | 846.0    | 3
...
32808 | 32808.0  | 1
110366 | 110366.0 | 1
112423 | 112423.0 | 1
```

The minimal resolution *in this experiment* is `22 ns` but it was achieved only twice (`N = 1000000`).
Once we had two sequential timestamp invocation with difference in `112423 ticks` (or `≈112 μs`).
So, we can't say that there is a specific value of resolution in this case, but we can say that the resolution has the same order as latency.

---

### Summary

This was a brief overview of the `Stopwatch` class.
It is hard to cover all the details of `Stopwatch` behavior because there is a lot of different combinations of runtimes / operation systems / hardware.
When we are using `Stopwatch`, usually we care about its latency and resolution because these values determine what we can measure with `Stopwatch` and what we can't.
There are some possible configurations:

Runtime    | OS       | Hardware Timer | 1 tick    | Latency    | Resolution
-----------|----------|----------------|----------:|-----------:|-------------:
Full .NET  | Windows  | TSC            | 300-400ns | 15-18ns    | 300-400ns
Full .NET  | Windows  | HPET           | 69.8ns    | 0.5-0.8us  | ≈Latency
Full .NET  | Windows  | NA             | 100ns     | 7-10ns     | 0.5-55ms
Mono       | Windows  | TSC            | 100ns     | 35-45ns    | 300-400ns
Mono       | Windows  | HPET           | 100ns     | 0.5-0.8us  | ≈Latency
Mono       | Windows  | NA             | 100ns     | 30-40ns    | 0.5-55ms
CoreCLR    | Linux    | TSC            | 1ns       | 30-35ns    | ≈Latency
CoreCLR    | Linux    | HPET/ACPI_PM   | 1ns       | 0.5-0.8us  | ≈Latency
Mono       | Linux    | TSC            | 100ns     | 20-25ns    | 100ns
Mono       | Linux    | HPET/ACPI_PM   | 100ns     | 0.5-0.8us  | ≈Latency

* Here `Hardware Timer = NA` means that there is no high-precision timer in the system, i.e. `Stopwatch.IsHighResolution = false`.
* `1 tick` is calculated based on nominal frequency (`1 second` / `Stopwatch.Frequency`).
* `Resolution = ≈Latency` means that the actual Resolution is less than the Latency, the observed Resolution has the same order as the Latency.

Note that it's only examples, you can get different values in different situations.
This tables just shows that sometimes it's not easy to guess target latency and resolution, there are a lot of things which can affect these values.
Anyway, you should be careful, if you want to measure time intervals.
Especially, if you want to measure small time intervals: it's really easy to make a mistake and get wrong results.
If you want to know more about high-resolution time measurements, there are a lot of links in the [next section](#links).

As you can see, the topic is very hard because there are a lot of different environments in the modern world.
If I missed something important or wrote something wrong, feel free to leave any feedback.

### Links

* **Best**
    * [MSDN: Acquiring high-resolution time stamps](https://msdn.microsoft.com/library/windows/desktop/dn553408.aspx)
    * [The Windows Timestamp Project](http://www.windowstimestamp.com/description)
    * [Pitfalls of TSC usage](http://oliveryang.net/2015/09/pitfalls-of-TSC-usage/)
* **Useful software**
    * [CPU-Z](http://www.cpuid.com/softwares/cpu-z.html)
    * [ClockRes](https://technet.microsoft.com/en-us/sysinternals/bb897568.aspx)
    * [Coreinfo](https://technet.microsoft.com/en-us/sysinternals/cc835722)
    * [DPC Latency Checker](http://www.thesycon.de/deu/latency_check.shtml)
    * [Harmonic](http://www.bytemedev.com/programs/harmonic-help/)
    * [LatencyMon](http://www.resplendence.com/latencymon)
* **MSDN**
    * [MSDN: BCDEdit](https://msdn.microsoft.com/en-us/library/windows/hardware/ff542202%28v=vs.85%29.aspx)
    * [MSDN: DateTime.UtcNow](https://msdn.microsoft.com/library/system.datetime.utcnow.aspx)
    * [MSDN: Stopwatch](https://msdn.microsoft.com/library/system.diagnostics.stopwatch.aspx)
    * [MSDN: SetThreadAffinityMask](https://msdn.microsoft.com/library/windows/desktop/ms686247.aspx)
    * [MSDN: Game Timing and Multicore Processors](https://msdn.microsoft.com/en-us/library/ee417693.aspx)
    * [MSDN: VirtualAlloc](https://msdn.microsoft.com/library/windows/desktop/aa366887.aspx)
    * [MSDN: __rdtsc](https://msdn.microsoft.com/en-us/library/twchhe95.aspx)
* **Wiki**
    * [Wiki: System time](https://en.wikipedia.org/wiki/System_time)
    * [Wiki: CPUID](https://en.wikipedia.org/wiki/CPUID)
* **Intel**
    * [Intel: How to Benchmark Code Execution Times on Intel®IA-32 and IA-64 Instruction Set Architectures](http://www.intel.com/content/dam/www/public/us/en/documents/white-papers/ia-32-ia-64-benchmark-code-execution-paper.pdf)
    * [Intel: IA-PC HPET Specification](http://www.intel.com/content/dam/www/public/us/en/documents/technical-specifications/software-developers-hpet-spec-1-0a.pdf)
    * [Intel: Intel® 64 and IA-32 Architectures Software Developer’s Manual Volume 3A: System Programming Guide, Part 1](ftp://download.intel.com/design/processor/manuals/253668.pdf)
    * [Intel: Intel® 64 and IA-32 Architectures Software Developer’s Manual](http://www.intel.com/content/dam/www/public/us/en/documents/manuals/64-ia-32-architectures-software-developer-manual-325462.pdf)
    * [Intel's original CPU TSC Counter guidance for use in game timing (1998)](https://www.ccsl.carleton.ca/~jamuir/rdtscpm1.pdf)
    * [Power Management States: P-States, C-States, and Package C-States](https://software.intel.com/en-us/articles/power-management-states-p-states-c-states-and-package-c-states)
* **Blog posts**
    * [Random ASCII: Windows Timer Resolution: Megawatts Wasted (2013)](https://randomascii.wordpress.com/2013/07/08/windows-timer-resolution-megawatts-wasted/)
    * [Random ASCII: Sleep Variation Investigated (2013)](https://randomascii.wordpress.com/2013/04/02/sleep-variation-investigated/)
    * [Random ASCII: rdtsc in the Age of Sandybridge (2011)](https://randomascii.wordpress.com/2011/07/29/rdtsc-in-the-age-of-sandybridge/)
    * [The Old New Thing: Precision is not the same as accuracy (2005)](https://blogs.msdn.microsoft.com/oldnewthing/20050902-00/?p=34333/#460003)
    * [VirtualDub: Beware of QueryPerformanceCounter() (2006)](http://www.virtualdub.org/blog/pivot/entry.php?id=106)
    * [Computer Performance By Design: High Resolution Clocks and Timers for Performance Measurement in Windows (2012)](http://computerperformancebydesign.com/high-resolution-clocks-and-timers-for-performance-measurement-in-windows/)
    * [Jan Wassenberg: Timing Pitfalls and Solutions (2007)](http://algo2.iti.kit.edu/wassenberg/timing/timing_pitfalls.pdf)
    * [MathPirate: Temporal Mechanics: Changing the Speed of Time, Part II (2010)](http://www.mathpirate.net/log/2010/03/20/temporal-mechanics-changing-the-speed-of-time-part-ii/)
    * [Mike Martin: Disable HPET (2015)](http://www.mikemartin.co/system_guides/hardware/motherboard/disable_high_precision_event_timer_hpet)
    * [Manski`s blog: High Resolution Clock in C# (2014)](http://manski.net/2014/07/high-resolution-clock-in-csharp/)
    * [Coding Horror: Keeping Time on the PC (2007)](http://blog.codinghorror.com/keeping-time-on-the-pc/)
    * [Hungry Mind: High-Resolution Timer = Time Stamp Counter = RDTSC (2007, In Russian)](http://chabster.blogspot.ru/2007/09/high-resolution-timer-time-stamp.html)
    * [How to measure your CPU time: clock_gettime! (2016)](http://jvns.ca/blog/2016/02/20/measuring-cpu-time-with-clock-gettime/)
    * [How CPU load averages work (and using them to triage webserver performance!) (2016)](http://jvns.ca/blog/2016/02/07/cpu-load-averages/)
    * [Stat's blog: What is behind System.nanoTime()? (2012)](http://stas-blogspot.blogspot.co.il/2012/02/what-is-behind-systemnanotime.html)
    * [Linux: virtualization and tracing: How does clock_gettime work (2013)](http://linuxmogeb.blogspot.co.il/2013/10/how-does-clockgettime-work.html)
    * [Software ahoy!: High Performance Time Measurement in Linux (2010)](https://aufather.wordpress.com/2010/09/08/high-performance-time-measuremen-in-linux/)
* **Misc**
    * [Advanced Configuration and Power Interface  Specification 6.0 (April 2015)](http://www.uefi.org/sites/default/files/resources/ACPI_6.0.pdf)
    * [RedHat Documentation: Timestamping](https://access.redhat.com/documentation/en-US/Red_Hat_Enterprise_MRG/2/html/Realtime_Reference_Guide/chap-Timestamping.html)
    * [Luxford: High Performance Windows Timers](http://www.luxford.com/high-performance-windows-timers)
    * [Mmo-champion: WinTimerTester](http://www.mmo-champion.com/threads/1215396-WinTimerTester)
    * [support.microsoft.com: Programs that use the QueryPerformanceCounter function may perform poorly](https://support.microsoft.com/en-us/kb/895980)
    * [support.microsoft.com: The system clock may run fast when you use the ACPI power management timer](https://support.microsoft.com/en-us/kb/821893)
    * [linux.die.net: sched_setaffinity](http://linux.die.net/man/2/sched_setaffinity)
    * [NCrunch: How to set a thread's processor affinity in .NET](http://blog.ncrunch.net/post/How-to-set-a-threads-processor-affinity-in-NET.aspx)
    * [x86 Instruction Set Reference: RDTSC](http://x86.renejeschke.de/html/file_module_x86_id_278.html)
    * [TSC and Power Management Events on AMD Processors (2005)](https://lkml.org/lkml/2005/11/4/173)
    * [Counting on the time stamp counter (2006)](http://lwn.net/Articles/209101/)
    * [JDK-6313903: Thread.sleep(3) might wake up immediately on windows](http://bugs.java.com/bugdatabase/view_bug.do?bug_id=6313903)
    * [Wikipedia: NTSC](https://en.wikipedia.org/wiki/NTSC)
    * [Wikipedia: Colorburst](https://en.wikipedia.org/wiki/Colorburst)
    * [3.579545 MHz Can be More Than the Color Burst (1980)](http://dl.acm.org/citation.cfm?id=2278530)
    * [Implementing virtual system calls](https://lwn.net/Articles/615809/)
    * [github.com/torvalds/linux: x86: tsc prevent time going backwards](https://github.com/torvalds/linux/commit/d8bb6f4c1670c8324e4135c61ef07486f7f17379)
* **StackOverflow**
    * [StackOverflow: Can the .NET Stopwatch class be THIS terrible?](http://stackoverflow.com/questions/3400254/can-the-net-stopwatch-class-be-this-terrible/3400490#3400490)
    * [StackOverflow: How precise is the internal clock of a modern PC?](http://stackoverflow.com/questions/2607263/how-precise-is-the-internal-clock-of-a-modern-pc)
    * [StackOverflow: Windows 7 timing functions - How to use GetSystemTimeAdjustment correctly?](http://stackoverflow.com/q/7685762/184842)
    * [StackOverflow: What is the acpi_pm linux clocksource used for, what hardware implements it?](http://stackoverflow.com/q/7987671/184842)
    * [StackOverflow: Is QueryPerformanceFrequency accurate when using HPET?](http://stackoverflow.com/q/22942123/184842)
    * [StackOverflow: Measure precision of timer (e.g. Stopwatch/QueryPerformanceCounter)](http://stackoverflow.com/questions/36318291/measure-precision-of-timer-e-g-stopwatch-queryperformancecounter)
    * [StackOverflow: How to calculate the frequency of CPU cores](http://stackoverflow.com/q/23251795/184842)
    * [StackOverflow: Precise Linux Timing - What Determines the Resolution of clock_gettime()?](http://stackoverflow.com/q/18343188/184842)
