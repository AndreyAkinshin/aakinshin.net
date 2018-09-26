---
layout: ru-post
title: Jon Skeet's Quiz
date: "2013-11-03"
lang: ru
type: post
tags:
- ".NET"
- C#
redirect_from:
- /ru/blog/dotnet/jon-skeet-quiz/
- /ru/blog/post/jon-skeet-quiz/
---

Однажды Джона Скита попросили сформулировать три интересных вопроса на знание C#. Он спросил следующее ([оригинал вопросника](http://www.dotnetcurry.com/magazine/jon-skeet-quiz.aspx),	[перевод статьи](http://timyrguev.blogspot.ru/2013/10/blog-post.html)):

* **Q1.** *Вызов какого конструктора можно использовать, чтобы следующий код вывел True (хотя бы в реализации Microsoft.NET)?*

```cs
object x = new /* fill in code here */;
object y = new /* fill in code here */;
Console.WriteLine(x == y);
```

*Учтите, что это просто вызов конструктора, вы не можете поменять тип переменных.*

* **Q2.** *Как сделать так, чтобы следующий код вызывал три различных перегрузки метода?*

```cs
void Foo()
{
    EvilMethod<string>();
    EvilMethod<int>();
    EvilMethod<int?>();
}
```

* **Q3.** *Как заставить следующий код выбросить исключение во второй строчке с помощью локальной переменной (без хитрого изменения её значения)?*

```cs
string text = x.ToString(); // No exception
Type type = x.GetType(); // Bang!
```

Вопросы показались мне интересными, поэтому я решил обсудить их решения.<!--more-->

---

* **A1-1.**

Одним из самых простых способов является использование [Nullable](http://msdn.microsoft.com/en-us/library/1t3y8s4s(v=vs.90).aspx)-типов:

```cs
object x = new int?();
object y = new int?();
Console.WriteLine(x == y);
```

Несмотря на явный вызов конструктора, получившиеся значения равны `null`, а следовательно совпадают.

* **A1-2.** Или можно вспомнить про [интернирование строк](http://blogs.msdn.com/b/ericlippert/archive/2009/09/28/string-interning-and-string-empty.aspx) и объявить две пустые строчки:

```cs
object x = new string(new char[0]);
object y = new string(new char[0]);
Console.WriteLine(x == y);
```

* **A2.** Вторая задачка — самая сложная из трёх предложенных. Необходимо придумать такое решение, чтобы запускались именно три *разных* перегрузки нашего метода. В качестве варианта решения можно рассмотреть следующий код:

```cs
public class ReferenceGeneric<T> where T : class { }

public class EvilClassBase
{
  protected void EvilMethod<T>()
  {
    Console.WriteLine("int?");
  }
}

public class EvilClass : EvilClassBase
{
  public void Run()
  {
    EvilMethod<string>();
    EvilMethod<int>();
    EvilMethod<int?>();
  }

  private void EvilMethod<T>(ReferenceGeneric<T> arg = null) where T : class
  {
    Console.WriteLine("string");
  }

  private void EvilMethod<T>(T? arg = null) where T : struct
  {
    Console.WriteLine("int");
  }
}
```

Для начала разберёмся с типам `string` и `int`. Тут всё просто: `string` является ссылочным типом, а `int` — значимым. При написании кода нам помогут конструкции `where T : class`, `where T : struct` и параметры по умолчанию, которые явно задействуют тип `T` соответствующим образом: в первый метод пойдёт аргумент типа `ReferenceGeneric<T>` (он может принимать только ссылочные типы), а во второй — `T?` (он может принимать только значимые non-nullable типы). Теперь вызовы `EvilMethod<string>()` и `EvilMethod<int>()` «найдут» себе правильные перегрузки.

Едем дальше, вспомним про `int?`. Для него создадим перегрузку с сигнатурой без всяких дополнительных условий `EvilMethod<T>()` (увы, C# не позволяет написать что-нибудь вроде `where T : Nullable<int>`). Но если мы объявим такой метод в том же классе, то он «заберёт» себе вызовы первых двух методов. Поэтому следует «отправить» его в базовый класс, там он нам мешать не будет.

Давайте взглянем на то, что получилось. Вызовы `EvilMethod<string>()` и `EvilMethod<int>()` «увидят» подходящие перегрузки в текущем классе и будут их использовать. Вызов `EvilMethod<int>;()` подходящей перегрузки в текущем классе «не найдёт», поэтому «пойдёт» за ней в базовый класс. Сила [C# Overload resolution rules](http://msdn.microsoft.com/en-us/library/aa691336%28v=vs.71%29.aspx) опять помогла нам!

* **A3.** И снова Nullable-типы спешат на помощь!

```cs
var x = new int?();
string text = x.ToString(); // No exception
Type type = x.GetType(); // Bang!
```

[Вспомним](http://msdn.microsoft.com/en-us/library/9hd15ket.aspx), что метод `ToString()` перегружен в `Nullable<T>`, для null-значения он вернёт пустую строчку. Увы, для `GetType()` такой фокус не пройдёт, он не может быть перегружен и на null-значении выбросит исключение. Также вы [можете почитать](http://stackoverflow.com/questions/12725631/nullable-type-gettype-throws-exception) оригинальный ответ Джона на свой вопрос.

Не забываем, что при очень большом желании через неуправляемый код мы всегда можем долезть до таблицы методов и ручками подменить ссылку на `GetType()`, но сегодня нас просили не хитрить =).
