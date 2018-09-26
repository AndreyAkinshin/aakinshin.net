---
layout: ru-post
title: "Про System.Drawing.Color и оператор =="
date: "2014-02-21"
lang: ru
type: post
tags:
- ".NET"
- Colors
- C#
- Equals
redirect_from:
- /ru/blog/dotnet/system-drawing-color-equals/
- /ru/blog/post/system-drawing-color-equals/
---

Для многих стандартных структур в .NET-е переопределён оператор `==`, который позволяет легко сравнивать ваши объекты. К сожалению, далеко не все задумываются о том, что на самом деле сравнивается при работе с этим замечательным оператором. В этой короткой заметке мы посмотрим логику сравнения объектов на примере `System.Drawing.Color`. Как вы думаете, что выведет следующий код:

```cs
var redName = Color.Red;
var redArgb = Color.FromArgb(255, 255, 0, 0);
Console.WriteLine(redName == redArgb);
```

<!--more-->

«И тут красный, и там красный. Наверное, объекты должны быть равны.», — подумает читатель. Но давайте откроем [исходный код](http://www.dotnetframework.org/default.aspx/Net/Net/3@5@50727@3053/DEVDIV/depot/DevDiv/releases/whidbey/netfxsp/ndp/fx/src/CommonUI/System/Drawing/Color@cs/1/Color@cs) и посмотрим на оператор `==`:

```cs
public static bool operator ==(Color left, Color right) {
    if (left.value == right.value
        && left.state == right.state
        && left.knownColor == right.knownColor) {

        if (left.name == right.name) {
            return true;
        }

        if (left.name == (object) null || right.name == (object) null) {
            return false;
        }

        return left.name.Equals(right.name);
    }

    return false;
}
```

Изучение исходного кода подталкивает нас к интересному выводу: цвета сравниваются не по ARGB-значанию, а по свойству Name. Какое же имя у наших объектов? Давайте посмотрим:

```cs
Console.WriteLine(redName.Name); // Red
Console.WriteLine(redArgb.Name); // ffff0000
```

Хм, имена-то разные. Таким образом, выражение `redName == redArgb` вернёт нам `False`. Неприятная ситуация может получиться, если, например, исходный `Color.Red` был сериализован в ARGB, затем десериализрован обратно, после чего вы вздумали сравнить итоговый цвет с оригиналом. Давайте почитаем, что [пишут](http://msdn.microsoft.com/en-us/library/system.drawing.color.op_equality(v=vs.110).aspx) про оператор `==` в [MSDN](http://msdn.microsoft.com/en-us/library/system.drawing.color.op_equality(v=vs.110).aspx):

> This method compares more than the ARGB values of the	[Color](http://msdn.microsoft.com/en-us/library/system.drawing.color(v=vs.110).aspx) structures. It also does a comparison of some state flags. If you want to compare just the ARGB values of two Color structures, compare them using the [ToArgb](http://msdn.microsoft.com/en-us/library/system.drawing.color.toargb(v=vs.110).aspx) method.

Ну, теперь всё понятно, для сравнения ARGB-значений наших цветов нам нужен метод `ToArgb`:

```cs
Console.WriteLine(redName.ToArgb() == redArgb.ToArgb()); // True
```

### Выводы

Я думаю, не следует полагаться на догадки о логике работы стандартных методов сравнения, которые изначально могут показаться вам очевидными. Если вы пользуетесь оператором == или методом Equals для значимых типов, то неплохо было бы сначала заглянуть в документацию и проверить, что именно будет сравниваться.