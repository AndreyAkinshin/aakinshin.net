---
layout: ru-post
title: List.ForEach в .NET 4.5
date: "2014-11-24"
lang: ru
type: post
tags:
- ".NET"
- ".NET-4.5"
- Loops
- List
redirect_from:
- /ru/blog/dotnet/listforeach-net-45/
- /ru/blog/post/listforeach-net-45/
---

Продолжим обсуждать [тему](http://aakinshin.blogspot.ru/2014/11/dotnet-list-version-side-effect.html) изменения коллекции внутри цикла `foreach`. Следующий код

```cs
var list = new List<int> { 1, 2 };
foreach (var i in list)
{
    if (i == 1)
        list.Add(3);
    Console.WriteLine(i);
}
```

выбросит `InvalidOperationException`. А как думаете, что случится при выполнении цикла через [List&lt;T&gt;.ForEach](http://msdn.microsoft.com/library/bwabdf9z.aspx)?


```cs
var list = new List<int> { 1, 2 };
list.ForEach(i =>
{
    if (i == 1)
        list.Add(3);
    Console.WriteLine(i);
});
```


Правильный ответ: зависит.<!--more--> Ранее (.NET 4.0) данный код замечательно отрабатывал и выводил `1 2 3`. Это было не очень хорошо. Поэтому в .NET 4.5 поведение поменялось, `ForEach` начал бросать `InvalidOperationException` для случая, если кто-то внутри цикла менял коллекцию:

```cs
public void ForEach(Action<T> action) {
  if( action == null) { 
    ThrowHelper.ThrowArgumentNullException(ExceptionArgument.match);
  } 
  Contract.EndContractBlock();

  int version = _version;

  for(int i = 0 ; i < _size; i++) {
    if (version != _version && BinaryCompatibility.TargetsAtLeast_Desktop_V4_5) { 
      break; 
    }
    action(_items[i]); 
  }

  if (version != _version && BinaryCompatibility.TargetsAtLeast_Desktop_V4_5)
    ThrowHelper.ThrowInvalidOperationException(
        ExceptionResource.InvalidOperation_EnumFailedVersion); 
}
```

<span style="text-decoration: line-through;">Что касается Mono, то в нём никаких исключение не бросается (даже в последнем стабильном на текущий момент Mono 3.10).</span> Когда я узнал, что в Mono 3.10 всё плохо, то очень расстроился. А потом пошёл и завёл [баг-репорт](https://bugzilla.xamarin.com/show_bug.cgi?id=24775). Вскоре баг был [исправлен](https://github.com/mono/mono/commit/5517c56afa66f4d54575b01adb86fe1577128c01).

А в старых версий (например, 2.10) был [баг](http://lists.ximian.com/pipermail/mono-bugs/2011-June/112085.html), в результате которого исключение не происходило даже внутри обычного `foreach`, если коллекцию менять через индексатор ([ideone](http://ideone.com/A3DbN)):

```cs
using System;
using System.Collections.Generic;

namespace test
{
    public class test
    {
        public static void Main()
        {
            List x = new List();
            x.Add(1);
            x.Add(4);
            x.Add(9);
            foreach(int i in x){
                x[2] = 3;
            }
            foreach(int i in x){
                System.Console.WriteLine(i);
            }
        }
    }
}

Actual Results (Mono 2.10):
1
4
3
```

### Ссылки

* [.NET Web Development and Tools Blog: All about : All about &lt;httpRuntime targetFramework&gt;](http://blogs.msdn.com/b/webdev/archive/2012/11/19/all-about-httpruntime-targetframework.aspx)
* [.NET Framework Blog: .NET Framework 4.5 – Off to a great start](http://blogs.msdn.com/b/dotnet/archive/2012/10/17/net-framework-4-5-off-to-a-great-start.aspx)
* [ItDepends.NET: ListForEach](https://github.com/AndreyAkinshin/ItDepends.NET/tree/master/ListForEach)
* [MSDN: InvalidOperationException](http://msdn.microsoft.com/library/system.invalidoperationexception.aspx)
* [Mono Bug 699182: Modifications to a Collection via indexer during foreach should throw InvalidOperationException](http://lists.ximian.com/pipermail/mono-bugs/2011-June/112085.html)
* [Mono Bug 24775: List.ForEach does not throw InvalidOperationException when collection was modified](https://bugzilla.xamarin.com/show_bug.cgi?id=24775)