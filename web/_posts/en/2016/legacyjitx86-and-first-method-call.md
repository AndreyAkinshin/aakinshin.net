---
layout: post
title: "LegacyJIT-x86 and first method call"
date: "2016-04-04"
lang: en
type: post
tags:
- ".NET"
- C#
- JIT
- Benchmarks
redirect_from:
- /en/blog/dotnet/legacyjitx86-and-first-method-call/
- /blog/post/legacyjitx86-and-first-method-call/
---

Today I tell you about one of my favorite benchmarks (this method doesn't return a useful value, we need it only as an example):

```cs
[Benchmark]
public string Sum()
{
    double a = 1, b = 1;
    var sw = new Stopwatch();
    for (int i = 0; i < 10001; i++)
        a = a + b;
    return string.Format("{0}{1}", a, sw.ElapsedMilliseconds);
}
```

An interesting fact: if you call `Stopwatch.GetTimestamp()` before the first call of the `Sum` method, you improve `Sum` performance several times (works only with LegacyJIT-x86).

<!--more-->

### Source code and ASM

Let's consider the following programs (platform target is `x86`):

```cs
class ProgramA
{
    static void Main()
    {
        Sum();
    }

    public static string Sum()
    {
        double a = 1, b = 1;
        var sw = new Stopwatch();
        for (int i = 0; i < 10001; i++)
            a = a + b;
        return string.Format("{0}{1}", a, sw.ElapsedMilliseconds);
    }
}
```

```cs
class ProgramB
{
    static void Main()
    {
        Stopwatch.GetTimestamp(); // !!!
        Sum();
    }

    public static string Sum()
    {
        double a = 1, b = 1;
        var sw = new Stopwatch();
        for (int i = 0; i < 10001; i++)
            a = a + b;
        return string.Format("{0}{1}", a, sw.ElapsedMilliseconds);
    }
}
```

The only difference between these programs is the `Stopwatch.GetTimestamp()` call. Now, let's look at the asm code for the loop:

```x86asm
; ProgramA
;  for (int i = 0; i < 10001; i++)
xor         eax,eax  
;  a = a + b;
fld1  
fadd        qword ptr [ebp-14h]  
fstp        qword ptr [ebp-14h]

; ProgramB
;  for (int i = 0; i < 10001; i++)
xor         eax,eax  
;  a = a + b;
fld1  
faddp       st(1),st  
```

It turns out, that in `ProgramA` keeps data on the stack, `ProgramB` keeps data in FPU registers.

### How so?

In fact, in `ProgramB` we can call `Stopwatch.IsHighResolution` or `Stopwatch.Frequency` instead of `Stopwatch.GetTimestamp()`. The main things is that we want to implicitly call the static constructor of the `Stopwatch` class. It affects how the call of the `Stopwatch` instance constructor will be jitted:

```x86asm
; Program A
;  var sw = new Stopwatch();
mov         ecx,71CDF3D4h  
call        005D30F4         ; basic ctor logic

mov         ecx,5E5F60h      ; !!! Here we should check
mov         edx,4F6h         ; !!! that static constructor
call        005D348C         ; !!! has been called

; // inlined Stopwatch::.ctor body
mov         dword ptr [esi+4],0   ; elapsed = 0
mov         dword ptr [esi+8],0   ; elapsed = 0
mov         byte ptr [esi+14h],0  ; isRunning = false
mov         dword ptr [esi+0Ch],0 ; startTimeStamp = 0
mov         dword ptr [esi+10h],0 ; startTimeStamp = 0

; Program B
;  var sw = new Stopwatch();
mov         ecx,71CDF3D4h  
call        005D30F4         ; basic ctor logic

; // inlined Stopwatch::.ctor body
mov         dword ptr [esi+4],0   ; elapsed = 0
mov         dword ptr [esi+8],0   ; elapsed = 0
mov         byte ptr [esi+14h],0  ; isRunning = false
mov         dword ptr [esi+0Ch],0 ; startTimeStamp = 0
mov         dword ptr [esi+10h],0 ; startTimeStamp = 0
```

As you can see, we have two call sites for `ProgramA` and one call site for `ProgramB`.

The FP enregistration logic for the LegacyJIT-x86 uses the number of call sites as a factor in choosing to enregister or not to enregister floating point locals. Thus, we have different asm code for `ProgramA` and `ProgramB`.

### Benchmarks

But should we care about it? How it affects method performance? Let's benchmark it! I wrote the following benchmark (based on [BenchmarkDotNet](https://github.com/PerfDotNet/BenchmarkDotNet) v0.9.4):

```cs
[Config(typeof(Config))]
public class FirstCall
{
    [Params(false, true)]
    public bool CallTimestamp { get; set; }

    [Setup]
    public void Setup()
    {
        if (CallTimestamp)
            Stopwatch.GetTimestamp();
    }

    [Benchmark]
    public string Sum()
    {
        double a = 1, b = 1;
        var sw = new Stopwatch();
        for (int i = 0; i < 10001; i++)
            a = a + b;
        return string.Format("{0}{1}", a, sw.ElapsedMilliseconds);
    }

    private class Config : ManualConfig
    {
        public Config()
        {
            Add(Job.LegacyJitX86);
        }
    }
}
```

Results:

```ini
BenchmarkDotNet=v0.9.4.0
OS=Microsoft Windows NT 6.2.9200.0
Processor=Intel(R) Core(TM) i7-4810MQ CPU 2.80GHz, ProcessorCount=8
Frequency=2728072 ticks, Resolution=366.5592 ns, Timer=TSC
HostCLR=MS.NET 4.0.30319.42000, Arch=32-bit RELEASE
JitModules=clrjit-v4.6.1073.0

Type=FirstCall  Mode=Throughput  Platform=X86
Jit=LegacyJit

 Method |     Median |    StdDev | CallTimestamp |
------- |----------- |---------- |-------------- |
    Sum | 27.0464 us | 0.4958 us |         False |
    Sum |  8.3247 us | 0.0293 us |          True |
```

A single call of `Stopwatch.GetTimestamp()` before the first call of the `Sum` method improved performance 3.5 times!

### Conclusion

Sometimes, performance is tricky and benchmarking is super-tricky.

* In general case, you can't just take a method without a context and start to discuss about its performance because method jitted code can depend on CLR state at the moment of the first method call. (However, in practice, this is a rare situation).
* Your benchmark methods can affect each other (not only because of static constructors; e.g., self-tuned GC and interface method dispatching are important). Thus, it is a good practice to run each benchmark method in a separated process (default behaviour of [BenchmarkDotNet](https://github.com/PerfDotNet/BenchmarkDotNet)) .
* It is really easy to make a mistake in a handwritten benchmark. In the above example, a careless call of a `Stopwatch` method can spoil benchmark results.

### See also

* [Stackoverflow: Weird performance increase in simple benchmark](http://stackoverflow.com/questions/32114308/weird-performance-increase-in-simple-benchmark)
* [MSDN: Static Constructors](https://msdn.microsoft.com/en-us/library/k9x6w0hc.aspx)