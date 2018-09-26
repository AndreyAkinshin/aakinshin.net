---
layout: ru-post
title: "Определение версии JIT в рантайме"
date: "2015-02-28"
lang: ru
type: post
tags:
- ".NET"
- C#
- JIT
redirect_from:
- /ru/blog/dotnet/jit-version-determining-in-runtime/
- /ru/blog/post/jit-version-determining-in-runtime/
---

Иногда мне в моих маленьких C#-экспериментах нужно определять версию используемого JIT-компилятора. Понятно, что её можно определить заранее исходя из окружения. Но порой мне хочется знать её в рантайме, чтобы выполнять специфичный код для текущего JIT-компилятора. Строго говоря, я хочу получать значение из следующего перечисления:

```cs
public enum JitVersion
{
    Mono, MsX86, MsX64, RyuJit
}
```

Я могу легко определить, что работаю под Mono, по наличию класса `Mono.Runtime`. Если это не так, то можно считать, что мы работаем с JIT от Microsoft. JIT-x86 легко узнать с помощью `IntPtr.Size == 4`. А вот чтобы отличить старый JIT-x64 от нового RyuJIT необходимо немного призадуматься. Далее я покажу, как это можно сделать с помощью бага JIT-x64, который я описывал в [предыдущем посте](http://aakinshin.net/ru/blog/dotnet/subexpression-elimination-bug-in-jit-x64/).

<!--more-->

Сначала приведу тривиальный код, который поможет нам опознать версии `JitVersion.Mono` и `JitVersion.MsX86`:

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

Теперь научимся определять `JitVersion.MsX64`. Для этого проверим наличие [JIT-x64 sub-expression elimination optimizer bug](http://aakinshin.net/ru/blog/dotnet/subexpression-elimination-bug-in-jit-x64/). Обратите внимание, что программа должна быть скомпилирована с включёнными оптимизациями.

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

В рамках данной задачи мы работаем с ограниченным набором JIT-компиляторов. Поэтому RyuJIT можно опознать методом исключения:

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

Всё готово! Напишем простую программу, в которой определим версию JIT:

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

Отлично, класс готов к использованию! Полный код также доступен на Gist: [JitVersionInfo.cs](https://gist.github.com/AndreyAkinshin/0506ad10faf0c2a7b1cb).

### Замечания

* Метод определения MsX64 vs RyuJIT работает только с включёнными оптимизациями.
* Данная программа работает с ограниченными набором версий JIT, могут быть проблемы на нестандартных версиях .NET.
* Мигель обещал, что Mono 4 будет работать на CoreCLR, что означает использование RyuJIT.

### Ссылки

* [История про баг в JIT-x64](http://aakinshin.net/ru/blog/dotnet/subexpression-elimination-bug-in-jit-x64/)
* [StackOverflow: How to detect which .NET runtime is being used (MS vs. Mono)?](http://stackoverflow.com/q/721161/184842)
* [StackOverflow: How do I verify that ryujit is jitting my app?](http://stackoverflow.com/q/22422021/184842)