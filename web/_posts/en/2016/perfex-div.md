---
layout: post
title: "Performance exercise: Division"
date: "2016-12-26"
lang: en
type: post
tags:
- .NET
- PerformanceExercise
- Benchmarking
- Math
redirect_from:
- /en/blog/dotnet/perfex-div/
- /blog/post/perfex-div/
---

In the previous post, we [discussed](/en/blog/dotnet/perfex-min/) the performance space of the minimum function
  which was implemented via a simple ternary operator and with the help of bit magic.
Now we continue to talk about performance and bit hacks.
In particular, we will divide a positive number by three:
```cs
uint Div3Simple(uint n)   => n / 3;
uint Div3BitHacks(uint n) => (uint)((n * (ulong)0xAAAAAAAB) >> 33);
```

As usual, it's hard to say which method is faster in advanced because the performance depends on the environment.
Here are some interesting results:
 
<table class="table table-sm">
  <tr> <th></th>              <th>Simple</th>              <th>BitHacks</th>             </tr>
  <tr> <th>LegacyJIT-x86</th> <td class="norm">≈8.3ns</td> <td class="fast">≈2.6ns</td>  </tr>
  <tr> <th>LegacyJIT-x64</th> <td class="fast">≈2.6ns</td> <td class="fast">≈1.7ns</td>  </tr>
  <tr> <th>RyuJIT-x64   </th> <td class="norm">≈6.9ns</td> <td class="fast">≈1.5ns</td>  </tr>
  <tr> <th>Mono4.6.2-x86</th> <td class="norm">≈8.5ns</td> <td class="slow">≈14.4ns</td> </tr>
  <tr> <th>Mono4.6.2-x64</th> <td class="norm">≈8.3ns</td> <td class="fast">≈2.8ns</td>  </tr>
</table>

<!--more-->
Let's try to understand why we could have such results.
Note that it is just an exercise:
  we will not discuss which JIT or runtime is better,
  how we should write production code, and so on.
Our main goal is to understand which kind of pitfalls we should expect during benchmarking
  and why it's very important to check different environments.

### Bit hacks

