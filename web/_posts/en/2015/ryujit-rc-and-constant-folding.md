---
layout: post
title: "RyuJIT RC and constant folding"
date: "2015-05-12"
lang: en
type: post
tags:
- ".NET"
- C#
- JIT
- RyuJIT
- ConstantFolding
redirect_from:
- /en/blog/dotnet/ryujit-rc-and-constant-folding/
- /blog/post/ryujit-rc-and-constant-folding/
---

**Update:** The below results are valid for the release version of RyuJIT in .NET Framework 4.6 without updates.

The challenge of the day: which method is faster?

```cs
public double Sqrt13()
{
    return Math.Sqrt(1) + Math.Sqrt(2) + Math.Sqrt(3) + Math.Sqrt(4) + Math.Sqrt(5) + 
           Math.Sqrt(6) + Math.Sqrt(7) + Math.Sqrt(8) + Math.Sqrt(9) + Math.Sqrt(10) + 
           Math.Sqrt(11) + Math.Sqrt(12) + Math.Sqrt(13);
}
public double Sqrt14()
{
    return Math.Sqrt(1) + Math.Sqrt(2) + Math.Sqrt(3) + Math.Sqrt(4) + Math.Sqrt(5) + 
           Math.Sqrt(6) + Math.Sqrt(7) + Math.Sqrt(8) + Math.Sqrt(9) + Math.Sqrt(10) + 
           Math.Sqrt(11) + Math.Sqrt(12) + Math.Sqrt(13) + Math.Sqrt(14);
}
```

