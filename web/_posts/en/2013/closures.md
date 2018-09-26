---
layout: post
title: "Unobviousness in use of C# closures"
date: "2013-08-07"
lang: en
type: post
tags:
- Lambda
- Closures
- C#
- ".NET"
redirect_from:
- /en/blog/dotnet/closures/
- /blog/post/closures/
---

C# gives us an ability to use closures. This is a powerful tool that allows anonymous methods and lambda-functions to capture unbound variables in their lexical scope. And many programmers in .NET world like using closures very much, but only few of them understand how they really work. Let’s start with a simple sample:

```cs
public void Run()
{
  int e = 1;
  Foo(x => x + e);
}
```

Nothing complicated happens here: we just captured a local variable `e` in its lambda that is passed to some `Foo` method. Let’s see how the compiler will expand such construction.*

```cs
public void Run()
{
  DisplayClass c = new DisplayClass();
  c.e = 1;  
  Foo(c.Action);
}
private sealed class DisplayClass
{
  public int e;
  public int Action(int x)
  {
    return x + e;
  }
}
```

<!--more-->

As you see from the sample, an additional class containing the captured variable and the target method is created for our closure. This knowledge will help us understand how closures behave in different situations.

### The for loop

Probably, this is the most classic sample cited by everyone:

```
public void Run()
{
  var actions = new List<Action>();
  for (int i = 0; i < 3; i++)
    actions.Add(() => Console.WriteLine(i));
  foreach (var action in actions)
    action();
}
```

The sample contains a typical error. Newbie developers think that this code will output `"0 1 2"`, but in fact it will output `"3 3 3"`. Such strange behavior is easy to understand if you look on the expanded version of this method:

```cs
public void Run()
{
  var actions = new List<Action>();
  DisplayClass c = new DisplayClass();
  for (c.i = 0; c.i < 3; c.i++)
    list.Add(c.Action);
  foreach (Action action in list)
    action();
}

private sealed class DisplayClass
{
  public int i;

  public void Action()
  {
    Console.WriteLine(i);
  }
}
```

In this case they say that the variable is cycled by reference, not by value. Many programmers criticize this peculiarity of closures. They think it’s unclear though it’s quite logical for those who get a clear idea what’s inside the closures.

### The foreach loop

Let’s review a more interesting sample:

```cs
public void Run()
{
  var actions = new List<Action>();
  foreach (var i in Enumerable.Range(0, 3))
    actions.Add(() => Console.WriteLine(i));
  foreach (var action in actions)
    action();
}
```

What will the code output? Sorry to say that there is no simple answer to this question. The matter is that earlier versions of C#, behavior of foreach was equal to behavior of for: variable of the cycle was created once and was captured in all lambdas. Starting from C# 5.0 this behavior has changed ([here](http://blogs.msdn.com/b/ericlippert/archive/2009/11/12/closing-over-the-loop-variable-considered-harmful.aspx) Eric Lippert admits that Microsoft made the breaking change). Now this code outputs `"0 1 2"`. Note that this is a peculiarity of language, not of the platform. If you work in Visual Studio 2012 and change target framework to 3.5, nothing will change. And you will be able to see the old behavior in Visual Studio 2010. John Skit [explains](http://stackoverflow.com/questions/16264289/captured-closure-loop-variable-in-c-sharp-5-0) why it was decided to make different behavior for `foreach` and `for`. Let’s have a look at a new variant of the expanded version of the code:

```cs
public void Run()
{
  var actions = new List<Action>();
  foreach (int i in Enumerable.Range(0, 3))
  {
    DisplayClass c = new DisplayClass();
    с.i = i;    
    list.Add(c1.Action);
  }
  foreach (Action action in list)
    action();
}

private sealed class DisplayClass
{
  public int i;

  public void Action()
  {
    Console.WriteLine(i);
  }
}
```

You can easily see the difference: in C# 5.0, for every iteration of the foreach cycle, we get a new instance of the generated class providing closure logic.

### Closure of multiple variables

Let’s review a case when we get multiple variables that are captured in different variables:

```cs
public void Run()
{
  int x = 1, y = 2;
  Foo(u => u + x, u => u + y);
}
```

One can think that in this case two additional classes are generated and each of them will be responsible for a single variable. Actually, a single class will be generated:

```cs
public void Run()
{
  DisplayClass с = new DisplayClass();
  с.x = 1;
  с.y = 2;
  Foo(с.ActionX, c.ActionY);
}

private sealed class DisplayClass
{
  public int x;
  public int y;

  public int ActionX(int u)
  {
    return u + x;
  }

  public int ActionY(int u)
  {
    return u + y;
  }
}
```

Thus, lambdas are bound; garbage collector will access them when no reference to either of them will remain. Imagine the situation when the first lambda is used when initiating a long-living object, the second one is used when completing the work with it. And let there be many such objects. In this case initializing lambdas will stay in memory for quite a long time, though no one will ever invoke them.

### Scope

There is one more peculiarity of closures that you need to know. Let’s review a sample:

```cs
public void Run(List<int> list)
{
  foreach (var element in list)
  {
    var e = element;
    if (Condition(e))
      Foo(x => x + e);
  }
}
```

And here is the question: where the closure object will be created? In spite the lambda is created inside `if`, the object will be created in the same scope the captured variable is located in.

```cs
public void Run(List<int> list)
{
  foreach (int element in list)
  {
    DisplayClass c = new DisplayClass();
    c.e = element;
    if (Condition(c.e))
      Foo(c.Action);
  }
}

private sealed class DisplayClass
{
  public int e;

  public int Action(int x)
  {
    return x + e;
  }
}
```

This peculiarity is important when the `list` is quite big and the `Condition(e)` is executed quite rarely. `DisplayClass` instances will be created uselessly. It will affect memory and performance. We can fix the situation:

```cs
public void Run(List<int> list)
{
  foreach (var element in list)
    if (Condition(element))
    {
      var e = element;
      Foo(x => x + e);
    }
}
```

This method will be deployed in a more optimal manner since `DisplayClass` constructor will be invoked when it is really necessary:

```cs
public void Run(List<int> list)
{
  foreach (int element in list)
    if (Condition(element))
    {
      DisplayClass c = new DisplayClass();
      c.e = element;
      Foo(c.Action);
    }  
}

private sealed class DisplayClass
{
  public int e;
 
  public int Action(int x)
  {
    return x + e;
  }
}
```

### Problems

You can find problems about the subject in [ProblemBook.NET](http://problembook.net):
[ClosureAndForeach](http://problembook.net/content/en/Linq/ClosureAndForeach-P.html),
[ClosureAndFor](http://problembook.net/content/en/Linq/ClosureAndFor-P.html),
[ClosureAndVariable](http://problembook.net/content/en/Linq/ClosureAndVariable-P.html).

---

It’s very convenient to use the following utility: [dotPeek](http://www.jetbrains.com/decompiler/) from [JetBrains](http://www.jetbrains.com/) with enabled option *Show compiler-generated code*. Code included in the article is simplified in comparison with the disassembled version to make it easy to read.