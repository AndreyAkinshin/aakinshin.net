---
layout: post
title: "Cross-runtime .NET disassembly with BenchmarkDotNet"
date: "2018-04-10"
lang: en
type: post
tags:
- .NET
- C#
- BenchmarkDotNet
- benchmarking
- disassembly
redirect_from:
- /blog/post/dotnet-crossruntime-disasm
---

[BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet) is a cool tool for benchmarking.
It has a lot of useful features that help you with performance investigations.
However, you can use these features even if you are not actually going to benchmark something.
One of these features is `DisassemblyDiagnoser`.
It shows you a disassembly listing of your code for all required runtimes.
In this post, I will show you how to get disassembly listing for .NET Framework, .NET Core, and Mono with one click!
You can do it with a very small code snippet like this:

```cs
[DryCoreJob, DryMonoJob, DryClrJob(Platform.X86)]
[DisassemblyDiagnoser]
public class IntroDisasm
{
    [Benchmark]
    public double Sum()
    {
        double res = 0;
        for (int i = 0; i < 64; i++)
            res += i;
        return res;
    }
}
```

<!--more-->

That's all!
`[CoreJob]`, `[MonoJob]`, `[ClrJob]` mean that we are going to run it on .NET Core, Mono, and .NET Framework.
`[Dry]` means that we are going to run only single "dry" iteration for each runtime without actual measurements.
`[DisassemblyDiagnoser]` means that we want to get assembly listings in the `BenchmarkDotNet.Artifacts` folder.

Some important remarks:

* This benchmark requires .NET Framework, so it works only on Windows.
* We use `Platform.X86` for `[ClrJob]` because we want to see a difference in assembly listing.
  The modern versions of .NET Framework and .NET Core use the same JIT engine on `x64`.
  So let's compare `LegacyJIT-x86` from .NET Framework and `RyuJIT-x64` from .NET Core.
* To get assembly listings for Mono on Windows, you need `as` and `x86_64-w64-mingw32-objdump.exe` tools.
  You can read more about it in the [documentation](http://benchmarkdotnet.org/Configs/Diagnosers.htm#disassembly-diagnoser-for-mono-on-windows).

The source code (the benchmark + the csproj file) is available here: https://gist.github.com/AndreyAkinshin/62d2f4c3e67acde844f569fbf5846570
You can try it on your machine with the help of the following script:

```bash
git clone https://gist.github.com/62d2f4c3e67acde844f569fbf5846570.git DisasmDemo
cd DisasmDemo
dotnet run -f netcoreapp2.0 -c Release
start BenchmarkDotNet.Artifacts\results\IntroDisasm-disassembly-report.html
```

As a result, you will see an html page which contains disassembly listings for all runtimes:

@Raw(Model.Image("disasm.png"))

The raw code:

```x86asm
; .NET Framework 4.7 (CLR 4.0.30319.42000), 32bit LegacyJIT-v4.7.2633.0

07404098 DisasmDemo.IntroDisasm.Sum()
0740409c d9ee            fldz
0740409e 33c0            xor     eax,eax
074040a0 8945fc          mov     dword ptr [ebp-4],eax
074040a3 db45fc          fild    dword ptr [ebp-4]
074040a6 dec1            faddp   st(1),st
074040a8 40              inc     eax
074040a9 83f840          cmp     eax,40h
074040ac 7cf2            jl      074040a0
074040ae 8be5            mov     esp,ebp
```

```x86asm
; .NET Core 2.0.6 (CoreCLR 4.6.26212.01, CoreFX 4.6.26212.01), 64bit RyuJIT

00007fff 196433b0 DisasmDemo.IntroDisasm.Sum()
00007fff 196433b3 c4e17957c0      vxorpd  xmm0,xmm0,xmm0
00007fff 196433b8 33c0            xor     eax,eax
00007fff 196433ba c4e17057c9      vxorps  xmm1,xmm1,xmm1
00007fff 196433bf c4e1732ac8      vcvtsi2sd xmm1,xmm1,eax
00007fff 196433c4 c4e17b58c1      vaddsd  xmm0,xmm0,xmm1
00007fff 196433c9 ffc0            inc     eax
00007fff 196433cb 83f840          cmp     eax,40h
00007fff 196433ce 7cea            jl      00007fff 196433ba
00007fff 196433d0 c3              ret
```

```x86asm
; Mono 5.4.0 (Visual Studio), 64bit

 Sum
sub    $0x18,%rsp
mov    %rsi,(%rsp)
xorpd  %xmm0,%xmm0
movsd  %xmm0,0x8(%rsp)
xor    %esi,%esi
jmp    2e 
xchg   %ax,%ax
movsd  0x8(%rsp),%xmm0
cvtsi2sd %esi,%xmm1
addsd  %xmm1,%xmm0
movsd  %xmm0,0x8(%rsp)
inc    %esi
cmp    $0x40,%esi
jl     18 
movsd  0x8(%rsp),%xmm0
mov    (%rsp),%rsi
add    $0x18,%rsp
retq
```

As you can see, BenchmarkDotNet uses different diasasm style for each runtime.
Well, `DisassemblyDiagnoser` is a recent feature, it works, but we did not have enough time to polish it.
However, BenchmarkDotNet is [rapidly evolving](https://github.com/dotnet/BenchmarkDotNet/wiki/ChangeLog),
  each version contains many improvements and bug fixes.
If you want to help with the disasm support, [contributions are welcome](https://github.com/dotnet/BenchmarkDotNet#contributions-are-welcome)!