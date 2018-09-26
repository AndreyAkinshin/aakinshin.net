---
layout: ru-post
title: "Недокументированные ключевые слова C# или превращаем объект в тыкву"
date: "2013-08-26"
lang: ru
type: post
tags:
- ".NET"
- C#
- IL
- Benchmarking
redirect_from:
- /ru/blog/dotnet/undocumented-keywords-in-cs/
- /ru/blog/post/undocumented-keywords-in-cs/
---

Стандартный компилятор C# поддерживает 4 недокументированных ключевых слова: `__makeref`, `__reftype`, `__refvalue`, `__arglist`. Эти слова даже успешно распознаются в Visual Studio (хотя, ReSharper на них ругается). Они не даром исключены из стандарта — их использование может повлечь серьёзные проблемы с безопасностью. Поэтому не нужно их использовать везде подряд, но в отдельных исключительных случаях они могут пригодиться. В этом посте я обсужу предназначение недокументированных команд, рассмотрю вопросы их производительности и научусь превращать объект в тыкву.<!--more-->

### Описание ключевых слов

Все рассматриваемые слова связаны со структурой [TypedReference](http://msdn.microsoft.com/en-us/library/system.typedreference.aspx). Она хранит в себе два поля: указатель на область памяти и тип данных объекта, который расположен по этому указателю. Помимо рассмотренных ниже ключевых слов для операций над этой структурой могут пригодиться методы
[GetTargetType](http://msdn.microsoft.com/en-us/library/system.typedreference.gettargettype.aspx),
[MakeTypedReference](http://msdn.microsoft.com/en-us/library/system.typedreference.maketypedreference.aspx),
[SetTypedReference](http://msdn.microsoft.com/en-us/library/system.typedreference.settypedreference.aspx),
[TargetTypeToken](http://msdn.microsoft.com/en-us/library/system.typedreference.targettypetoken.aspx),
[ToObject](http://msdn.microsoft.com/en-us/library/system.typedreference.toobject.aspx).

Теперь перейдём непосредственно к ключевым словам. `__makeref` принимает на входе объект и возвращает `TypedReference` ссылку на него. `__reftype` и `__refvalue`
способны достать из `TypedReference` значения двух его полей: тип и значение. Посмотрим простой пример, который поясняет использование ключевых слов:

```
double value = 10;
TypedReference typedReference = __makeref(value); // typedReference = &value;
Console.WriteLine( __refvalue(typedReference, double)); // 10
__refvalue(typedReference, double) = 11; // *typedReference = 11
Console.WriteLine( __refvalue(typedReference, double)); // 11
Type type = __reftype(typedReference); // value.GetType()
Console.WriteLine(type.Name); // Double
```

Данный пример развернётся в IL-код, который представлен ниже. Как можно понять, рассмотренные ключевые слова транслируются в IL-команды `mkrefany` , `refanyval` ,
`refanytype`.

```
.maxstack 2
.locals init (
    [0] float64 'value',
    [1] valuetype [mscorlib]System.TypedReference typedReference,
    [2] class [mscorlib]System.Type 'type')
L_0000: ldc.r8 10
L_0009: stloc.0 
L_000a: ldloca.s 'value'
L_000c: mkrefany float64
L_0011: stloc.1 
L_0012: ldloc.1 
L_0013: refanyval float64
L_0018: ldind.r8 
L_0019: call void [mscorlib]System.Console::WriteLine(float64)
L_001e: ldloc.1 
L_001f: refanyval float64
L_0024: ldc.r8 11
L_002d: stind.r8 
L_002e: ldloc.1 
L_002f: refanyval float64
L_0034: ldind.r8 
L_0035: call void [mscorlib]System.Console::WriteLine(float64)
L_003a: ldloc.1 
L_003b: refanytype 
L_003d: call class [mscorlib]System.Type 
          [mscorlib]System.Type::GetTypeFromHandle
          (valuetype [mscorlib]System.RuntimeTypeHandle)
L_0042: stloc.2 
L_0043: ldloc.2 
L_0044: callvirt instance string 
          [mscorlib]System.Reflection.MemberInfo::get_Name()
L_0049: call void [mscorlib]System.Console::WriteLine(string)
L_004e: ret 
```

`__arglist` позволяет создать метод с переменным количеством параметров. Причём это не передача массива объектов через `params`, а в чистом виде переменное количество параметров. Получить переданные значения можно через структуру [ArgIterator](http://msdn.microsoft.com/en-us/library/system.argiterator.aspx). Ниже приведён пример, который иллюстрирует использование команды.

```
public void Run()
{
    Foo(__arglist(1, 2.0, "3", new int[0]));
}

public void Foo(__arglist)
{
    var iterator = new ArgIterator(__arglist);
    while (iterator.GetRemainingCount() > 0)
    {
        TypedReference typedReference = iterator.GetNextArg();
        Console.WriteLine("{0} / {1}", 
            TypedReference.ToObject(typedReference), 
            TypedReference.GetTargetType(typedReference));
    }
}
```

И соответствующий IL-код, в котором можно познакомиться с командой `arglist`:

```
.method public hidebysig instance void Run() cil managed
{
.maxstack 8
L_0000: ldarg.0 
L_0001: ldc.i4.1 
L_0002: ldc.r8 2
L_000b: ldstr "3"
L_0010: ldc.i4.0 
L_0011: newarr int32
L_0016: call instance vararg void Program::Foo(..., int32, float64, string)
L_001b: ret 
}

.method public hidebysig instance vararg void Foo() cil managed
{
.maxstack 3
.locals init (
    [0] valuetype [mscorlib]System.ArgIterator iterator,
    [1] valuetype [mscorlib]System.TypedReference typedReference)
L_0000: ldloca.s iterator
L_0002: arglist 
L_0004: call instance void 
          [mscorlib]System.ArgIterator::.ctor
          (valuetype [mscorlib]System.RuntimeArgumentHandle)
L_0009: br.s L_0029
L_000b: ldloca.s iterator
L_000d: call instance valuetype 
          [mscorlib]System.TypedReference 
          [mscorlib]System.ArgIterator::GetNextArg()
L_0012: stloc.1 
L_0013: ldstr "{0} / {1}"
L_0018: ldloc.1 
L_0019: call object [mscorlib]System.TypedReference::ToObject
          (valuetype [mscorlib]System.TypedReference)
L_001e: ldloc.1 
L_001f: call class [mscorlib]System.Type 
          [mscorlib]System.TypedReference::GetTargetType
          (valuetype [mscorlib]System.TypedReference)
L_0024: call void [mscorlib]System.Console::WriteLine(string, object, object)
L_0029: ldloca.s iterator
L_002b: call instance int32 [mscorlib]System.ArgIterator::GetRemainingCount()
L_0030: ldc.i4.0 
L_0031: bgt.s L_000b
L_0033: ret 
}
```

### Поговорим о производительности

На StackOverflow есть [обсуждение](http://stackoverflow.com/questions/4764573/why-is-typedreference-behind-the-scenes-its-so-fast-and-safe-almost-magical), в котором утверждается, что якобы работа с `TypedReference` осуществляется быстрее, чем упаковка/распаковка. Но бенчмарк у автора очень странный. Плюс, как мне кажется, автор запускал его в Debug mode with debugging — в этом случае действительно могут получиться такие результаты. Но некоторые люди писали в комментариях, что на самом деле упаковка/распаковка работает намного быстрее. Я решил проверить это, составив бенчмарк с помощью [BenchmarkDotNet](https://github.com/dotnet/BenchmarkDotNet) v0.5.1 (**Update:** данный пост был написан в 2013 году, в ту пору BenchmarkDotNet только начинал развиваться. С тех пор библиотека была значительно доработана, API был изменён.):

```cs
private const int IterationCount = 10000000;
private int[] array;

public void Run()
{
    array = new int[5];

    var competition = new BenchmarkCompetition();
    competition.AddTask("MakeRef", MakeRef);
    competition.AddTask("Boxing", Boxing);
    competition.Run();
}

public void MakeRef()
{
    for (int i = 0; i < IterationCount; i++)
        Set1(array, 0, i);
}

public void Boxing()
{
    for (int i = 0; i < IterationCount; i++)
        Set2(array, 0, i);
}

public void Set1(T[] a, int i, int v)
{
    __refvalue(__makeref(a[i]), int) = v;
}

public void Set2(T[] a, int i, int v)
{
    a[i] = (T)(object)v;
}
```

Не забывайте, что бенчмарки нужно запускать только в **Release mode without debugging**. Результаты, которые получились на моём ноутбуке:

```
MakeRef : 313ms
Boxing  :  34ms
```

У нас имеются классы `MyObject`, который содержит одно поле на 64 бита, и `Pumpkin`, который содержит два поля по 32 бита. В методе Run выполняются следующие вещи: мы создаём объект `myObject`, инициализируем его поле, получаем на него ссылку, а затем создаём `pumpkin`, который ссылается на ту же область памяти. В качестве теста мы пробуем поменять значение 64-х битного поля изначально объекта и смотрим на изменение соответствующих полей в тыкве.

Особый интерес представляют методы `GetAddress` и `Convert<T>` . Начнём с первого: он получает указатель `IntPtr` на переданный объект. В первой строчке всё просто: мы получаем `TypedReference` на переданный объект, а вот во второй строчке происходит немного магии. Первое поле `TypedReference` хранит `IntPtr` -ссылку на наш объект, но явно мы получить эту ссылку не можем. Поэтому мы получаем указатель на наш `TypedReference` (который также является указателем на его первое поле), приводим его к указателю на `IntPtr` , а потом разыменовываем. В итоге имеем своего рода неуправляемое получение адреса объекта.

А теперь переходим к методу `Convert<T>`. Этот метод должен нам создать объект типа `T`, который ссылается на заданную область памяти. В первой строке мы создаём дефолтный экземпляр типа `T` . Единственное его предназначение — это получить соответствующий `typedReference`, который создаётся во второй строчке. Второе поле полученной структуры указывает на нужный нам тип. Третьей строчкой мы записываем переданный нам адрес в первое поле структуры с помощью уже знакомой нам конструкции
`*(IntPtr*)(&typedReference)` . И в последней четвёртой строчке мы собираем из нашей `typedReference` структуры готовый объект целевого типа с помощью `__refvalue`
. Вуаля: тыква готова.

**P.S. Приведённый пример имеет чисто академическое предназначение, он приведён как демонстрация использования заявленных ключевых слов. В продакшн-коде нужно несколько раз подумать, прежде чем решить, что вам действительно необходимы подобные конструкции.**