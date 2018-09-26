---
layout: post
title: "JIT version determining in runtime"
date: "2015-02-28"
lang: en
type: post
tags:
- ".NET"
- C#
- JIT
redirect_from:
- /en/blog/dotnet/jit-version-determining-in-runtime/
- /blog/post/jit-version-determining-in-runtime/
---

Sometimes I want to know used JIT compiler version in my little C# experiments. It is clear that it is possible to determine the version in advance based on the environment. However, sometimes I want to know it in runtime to perform specific code for the current JIT compiler. More formally, I want to get the value from the following enum:

```cs
public enum JitVersion
{
    Mono, MsX86, MsX64, RyuJit
}
```

It is easy to detect Mono by existing of the `Mono.Runtime` class. Otherwise, we can assume that we work with Microsoft JIT implementation. It is easy to detect JIT-x86 with help of `IntPtr.Size == 4`. The challenge is to distinguish JIT-x64 and RyuJIT. Next, I will show how you can do it with help of the bug from my [previous post](http://aakinshin.net/en/blog/dotnet/subexpression-elimination-bug-in-jit-x64/).

<!--more-->

First of all, I show a trivial code that helps us to detect the `JitVersion.Mono` and `JitVersion.MsX86` versions:

```cs
public static bool IsMono()
{
    return Type.GetType("Mono.Runtime") != null;
}

public static bool IsMsX86()
{
    return !IsMono() && IntPtr.Size == 4;
}
```

Next, we will learn to detect `JitVersion.MsX64`. We will use [the JIT-x64 sub-expression elimination optimizer bug](http://aakinshin.net/en/blog/dotnet/subexpression-elimination-bug-in-jit-x64/) for this purpose. Note, that you should compile the program with enabled optimizations.

```cs
private int bar;

private bool IsMsX64(int step = 1)
{
    var value = 0;
    for (int i = 0; i < step; i++)
    {
        bar = i + 10;
        for (int j = 0; j < 2 * step; j += step)
            value = j + 10;
    }
    return value == 20 + step;
}
```

In this post, we work with a limited set of JIT-compiler. Therefore RyuJIT can be identified by the elimination method:

```cs
public JitVersion GetJitVersion()
{
    if (IsMono())
        return JitVersion.Mono;
    if (IsMsX86())
        return JitVersion.MsX86;
    if (IsMsX64())
        return JitVersion.MsX64;
    return JitVersion.RyuJit;
}
```

Everything is ready! Let's write a simple program, which determine the JIT version in runtime:

```cs
using System;

class Program
{
    public enum JitVersion
    {
        Mono, MsX86, MsX64, RyuJit
    }

    public class JitVersionInfo
    {
        public JitVersion GetJitVersion()
        {
            if (IsMono())
                return JitVersion.Mono;
            if (IsMsX86())
                return JitVersion.MsX86;
            if (IsMsX64())
                return JitVersion.MsX64;
            return JitVersion.RyuJit;
        }

        private int bar;

        private bool IsMsX64(int step = 1)
        {
            var value = 0;
            for (int i = 0; i < step; i++)
            {
                bar = i + 10;
                for (int j = 0; j < 2 * step; j += step)
                    value = j + 10;
            }
            return value == 20 + step;
        }

        public static bool IsMono()
        {
            return Type.GetType("Mono.Runtime") != null;
        }

        public static bool IsMsX86()
        {
            return !IsMono() && IntPtr.Size == 4;
        }
    }

    static void Main()
    {
        Console.WriteLine("Current JIT version: " + new JitVersionInfo().GetJitVersion());
    }
}
```

The class is ready to use! The complete code is also available on Gist: [JitVersionInfo.cs](https://gist.github.com/AndreyAkinshin/0506ad10faf0c2a7b1cb).

### Notes

* Method of distinguish MsX64 and RyuJIT works only with enabled optimizations.
* The approach works with a limited set of JIT versions, you can have troubles with non-standard .NET versions.
* Miguel have promised that Mono 4 will work on CoreCLR which means RyuJIT.

### Links

* [A bug story about JIT-x64](http://aakinshin.net/en/blog/dotnet/subexpression-elimination-bug-in-jit-x64/)
* [StackOverflow: How to detect which .NET runtime is being used (MS vs. Mono)?](http://stackoverflow.com/q/721161/184842)
* [StackOverflow: How do I verify that ryujit is jitting my app?](http://stackoverflow.com/q/22422021/184842)