I have measured the methods performance with help of [BenchmarkDotNet](https://github.com/AndreyAkinshin/BenchmarkDotNet) for RyuJIT RC (a part of .NET Framework 4.6 RC) and received the following results:

```
// BenchmarkDotNet=v0.7.4.0
// OS=Microsoft Windows NT 6.2.9200.0
// Processor=Intel(R) Core(TM) i7-4702MQ CPU ＠ 2.20GHz, ProcessorCount=8
// CLR=MS.NET 4.0.30319.0, Arch=64-bit  [RyuJIT]
Common:  Type=Math_DoubleSqrtAvx  Mode=Throughput  Platform=X64  Jit=RyuJit  .NET=Current  

 Method |  AvrTime |    StdDev |         op/s |
------- |--------- |---------- |------------- |
 Sqrt13 | 55.40 ns |  0.571 ns |  18050993.06 |
 Sqrt14 |  1.43 ns | 0.0224 ns | 697125029.18 |
```

How so? If I add one more `Math.Sqrt` to the expression, the method starts work 40 times faster! Let's examine the situation..<!--more-->

First of all, open in VisualStudio generated ASM code:

```nasm
; Sqrt13
vsqrtsd     xmm0,xmm0,mmword ptr [7FF94F9E4D28h]  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D30h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D38h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D40h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D48h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D50h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D58h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D60h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D68h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D70h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D78h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D80h]  
vaddsd      xmm0,xmm0,xmm1  
vsqrtsd     xmm1,xmm0,mmword ptr [7FF94F9E4D88h]  
vaddsd      xmm0,xmm0,xmm1  
ret

; Sqrt14
vmovsd      xmm0,qword ptr [7FF94F9C4C80h]  
ret    
```

How so? It seems that an expression with 13 of `Math.Sqrt` calculates honestly and an expression with 14 of `Math.Sqrt` uses constant folding for result precalculation.

Next, let's build own version of CoreCLR. I will work with the actual version for today ([0e6021bb](https://github.com/dotnet/coreclr/commit/0e6021bb96eaee9ac94e5f0095cbe4e846cdb6af)). 
`COMPLUS_JitDisasm` can help us to print generated ASM code:

```nasm
; Sqrt13
sqrtsd   xmm0, qword ptr [＠RWD00]
sqrtsd   xmm1, qword ptr [＠RWD08]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD16]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD24]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD32]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD40]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD48]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD56]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD64]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD72]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD80]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD88]
addsd    xmm0, xmm1
sqrtsd   xmm1, qword ptr [＠RWD96]
addsd    xmm0, xmm1
ret

; Sqrt14
movsd    xmm0, qword ptr [＠RWD00]
ret
```

We can see that CoreCLR uses the `sqrtsd` instruction (SSE2) instead of `vsqrtsd` (AVX). It is not important for now. We can create an issue on GitHib ([coreclr/issues/977](https://github.com/dotnet/coreclr/issues/977)) and continue (now there is a fix for the problem: [coreclr/pull/981](https://github.com/dotnet/coreclr/pull/981)).

Now let's enable `COMPLUS_JitDump` and print the full dump. We can see that RyuJIT build the following tree for `Sqrt13`:

```
*  stmtExpr  void  (top level) (IL 0x000...  ???)
|     /--*  mathFN    double sqrt
|     |  \--*  dconst    double 13.000000000000000
|  /--*  +         double
|  |  |  /--*  mathFN    double sqrt
|  |  |  |  \--*  dconst    double 12.000000000000000
|  |  \--*  +         double
|  |     |  /--*  mathFN    double sqrt
|  |     |  |  \--*  dconst    double 11.000000000000000
|  |     \--*  +         double
|  |        |  /--*  mathFN    double sqrt
|  |        |  |  \--*  dconst    double 10.000000000000000
|  |        \--*  +         double
|  |           |  /--*  mathFN    double sqrt
|  |           |  |  \--*  dconst    double 9.0000000000000000
|  |           \--*  +         double
|  |              |  /--*  mathFN    double sqrt
|  |              |  |  \--*  dconst    double 8.0000000000000000
|  |              \--*  +         double
|  |                 |  /--*  mathFN    double sqrt
|  |                 |  |  \--*  dconst    double 7.0000000000000000
|  |                 \--*  +         double
|  |                    |  /--*  mathFN    double sqrt
|  |                    |  |  \--*  dconst    double 6.0000000000000000
|  |                    \--*  +         double
|  |                       |  /--*  mathFN    double sqrt
|  |                       |  |  \--*  dconst    double 5.0000000000000000
|  |                       \--*  +         double
|  |                          |  /--*  mathFN    double sqrt
|  |                          |  |  \--*  dconst    double 4.0000000000000000
|  |                          \--*  +         double
|  |                             |  /--*  mathFN    double sqrt
|  |                             |  |  \--*  dconst    double 3.0000000000000000
|  |                             \--*  +         double
|  |                                |  /--*  mathFN    double sqrt
|  |                                |  |  \--*  dconst    double 2.0000000000000000
|  |                                \--*  +         double
|  |                                   \--*  mathFN    double sqrt
|  |                                      \--*  dconst    double 1.0000000000000000
\--*  =         double
   \--*  lclVar    double V01 tmp0
```

RyuJIT marks the expression in `Sqrt13` as not too big and don't apply any optimization in this case. However, RyuJIT mark the expression in `Sqrt14` as too big, save in a temp variable, and apply [constant folding](http://en.wikipedia.org/wiki/Constant_folding):

```
N001 [000001]   dconst    1.0000000000000000 => $c0 {DblCns[1.000000]}
N002 [000002]   mathFN    => $c0 {DblCns[1.000000]}
N003 [000003]   dconst    2.0000000000000000 => $c1 {DblCns[2.000000]}
N004 [000004]   mathFN    => $c2 {DblCns[1.414214]}
N005 [000005]   +         => $c3 {DblCns[2.414214]}
N006 [000006]   dconst    3.0000000000000000 => $c4 {DblCns[3.000000]}
N007 [000007]   mathFN    => $c5 {DblCns[1.732051]}
N008 [000008]   +         => $c6 {DblCns[4.146264]}
N009 [000009]   dconst    4.0000000000000000 => $c7 {DblCns[4.000000]}
N010 [000010]   mathFN    => $c1 {DblCns[2.000000]}
N011 [000011]   +         => $c8 {DblCns[6.146264]}
N012 [000012]   dconst    5.0000000000000000 => $c9 {DblCns[5.000000]}
N013 [000013]   mathFN    => $ca {DblCns[2.236068]}
N014 [000014]   +         => $cb {DblCns[8.382332]}
N015 [000015]   dconst    6.0000000000000000 => $cc {DblCns[6.000000]}
N016 [000016]   mathFN    => $cd {DblCns[2.449490]}
N017 [000017]   +         => $ce {DblCns[10.831822]}
N018 [000018]   dconst    7.0000000000000000 => $cf {DblCns[7.000000]}
N019 [000019]   mathFN    => $d0 {DblCns[2.645751]}
N020 [000020]   +         => $d1 {DblCns[13.477573]}
N021 [000021]   dconst    8.0000000000000000 => $d2 {DblCns[8.000000]}
N022 [000022]   mathFN    => $d3 {DblCns[2.828427]}
N023 [000023]   +         => $d4 {DblCns[16.306001]}
N024 [000024]   dconst    9.0000000000000000 => $d5 {DblCns[9.000000]}
N025 [000025]   mathFN    => $c4 {DblCns[3.000000]}
N026 [000026]   +         => $d6 {DblCns[19.306001]}
N027 [000027]   dconst    10.000000000000000 => $d7 {DblCns[10.000000]}
N028 [000028]   mathFN    => $d8 {DblCns[3.162278]}
N029 [000029]   +         => $d9 {DblCns[22.468278]}
N030 [000030]   dconst    11.000000000000000 => $da {DblCns[11.000000]}
N031 [000031]   mathFN    => $db {DblCns[3.316625]}
N032 [000032]   +         => $dc {DblCns[25.784903]}
N033 [000033]   dconst    12.000000000000000 => $dd {DblCns[12.000000]}
N034 [000034]   mathFN    => $de {DblCns[3.464102]}
N035 [000035]   +         => $df {DblCns[29.249005]}
N036 [000036]   dconst    13.000000000000000 => $e0 {DblCns[13.000000]}
N037 [000037]   mathFN    => $e1 {DblCns[3.605551]}
N038 [000038]   +         => $e2 {DblCns[32.854556]}
N039 [000041]   lclVar    V01 tmp0         d:2 => $e2 {DblCns[32.854556]}
N040 [000042]   =         => $e2 {DblCns[32.854556]}
```

This is very strange situation. I want to see RyuJIT could apply such optimization even for small expression. So, go to GitHub and create another issue: [coreclr/issues/978](https://github.com/dotnet/coreclr/issues/978). We can learn some new fact from the discussion: if we manually save the result of expression in a temp variable:

```cs
public static double Sqrt13B()
{
    double res = Math.Sqrt(1) + Math.Sqrt(2) + Math.Sqrt(3) + Math.Sqrt(4) + Math.Sqrt(5) + 
                 Math.Sqrt(6) + Math.Sqrt(7) + Math.Sqrt(8) + Math.Sqrt(9) + Math.Sqrt(10) + 
                 Math.Sqrt(11) + Math.Sqrt(12) + Math.Sqrt(13);
    return res;
}
```

then RyuJIT applies constant folding, the expression will be precalculated. As a result of the discussion, it was decided: RyuJIT shouldn't behave like this. So, another ticked was created: [coreclr/issues/987](https://github.com/dotnet/coreclr/issues/987).

### Links

* [coreclr/issues/977](https://github.com/dotnet/coreclr/issues/977): How to run CoreCLR with the AVX support?
* [coreclr/issues/978](https://github.com/dotnet/coreclr/issues/978): Is it possible to make "force optimization mode" for RyuJIT?
* [coreclr/pull/981](https://github.com/dotnet/coreclr/pull/981): Enable FEATURE_SIMD and FEATURE_AVX_SUPPORT in the JIT
* [coreclr/issues/987](https://github.com/dotnet/coreclr/issues/987): JIT optimization - Perform additional constant propagation for expressions