The first method (`n / 3`) looks very obvious.
However, it includes an integer division which is an expensive operation.
Fortunately, there is an [old hack](https://en.wikipedia.org/wiki/Division_algorithm#Division_by_a_constant)
  which allows replacing "Division by a constant" by "multiplication + bit shift".  
The basic idea is the following: we should hide the division inside a constant.
In our case, `0xAAAAAAAB = RoundUp(2^33 / 3)`.
Thus, we multiply `n` by `2^33 / 3` and divide it by `2^33` (`>> 33`).
The result is equal to `n/3`.


### Benchmarks

It's always hard to benchmark tiny methods.
There are many different ways to benchmark division, each of them will show own results.
Today we will try to measure *latency* of our operations.
It means that the next operation in the loop should be started only after the previous operation finished.
So, we create a dependency chain that use the result of previous operation as an input for the next one.
Such construction helps to prevent [instruction-level parallelism](https://en.wikipedia.org/wiki/Instruction-level_parallelism).
As usual, we design a benchmark with the help of [BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet):

```cs
[LegacyJitX86Job, LegacyJitX64Job, RyuJitX64Job, MonoJob]
public class DivBench
{
    private uint x = 1, initialValue = uint.MaxValue;

    [Benchmark(OperationsPerInvoke = 32)]
    public void Simple()
    {
        x = initialValue;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
        x = x / 3;
    }

    [Benchmark(OperationsPerInvoke = 32)]
    public void BitHacks()
    {
        x = initialValue;
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
        x = (uint) ((x * (ulong) 0xAAAAAAAB) >> 33);
    }
}
```

Note that `x` is a field here.
Here is a little homework exercise for you: check out what happens, if we declare `x` as a local variable.

Another note: BenchmarkDotNet doesn't allow to run a benchmark against two different version of Mono at the same time
  (hopefully, will be fixed soon).
So, I launched it twice and combined output manually.
Raw results on my laptop:

```ini
BenchmarkDotNet=v0.10.1, OS=Microsoft Windows NT 6.2.9200.0
Processor=Intel(R) Core(TM) i7-4702MQ CPU 2.20GHz, ProcessorCount=8
Frequency=2143475 Hz, Resolution=466.5321 ns, Timer=TSC
  LegacyJitX86 : Clr 4.0.30319.42000, 32bit LegacyJIT-v4.6.1586.0
  LegacyJitX64 : Clr 4.0.30319.42000, 64bit LegacyJIT/clrjit-v4.6.1586.0;compatjit-v4.6.1586.0
  RyuJitX64    : Clr 4.0.30319.42000, 64bit RyuJIT-v4.6.1586.0
  MonoX86      : Mono 4.6.2 (Visual Studio built mono), 32bit
  MonoX64      : Mono 4.6.2 (Visual Studio built mono), 64bit
```

|   Method |          Job |       Mean |    StdDev |
|--------- |------------- |----------- |---------- |
|   Simple | LegacyJitX86 |  8.3387 ns | 0.1021 ns |
| BitHacks | LegacyJitX86 |  2.5719 ns | 0.0049 ns |
|   Simple | LegacyJitX64 |  2.5649 ns | 0.0264 ns |
| BitHacks | LegacyJitX64 |  1.6595 ns | 0.0136 ns |
|   Simple |    RyuJitX64 |  6.8538 ns | 0.0352 ns |
| BitHacks |    RyuJitX64 |  1.5413 ns | 0.0138 ns |
|   Simple |      MonoX86 |  8.4779 ns | 0.0136 ns |
| BitHacks |      MonoX86 | 14.4434 ns | 0.0935 ns |
|   Simple |      MonoX64 |  8.2883 ns | 0.0590 ns |
| BitHacks |      MonoX64 |  2.8300 ns | 0.0101 ns |

A nice form:

<table class="table table-sm">
  <tr> <th></th>              <th>Simple</th>              <th>BitHacks</th>             </tr>
  <tr> <th>LegacyJIT-x86</th> <td class="norm">≈8.3ns</td> <td class="fast">≈2.6ns</td>  </tr>
  <tr> <th>LegacyJIT-x64</th> <td class="fast">≈2.6ns</td> <td class="fast">≈1.7ns</td>  </tr>
  <tr> <th>RyuJIT-x64   </th> <td class="norm">≈6.9ns</td> <td class="fast">≈1.5ns</td>  </tr>
  <tr> <th>Mono4.6.2-x86</th> <td class="norm">≈8.5ns</td> <td class="slow">≈14.4ns</td> </tr>
  <tr> <th>Mono4.6.2-x64</th> <td class="norm">≈8.3ns</td> <td class="fast">≈2.8ns</td>  </tr>
</table>

### Analysis

In the table, you can observe two performance mysteries:
1. `LegacyJIT-x64`+`Simple`: it works suspiciously quickly (the same order as in the `BitHacks` case).
2. `Mono4.6.2-x86`+`BitHacks`: it works slowly (`BitHacks` made the situation worse).

In other cases, `BitHacks` works 3–4 times faster than `Simple` which is nice.
Now let's look at the asm code of both methods in all cases.
The total listings are huge (because of the 32 same operations in each method), so we will look only at a single iteration.

#### LegacyJIT-x86

```x86asm
; Simple
mov         eax,dword ptr ds:[0089C8FCh]  
mov         ecx,3  
xor         edx,edx  
div         eax,ecx  
mov         dword ptr ds:[0089C8FCh],eax  
```

```x86asm
; BitHacks
mov         eax,dword ptr ds:[0089C8FCh]  
mov         edx,0AAAAAAABh  
mul         eax,edx  
mov         eax,edx  
shr         eax,1  
xor         edx,edx  
mov         dword ptr ds:[0089C8FCh],eax 
```

As usual, `LegacyJIT-x86` generates really simple code, no magic here.

#### RyuJIT-x64

```x86asm
; Simple
mov         ecx,3 ; Only before the first iteration  
xor         edx,edx  
div         eax,ecx  
mov         dword ptr [00007FFEEDB2338Ch],eax  
```

```x86asm
; BitHacks
and         eax,0FFFFFFFFh  
imul        rax,rdx  
shr         rax,21h  
and         eax,0FFFFFFFFh  
mov         dword ptr [00007FFEEDB2338Ch],eax 
```

`RyuJIT-x64` also generates simple code, but it's a little smarter than `LegacyJIT-x86`.
Here we keep the result in `eax` and only flush it to memory at the end of an iteration.
`LegacyJIT-x86` also loads value from memory to `eax` at the start of the iteration.

#### LegacyJIT-x64

```x86asm
; Simple
mov         ecx,dword ptr [7FFEEDB2338Ch]  
mov         eax,0AAAAAAABh  
mul         eax,ecx  
shr         edx,1  
mov         dword ptr [7FFEEDB2338Ch],edx 
```

```x86asm
; BitHacks
mov         eax,dword ptr [7FFEEDB2338Ch]  
mov         ecx,0AAAAAAABh  
imul        rax,rcx  
shr         rax,21h  
mov         dword ptr [7FFEEDB2338Ch],eax  
```

`LegacyJIT-x64` is smart enough to replace division by multiplication himself.
Therefore `LegacyJIT-x64`+`Simple` works fast (the first mystery solved).

#### Mono4.6.2-x64
```x86asm
<Simple>:
1c:  movabs $0x1cbc89a1880,%rax
23: 
26:  mov    (%rax),%eax
28:  mov    $0x3,%ecx
2d:  xor    %rdx,%rdx
30:  div    %ecx
32:  mov    %rax,%rcx
35:  movabs $0x1cbc89a1880,%rax
3c: 
3f:  mov    %ecx,(%rax)
```

```x86asm
<BitHacks>:
1c:  movabs $0x1cbc89a1880,%rax
23:
26:  mov    (%rax),%eax
28:  mov    %eax,%ecx
2a:  mov    $0xaaaaaaab,%eax
2f:  imul   %rax,%rcx
33:  shr    $0x21,%rcx
37:  shr    $0x0,%ecx
3a:  movabs $0x1cbc89a1880,%rax
41:
44:  mov    %ecx,(%rax)
```

The asm code produced by `Mono4.6.2-x64` doesn't look so smart, but it's still simple.
The performance results are almost the same as in the `LegacyJIT-x86` and `RyuJIT-x64` cases.

#### Mono4.6.2-x86
```x86asm
<Simple>:
 d:  mov    0x5dc638(%rip),%eax        # 5dc64b <Simple+0x5dc64b>
13:  mov    $0x3,%ecx
18:  xor    %edx,%edx
1a:  div    %ecx
1c:  mov    %eax,%ecx
1e:  mov    $0x5dc638,%eax
23:  mov    %ecx,(%rax)
```

For some reasons, it's not easy to show only one iteration from the original methods.
Therefore we look at the full listings of the following one-iteration version of the `BitHacks` benchmark:
```cs
public void BitHacks()
{
    x = initialValue;
    x = (uint)((x * (ulong)0xAAAAAAAB) >> 33);
}
```

And here is the listing:

```x86asm
<BitHacks>:
 0:  push   %rbp
 1:  mov    %esp,%ebp
 3:  push   %rdi
 4:  sub    $0x34,%esp
 7:  mov    0x8(%rbp),%eax
 a:  mov    %eax,-0x10(%rbp)
 d:  movl   $0x0,-0xc(%rbp)
14:  movl   $0xaaaaaaab,-0x18(%rbp)
1b:  movl   $0x0,-0x14(%rbp)
22:  mov    -0x14(%rbp),%eax
25:  mov    %eax,0xc(%rsp)
29:  mov    -0x18(%rbp),%eax
2c:  mov    %eax,0x8(%rsp)
30:  mov    -0xc(%rbp),%eax
33:  mov    %eax,0x4(%rsp)
37:  mov    -0x10(%rbp),%eax
3a:  mov    %eax,(%rsp)
3d:  callq  c2b9cee <BitHacks+0xc2b9cee>
42:  mov    %edx,-0xc(%rbp)
45:  mov    %eax,-0x10(%rbp)
48:  mov    0x10378794(%rip),%eax        # 103787e2 <BitHacks+0x103787e2>
4e:  mov    -0x10(%rbp),%ecx
51:  mov    %ecx,-0x18(%rbp)
54:  mov    -0xc(%rbp),%ecx
57:  mov    %ecx,-0x14(%rbp)
5a:  test   %eax,%eax
5c:  jne    a0 <BitHacks+0xa0>
5e:  jmp    6c <BitHacks+0x6c>
60:  mov    -0x20(%rbp),%eax
63:  mov    %eax,-0x18(%rbp)
66:  mov    -0x1c(%rbp),%eax
69:  mov    %eax,-0x14(%rbp)
6c:  mov    -0x18(%rbp),%eax
6f:  mov    %eax,-0x10(%rbp)
72:  mov    -0x14(%rbp),%eax
75:  mov    %eax,-0xc(%rbp)
78:  mov    -0xc(%rbp),%eax
7b:  shr    %eax
7d:  lea    -0x4(%rbp),%esp
80:  lea    -0x4(%rbp),%esp
83:  pop    %rdi
84:  leaveq 
85:  retq   
86:  sub    $0xc,%esp
89:  push   %rdi
8a:  nop
8b:  callq  fffffffffe9d6110 <BitHacks+0xfffffffffe9d6110>
90:  movl   $0x0,-0x10(%rbp)
97:  movl   $0x0,-0xc(%rbp)
9e:  jmp    60 <BitHacks+0x60>
a0:  lea    0x0(%rbp),%ebp
a3:  callq  fffffffffffc6ae4 <BitHacks+0xfffffffffffc6ae4>
a8:  mov    %eax,%ecx
aa:  mov    -0x18(%rbp),%edx
ad:  mov    %edx,-0x20(%rbp)
b0:  mov    -0x14(%rbp),%edx
b3:  mov    %edx,-0x1c(%rbp)
b6:  mov    %ecx,%edi
b8:  test   %eax,%eax
ba:  jne    86 <BitHacks+0x86>
bc:  jmp    60 <BitHacks+0x60>
```

It doesn't look as simple as previous listings.
`Mono4.6.2-x86` generates a huge amount of instructions which explains pure performance (the second mystery solved).
A detailed description of the generated code is beyond the scope of this post, but you can do it yourself as an another homework.
(*Hint: check out how `Mono4.6.2-x86` works with the `uint*ulong` operation.*)

### Conclusion

If you care about the performance of integer division, you should also care about your runtime and JIT compiler.
`LegacyJIT-x64` can apply the described optimization himself and produce fast code.
If you wrote such optimization manually, `Mono4.6.2-x86` will run it slowly because it has some troubles with the 64bit multiplication.

Please, don't make general conclusions about .NET, Mono, or a particular JIT compiler from this post.
Main idea of my performance exercises is to show how hard microbenchmarking can be.
If you are trying to measure operations which take nanoseconds, you should think about all the target environments.