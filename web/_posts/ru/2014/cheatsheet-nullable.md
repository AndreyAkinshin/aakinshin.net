---
layout: ru-post
title: Nullable-арифметика
date: "2014-11-11"
lang: ru
type: post
tags:
- ".NET"
- Nullable
- C#
- CheatSheet
redirect_from:
- /ru/blog/dotnet/cheatsheet-nullable/
- /ru/blog/post/cheatsheet-nullable/
---

Что будет, если `null` поделить на ноль? А сколько будет `null | true`? А `null & true`? А `((string)null + null)`?

Практика подсказывает, что C#-разработчики зачастую не особо задумываются о том, как будут оцениваться выражения, если один из операндов равен `null`. Поэтому я решил составить небольшую шпаргалку на эту тему.<!--more-->

### Числа

Обычные арифметические операции с числами, в которых один из операндов равен `null`, всегда будут возвращать `null`. Т.е. если у нас имеется некоторый `X` типа `sbyte`, `byte`, `short`, `ushort`, `int`, `uint`, `long`, `ulong`, `char`, `float`, `double` или `decimal`, то для любых значений `X` работает нижеприведённая табличка. Даже если `X==0`, то выражения `null / X` и `null % X` всё равно вернут `null`.

```
+------------+-------+
| Expression | Value |
+------------+-------+
| X + null   | null  |
| X - null   | null  |
| X * null   | null  |
| X / null   | null  |
| X % null   | null  |
| null + X   | null  |
| null - X   | null  |
| null * X   | null  |
| null / X   | null  |
| null % X   | null  |
+------------+-------+
```

### Сравнения

Операции `<`, `<=`, `>`, `>=` всегда возвращают `false`, если один из операндов равен `null`. Операции `==` и `!=` работают так, как подсказывает логика.

```
+-------+-------+-------+-------+-------+-------+-------+-------+
|   X   |   Y   |  X<Y  | X<=Y  |  X>Y  | X>=Y  | X==Y  | X!=Y  |
+-------+-------+-------+-------+-------+-------+-------+-------+
| 0     | 0     | false | true  | false | true  | true  | false |
| 0     | null  | false | false | false | false | false | true  |
| null  | 0     | false | false | false | false | false | true  |
| null  | null  | false | false | false | false | true  | false |
+-------+-------+-------+-------+-------+-------+-------+-------+
```

### Логические операции

Логические операции `|`, `&`, `^` вызывают большее количество непонимания у людей. Проиллюстрируем булеву арифметику ещё одной табличной:

```
+-------+-------+-------+-------+-------+
|   X   |   Y   | X | Y | X & Y | X ^ Y |
+-------+-------+-------+-------+-------+
| false | false | false | false | false |
| false | true  | true  | false | true  |
| false | null  | null  | false | null  |
| true  | false | true  | false | true  |
| true  | true  | true  | true  | false |
| true  | null  | true  | null  | null  |
| null  | false | null  | false | null  |
| null  | true  | true  | null  | null  |
| null  | null  | null  | null  | null  |
+-------+-------+-------+-------+-------+
```

### Строки

В операциях конкатенации строк `null` всегда заменяется на пустую строчку. Таким образом,

```cs
"foo" + null == "foo"
(string)null + null + null == ""
```

### Ссылки

* [C# Language Specification](http://www.microsoft.com/downloads/en/details.aspx?FamilyID=DFBF523C-F98C-4804-AFBD-459E846B268E)		
  * 4.1.10 Nullable types
  * 6.1.4 Implicit nullable conversions
  * 6.2.3 Explicit nullable conversions
  * 7.3.7 Lifted operators
  * 7.8.4 Addition operator
  * 7.10.9 Equality operators and null
  * 7.11.4 Nullable boolean logical operators
* [MSDN: Using Nullable Types (C# Programming Guide)](http://msdn.microsoft.com/library/2cf62fcy.aspx)