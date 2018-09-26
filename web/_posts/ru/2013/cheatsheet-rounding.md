---
layout: ru-post
title: "Учимся округлять в C#"
date: "2013-09-18"
lang: ru
type: post
tags:
- ".NET"
- C#
- Rounding
- CheatSheet
redirect_from:
- /ru/blog/dotnet/cheatsheet-rounding/
- /ru/blog/post/cheatsheet-rounding/
---

А знаете ли вы, что `Math.Round(1.5) == Math.Round(2.5) == 2`? Можете ли сходу сказать, сколько будет `-7%3` и `7%-3`? Помните ли, чем отличаются
`Math.Round`, `Math.Floor`, `Math.Ceiling`, `Math.Truncate`? А как происходит округление при использовании `string.Format`? Давайте немного погрузимся в мир округлений и разберёмся с нюансами, которые не для всех могут быть очевидными.<!--more-->

### Math.Round

MSDN:
[Round](http://msdn.microsoft.com/en-us/library/system.math.round.aspx)

```cs
public static decimal Round(decimal value)
public static double Round(double value)
public static decimal Round(decimal value, int digits)
public static double Round(double value, int digits)
public static decimal Round(decimal value, MidpointRounding mode)
public static double Round(double value, MidpointRounding mode)
public static decimal Round(decimal value, int digits, MidpointRounding mode)
public static double Round(double value, int digits, MidpointRounding mode)
```

`Math.Round` — это метод округления к ближайшему числу или к ближайшему числу с заданным количеством знаков после запятой. Работает с типами `decimal` и `double`, в параметрах можно встретить три вида параметров:

* `value`: округляемое число
* `digits`: количество знаков в дробной части, которые нужно оставить
* `mode`: параметр, который определяет в какую сторону округлять число, которое находится ровно посередине между двумя вариантами

Параметр `mode` используется, когда округляемое значение находится ровно посередине между двумя вариантами. Принимает значение из следующего перечисления:

```cs
public enum MidpointRounding { AwayFromZero, ToEven}
```

* `AwayFromZero`: округление происходит к тому числу, которое дальше от нуля.
* `ToEven`: округление происходит к чётному числу.

Обратите внимание, что по умолчанию `mode == MidpointRounding.ToEven`, поэтому `Math.Round(1.5) == Math.Round(2.5) == 2`.

### Math.Floor, Math.Ceiling, Math.Truncate

MSDN:
[Floor](http://msdn.microsoft.com/en-us/library/system.math.floor.aspx),
[Ceiling](http://msdn.microsoft.com/en-us/library/system.math.ceiling.aspx),
[Truncate](http://msdn.microsoft.com/en-us/library/system.math.truncate.aspx)

```cs
public static decimal Floor(decimal value)
public static double Floor(double value)
public static decimal Ceiling(decimal value)
public static double Ceiling(double value)
public static decimal Truncate(decimal value)
public static double Truncate(double value)
```

* `Math.Floor` округляет вниз по направлению к отрицательной бесконечности.
* `Math.Ceiling` округляет вверх по направлению к положительной бесконечности.
* `Math.Truncate` округляет вниз или вверх по направлению к нулю.


### Сводная таблица

Сориентироваться в методах округления может помочь следующая табличка:

```
value               | -2.9 | -0.5 | 0.3 | 1.5 | 2.9 |
--------------------+------+------+-----+-----+-----+
Round(ToEven)       |   -3 |    0 |   0 |   2 |   3 |
Round(AwayFromZero) |   -3 |   -1 |   0 |   2 |   3 |
Floor               |   -3 |   -1 |   0 |   1 |   2 |
Ceiling             |   -2 |    0 |   1 |   2 |   3 |
Truncate            |   -2 |    0 |   0 |   1 |   2 |
```

Округление проводится в соответствии со стандартом *IEEE Standard 754, section 4*.

### Целочисленное деление и взятие по модулю

В C# есть два замечательных оператора над целыми числами: `/` для целочисленного деления ([MSDN](http://msdn.microsoft.com/en-us/library/3b1ff23f.aspx)) и `%`
для взятия остатка от деления ([MSDN](http://msdn.microsoft.com/en-us/library/0w4e0fzs.aspx)). Деление производится по следующим правилам:

* При целочисленном делении результат всегда округляется по направлению к нулю.
* При взятии остатка от деления должно выполняться следующее правило: `x % y = x – (x / y) * y`

Также можно пользоваться шпаргалкой:

```
 a |  b | a/b | a%b |
---+----+-----+-----+
 7 |  3 |  2  |  1  |
-7 |  3 | -2  | -1  |
 7 | -3 | -2  |  1  |
-7 | -3 |  2  | -1  |
```

### string.Format

При форматировании чисел в виде строки можно пользоваться функцией `string.Format` (см. [Standard Numeric Format Strings](http://msdn.microsoft.com/en-us/library/dwhawy9k.aspx), [Custom Numeric Format Strings](http://msdn.microsoft.com/en-us/library/0c899ak8.aspx)). Например, для вывода числа с двумя знаками после десятичной точки можно воспользоваться `string.Format("{0:0.00}", value)` или `string.Format("{0:N2}", value)`. Округление происходит по принципу `AwayFromZero`. Проиллюстрируем правила округления очередной табличкой:

```
value  | string.Format("{0:N2}", value) |
-------+--------------------------------+
-2.006 | -2.01                          |
-2.005 | -2.01                          |
-2.004 | -2.00                          |
 2.004 |  2.00                          |
 2.005 |  2.01                          |
 2.006 |  2.01                          |
```

### Задачи

На приведённую тему есть две задачки в [ProblemBook.NET](http://problembook.net): [Rounding1](http://problembook.net/content/ru/Math/Rounding1-P.html), [Rounding2](http://problembook.net/content/ru/Math/Rounding2-P.html).