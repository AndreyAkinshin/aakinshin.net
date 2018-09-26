---
layout: post
title: Jon Skeet's Quiz
date: "2013-11-03"
lang: en
type: post
tags:
- ".NET"
- C#
redirect_from:
- /en/blog/dotnet/jon-skeet-quiz/
- /blog/post/jon-skeet-quiz/
---

Jon Skeet was once asked to give three questions to check how well you know C#. He asked the [following questions](http://www.dotnetcurry.com/magazine/jon-skeet-quiz.aspx):


* **Q1.** *What constructor call can you write such that this prints True (at least on the Microsoft .NET implementation)?*

```cs
object x = new /* fill in code here */;
object y = new /* fill in code here */;
Console.WriteLine(x == y);
```

*Note that it’s just a constructor call, and you can’t change the type of the variables.*

* **Q2.** *How can you make this code compile such that it calls three different method overloads?*

```cs
void Foo()
{
    EvilMethod<string>();
    EvilMethod<int>();
    EvilMethod<int?>();
}
```

* **Q3.** *With a local variable (so no changing the variable value cunningly), how can you make this code fail on the second line?*

```cs
string text = x.ToString(); // No exception
Type type = x.GetType(); // Bang!
```

These questions seemed interesting to me, that is why I decided to discuss the solutions.<!--more-->

---

* **A1-1.**

One of the simplest ways is using [Nullable](http://msdn.microsoft.com/en-us/library/1t3y8s4s(v=vs.90).aspx) types:

```cs
object x = new int?();
object y = new int?();
Console.WriteLine(x == y);
```

In spite of the explicit call of the constructor, values we got are equal to null and thus they match.

* **A1-2.** 
Or you can remember of [string interning](http://blogs.msdn.com/b/ericlippert/archive/2009/09/28/string-interning-and-string-empty.aspx) and declare two empty strings:

```cs
object x = new string(new char[0]);
object y = new string(new char[0]);
Console.WriteLine(x == y);
```

* **A2.** The second question is the most complicated one. It’s necessary to offer the solution which calls tree different method overloads. I can suggest the following code as a sample:

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

Let’s consider `string` and `int` types. Here it’s quite simple: `string` is a reference type and `int` is a value type. The following constructions will help us write the code: `where T : class`, `where T : struct`. The default parameters will explicitly use `T` type in the corresponding way: the first method will use argument of the following type: `ReferenceGeneric<T>` (it can accept only reference types), and the second method will use `T`? (it can accept only value non-nullable types). Now calls of `EvilMethod<string>()` and `EvilMethod<int>()` will get correct overloads.
 
Let’s proceed to `int?`. We will create overload with a signature without any additional conditions `EvilMethod<T>()` (unfortunately, C# doesn’t allow you to write anything of this kind `where T : Nullable<int>`). But if you declare this method in the same class, it will get calls of the first two methods. That is why you need to send it the base class.
 
Let’s look at what we have. Calls of `EvilMethod<string>()` and `EvilMethod<int>()` will see the suitable overloads in the current class and will use them. Call of `EvilMethod<int?>()` won’t find a suitable overload in the current class and will apply to the base class for it. Power of [C# Overload resolution rules](http://msdn.microsoft.com/en-us/library/aa691336%28v=vs.71%29.aspx) helped us once again!

* **A3.** Again, Nullable types will help us!

```cs
var x = new int?();
string text = x.ToString(); // No exception
Type type = x.GetType(); // Bang!
```

[Remember](http://msdn.microsoft.com/en-us/library/9hd15ket.aspx) that `ToString()` method is overloaded in `Nullable<T>`, it will get an empty string for the null value. Unfortunately, this trick won’t work for `GetType()`. It can’t be overloaded and will through an exception for the null value. You can also [read](http://stackoverflow.com/questions/12725631/nullable-type-gettype-throws-exception) the Jon’s original answer to this question.
 
Don’t forget that if you really want you can always access methods table via the unmanaged code and manually substitute reference to `GetType()`, but we were asked not to shuffle =).

## Cross-posts

* [blogs.perpetuumsoft.com](http://blogs.perpetuumsoft.com/dotnet/jon-skeets-quiz/)