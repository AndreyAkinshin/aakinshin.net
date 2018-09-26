---
layout: ru-post
title: "Сайд-эффект внутренней реализации List"
date: "2014-11-19"
lang: ru
type: post
tags:
- ".NET"
- C#
- List
- Bugs
redirect_from:
- /ru/blog/dotnet/list-version-side-effect/
- /ru/blog/post/list-version-side-effect/
---

Если вы делаете `foreach` по некоторому [List](http://msdn.microsoft.com/library/6sh2ey19.aspx)-у, то менять итерируемый лист внутри цикла крайне не рекомендуется, ведь это верный способ получить [InvalidOperationException](http://msdn.microsoft.com/library/system.invalidoperationexception.aspx). А теперь загадка: как думаете, что случится со следующим кодом:

```cs
var list = new List<int> { 0, 1, 2 };
foreach(var x in list)
{
  if (x == 0)
  {
    for (int i = int.MinValue; i < int.MaxValue; i++)
      list[0] = 0;
    list.Add(3);
  }
  Console.WriteLine(x);
}
```
<!--more-->
Правильный ответ: этот код замечательно отработает.	На консоли вы увидете:

```
0
1
2
3
```

Разгадка кроется во внутренней реализации класса List (см. реализацию в	[MS.NET](http://referencesource.microsoft.com/#mscorlib/system/collections/generic/list.cs)	и в
[Mono 3.10](https://github.com/mono/mono/blob/mono-3.10.0/mcs/class/corlib/System.Collections.Generic/List.cs)). При итерировании наш List должен как-то следить, не поменял ли его кто-нибудь внутри очередной итерации. Для этого используется приватное поле `_version`. При любой операции `_version` увеличивается на 1. При создании Enumerator-для цикла это значение [запоминается](http://referencesource.microsoft.com/#mscorlib/system/collections/generic/list.cs,1199), а при каждом вызове `MoveNext`
происходит [проверка](http://referencesource.microsoft.com/#mscorlib/system/collections/generic/list.cs,1224), что номер версии не поменялся. Если кто-то менял элементы коллекции, то [будет брошен](http://referencesource.microsoft.com/#mscorlib/system/collections/generic/list.cs,1225) [InvalidOperationException](http://msdn.microsoft.com/library/system.invalidoperationexception.aspx).

Но приведённый выше код отлично отрабатывает без всяких исключений. Как же так? Разгадка проста: для хранения `_version` используется тип `int`. А что будет, если `int`-переменную увеличить на `1` ровно <i>2 <sup>32</sup></i> раза? Она вернётся к своему исходному значению. В примере внутренний цикл (от	`int.MinValue` до `int.MaxValue`) изменяет бедный `_version` ровно <i>2 <sup>32</sup>-1</i> раз. А строчка `list.Add(3)` пополняет лист новым элементом и совершает финальный инкремент `_version`, который возвращает его к исходному значению. В результате при следующем вызове `MoveNext()` никто не подозревает, что мы что-то поменяли. Идеальное преступление.

Документация нам [говорит](http://msdn.microsoft.com/library/system.collections.ienumerator.movenext.aspx), что исключение должно быть брошено, если кто-то поменял коллекцию. Так что формально данный пример иллюстрирует небольшую .NET-багу. Впрочем, особо волноваться по этому поводу не стоит: вероятность наткнуться на подобную проблему реальной жизни достаточно мала. Закладываться на такое поведение и как-то его учитывать тоже не стоит, т.к. впоследствии оно может поменяться (например, `_version` сделают 64-битным).

### Ссылки

* [StackOverflow: Why this code throws 'Collection was modified' and when I iterate something before it, it doesn't?](http://stackoverflow.com/q/26718990/184842)