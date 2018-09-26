---
layout: post
title: "RyuJIT CTP5 and loop unrolling"
date: "2015-03-01"
lang: en
type: post
tags:
- ".NET"
- C#
- JIT
- RyuJIT
- LoopUnrolling
redirect_from:
- /en/blog/dotnet/ryujit-ctp5-and-loop-unrolling/
- /blog/post/ryujit-ctp5-and-loop-unrolling/
---

RyuJIT will be available soon. It is a next generation JIT-compiler for .NET-applications. Microsoft likes to tell us about the benefits of SIMD using and JIT-compilation time reducing. But what about basic code optimization which is usually applying by a compiler? Today we talk about the loop unrolling (unwinding) optimization. In general, in this type of code optimization, the code

```cs
for (int i = 0; i < 1024; i++)
    Foo(i);
```

transforms to

```cs
for (int i = 0; i < 1024; i += 4)
{
    Foo(i);
    Foo(i + 1);
    Foo(i + 2);
    Foo(i + 3);
}
```

Such approach can significantly increase performance of your code. So, what's about loop unrolling in .NET?

<!--more-->

### Common theory

First of all, let's talk about how loop unrolling affects to our applications.

#### Advantages

* We are reducing the number of machine commands (iterator increments).
* Reduced overheads of [branch prediction](https://en.wikipedia.org/wiki/Branch_predictor).
* We increase the possibility of using [instruction-level parallelism](https://en.wikipedia.org/wiki/Instruction-level_parallelism).
* We can apply additional code improvements in conjunction with other optimizations (e. g. , [inlining](http://en.wikipedia.org/wiki/Inline_expansion)).

#### Disadvantages

* The source code size increased.
* Sometimes, due to the increasing size of the instruction amount, it is impossible to simultaneously apply loop unrolling and inlining.
* Possible [cache misses](http://en.wikipedia.org/wiki/CPU_cache#Cache_miss) in the commands cache.
* Possible increased register usage in a single iteration (we may not have enough registers, other optimizations can not apply because of registers deficit).
* If there is branching in the iteration, loop unrolling can adversely affect to other optimizations.

#### Conclusion

Loop unrolling is a very powerful tool for optimization, but only if we use it wisely. I don't recommended apply it yourself: it will reduce the readability of the source code and it can adversely affect to use other optimizations. It is best to leave this approach to the compiler. It is important that your compiler could do loop unrolling competently.

### Experiments

#### Source code

We will work with a very simple loop which is very easy to unroll:

```cs
int sum = 0;
for (int i = 0; i < 1024; i++)
    sum += i;
Console.WriteLine(sum);
```

Note, the amount of iterations is known beforehand and it is equal to 2<sup>10</sup>. It is very important because it greatly simplifies usage of the considered optimization.

#### JIT-x86

Let's run the code with JIT-x86 and look to the assembler code:

```
        int sum = 0;                    
00EE0052  in          al,dx             
00EE0053  push        esi               
00EE0054  xor         esi,esi           
        for (int i = 0; i < 1024; i++)  
00EE0056  xor         eax,eax           
            sum += i;                   
00EE0058  add         esi,eax           ; sum += i
        for (int i = 0; i < 1024; i++)  
00EE005A  inc         eax               ; i++
00EE005B  cmp         eax,400h          
00EE0060  jl          00EE0058          
```

As you can see, JIT-x86 didn't apply loop unrolling. You should understood, the 32-bit version of JIT-compiler is quite primitive. JIT-x86 apply loop unrolling rarely, only if specific conditions are satisfied.

#### JIT-x64

Next, try the experiment with the 64-bit version of JIT-compiler:

```
        int sum = 0;                               
00007FFCC8710090  sub         rsp,28h              
        for (int i = 0; i < 1024; i++)             
00007FFCC8710094  xor         ecx,ecx              
00007FFCC8710096  mov         edx,1                ; edx = i + 1
00007FFCC871009B  nop         dword ptr [rax+rax]  
00007FFCC87100A0  lea         eax,[rdx-1]          ; eax = i
            sum += i;                              
00007FFCC87100A3  add         ecx,eax              ; sum += i
00007FFCC87100A5  add         ecx,edx              ; sum += i + 1
00007FFCC87100A7  lea         eax,[rdx+1]          ; eax = i + 2
00007FFCC87100AA  add         ecx,eax              ; sum += i + 2;
00007FFCC87100AC  lea         eax,[rdx+2]          ; eax = i + 3
00007FFCC87100AF  add         ecx,eax              ; sum += i + 3;
00007FFCC87100B1  add         edx,4                ; i += 4
        for (int i = 0; i < 1024; i++)             
00007FFCC87100B4  cmp         edx,401h             
00007FFCC87100BA  jl          00007FFCC87100A0     
```

As you can see, loop unrolling have been applied, the loop body repeated 4 times. JIT-x64 is able to repeat the loop body 2, 3 or 4 times (it depends on the amount of iterations). Unfortunately, if there are no 2, 3, 4 in the set of iterations amount divisors, loop unrolling will not be applied.

#### RyuJIT

What's about new RyuJIT? Let's look to the assembler code:

```
        int sum = 0;                            
00007FFCC86E0091  sub         rsp,20h           
00007FFCC86E0095  xor         esi,esi           
        for (int i = 0; i < 1024; i++)          
00007FFCC86E0097  xor         eax,eax           
            sum += i;                           
00007FFCC86E0099  add         esi,eax           ; sum += i
        for (int i = 0; i < 1024; i++)          
00007FFCC86E009B  inc         eax               ; i++
00007FFCC86E009D  cmp         eax,400h          
00007FFCC86E00A2  jl          00007FFCC86E0099  
```

A sad situation: RyuJIT can't unroll even the simplest loop. The cause is the following: RyuJIT is based off of the same codebase as JIT-x86 (see: [RyuJIT: The next-generation JIT compiler for .NET](http://blogs.msdn.com/b/dotnet/archive/2013/09/30/ryujit-the-next-generation-jit-compiler.aspx)).

### Summary

RyuJIT allows us to use SIMD-instructions and reduces the JIT compilation time. Unfortunately, the performance of the resulted code with the transition to the new JIT can reduce. Note, there is no the final RuyJIT, the experiment was conducted for CTP5. Let's hope that the RyuJIT release will include smart code optimizations.

### Links

* [Unrolling of small loops in different JIT versions](http://aakinshin.net/en/blog/dotnet/unrolling-of-small-loops-in-different-jit-versions/)
* [Wikipedia: Loop unrolling](http://en.wikipedia.org/wiki/Loop_unrolling)
* [J. C. Huang, T. Leng, Generalized Loop-Unrolling: a Method for Program Speed-Up (1998)](https://www.researchgate.net/publication/2449271_Generalized_Loop-Unrolling_a_Method_for_Program_Speed-Up)
* [Wikipedia: Branch prediction](https://en.wikipedia.org/wiki/Branch_predictor)
* [Wikipedia: Instruction-level parallelism](https://en.wikipedia.org/wiki/Instruction-level_parallelism)
* [Wikipedia: Inline expansion](http://en.wikipedia.org/wiki/Inline_expansion)
* [Wikipedia: Cache miss](http://en.wikipedia.org/wiki/CPU_cache#Cache_miss)
* [StackOverflow: http://stackoverflow.com/questions/2349211/when-if-ever-is-loop-unrolling-still-useful](http://stackoverflow.com/questions/2349211/when-if-ever-is-loop-unrolling-still-useful)
* [Blogs.Msdn: RyuJIT: The next-generation JIT compiler for .NET](http://blogs.msdn.com/b/dotnet/archive/2013/09/30/ryujit-the-next-generation-jit-compiler.aspx)