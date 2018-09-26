---
layout: ru-post
title: "LegacyJIT-x86 и первый вызов метода"
date: "2016-04-04"
lang: ru
type: post
tags:
- ".NET"
- C#
- JIT
- Benchmarks
redirect_from:
- /ru/blog/dotnet/legacyjitx86-and-first-method-call/
- /ru/blog/post/legacyjitx86-and-first-method-call/
---

Сегодня я расскажу вам об одном из моих любимых бенчмарков (данный метод не возвращает ничего полезного, он нам нужен только в качестве примера):

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

Интересный факт: если вы вызовете `Stopwatch.GetTimestamp()` перед первым вызовом метода `Sum`, то это увеличит скорость работы метода в несколько раз (фокус работает только для LegacyJIT-x86).

<!--more-->

### Исходный код и ASM

Рассмотрим две следующие программы (работаем на `x86`):

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

Единственное отличие между этими программами состоит в лишнем вызове `Stopwatch.GetTimestamp()`. А теперь взглянем на asm-код нашего цикла внутри метода `Sum`:

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

Оказывается, программа `ProgramA` хранит данные на стеке, а `ProgramB` хранит их в регистрах.

### Как так?

На самом деле в программе `ProgramB` мы можем вызвать `Stopwatch.IsHighResolution` или `Stopwatch.Frequency` вместо `Stopwatch.GetTimestamp()`. Главный момент заключается в том, что для достижения нужного эффекта нам необходимо неявно вызвать статический конструктор класса `Stopwatch`. Это повлияет на то, как экзеплярный конструктор `Stopwatch` будет обработан JIT-компилятором:

```x86asm
; Program A
;  var sw = new Stopwatch();
mov         ecx,71CDF3D4h  
call        005D30F4         ; базовая логика конструктора

mov         ecx,5E5F60h      ; !!! Тут мы должны проверить,
mov         edx,4F6h         ; !!! что статический конструктор
call        005D348C         ; !!! был вызван

; // заинлайненный Stopwatch::.ctor
mov         dword ptr [esi+4],0   ; elapsed = 0
mov         dword ptr [esi+8],0   ; elapsed = 0
mov         byte ptr [esi+14h],0  ; isRunning = false
mov         dword ptr [esi+0Ch],0 ; startTimeStamp = 0
mov         dword ptr [esi+10h],0 ; startTimeStamp = 0

; Program B
;  var sw = new Stopwatch();
mov         ecx,71CDF3D4h  
call        005D30F4         ; базовая логика конструктора

; // заинлайненный Stopwatch::.ctor
mov         dword ptr [esi+4],0   ; elapsed = 0
mov         dword ptr [esi+8],0   ; elapsed = 0
mov         byte ptr [esi+14h],0  ; isRunning = false
mov         dword ptr [esi+0Ch],0 ; startTimeStamp = 0
mov         dword ptr [esi+10h],0 ; startTimeStamp = 0
```

Как можно увидеть из листинга, у нас имеется два `call` для `ProgramA` и один `call` для `ProgramB`.

LegacyJIT-x86 использует количество `call`-ов в качестве одного из факторов для того, чтобы решить использовать ли регистры для локальных floating point-переменных или не использовать. Таким образом, мы получили разный asm-код для `ProgramA` и `ProgramB`.

### Бенчмарки

Но должна ли нас волновать эта разница? Как это влияет на производительность? Давайте забенчмаркаем! Я написал следующий бенчмарк для оценки ситуации (основано на [BenchmarkDotNet](https://github.com/PerfDotNet/BenchmarkDotNet) v0.9.4):

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

Результаты:

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

Получается так, что вызов `Stopwatch.GetTimestamp()` перед первым вызовом метода `Sum` увеличил скорость работы в 3.5 раза!

### Заключение

Производительность — тема сложная. Бенчмаркинг — тема очень сложная. Постараюсь сформулировать мораль данной истории:

* В общем случае мы не можем просто так взять метод без контекста и начать рассуждать о его производительности, ведь его asm-код может зависеть от состояния CLR в момент первого вызова (однако, на практике это редко имеет значение).
* Бенчмарки могут влиять друг на друга (не только из-за статических конструкторов; например, имеют большое значение самонастраиваемый сборщик мусора и диспатчинг интерфейсных методов). Поэтому хорошей практикой является запуск каждого бенчмарк-метода в отдельном процессе ([BenchmarkDotNet](https://github.com/PerfDotNet/BenchmarkDotNet) так и делает) .
* Очень легко сделать ошибку в самописном бенчмарке. Если бы мы писали руками бенчмарк для метода `Sum`, то лишний случайный вызов метода класса `Stopwatch` в корне бы изменил результаты нашего маленького эксперимента.

### См. также

* [Stackoverflow: Weird performance increase in simple benchmark](http://stackoverflow.com/questions/32114308/weird-performance-increase-in-simple-benchmark)
* [MSDN: Static Constructors](https://msdn.microsoft.com/en-us/library/k9x6w0hc.aspx)