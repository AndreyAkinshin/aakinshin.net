---
layout: post
title: "Wrapping C# class for use in COM"
date: "2013-06-03"
lang: en
type: post
tags:
- ".NET"
- C#
- COM
redirect_from:
- /en/blog/dotnet/wrap-cs-in-com/
- /blog/post/wrap-cs-in-com/
---

Let us have a C# class that makes something useful, for example:

```cs
public class Calculator
{
    public int Sum(int a, int b)
    {
        return a + b;
    }
}
```

Let’s create a [COM](http://ru.wikipedia.org/wiki/Component_Object_Model) interface for this class to make it possible to use its functionality in other areas. At the end we will see how this class is used in Delphi environment.<!--more-->

For a beginning, we proceed to the project properties and check *Register for COM interop* on the *Build* tab.

<p class="center">
  <img src="/img/posts/dotnet/wrap-cs-in-com/screen1.png" />
</p>

Create an interface for our class:

```cs
public interface ICalculator
{
    int Sum(int a, int b);
}

public class Calculator : ICalculator
{
    public int Sum(int a, int b)
    {
        return a + b;
    }
}
```

It’s necessary to mark the class and the interface with a set of attributes: it’s necessary to specify unique [GUID](http://ru.wikipedia.org/wiki/GUID)’s for them, set `ComVisible(true)`,and add the `ClassInterface(ClassInterfaceType.None)` attribute to the class:

```cs
[Guid("364C5E66-4412-48E3-8BD8-7B2BF09E8922")]
[ComVisible(true)]
public interface ICalculator
{
    int Sum(int a, int b);
}

[Guid("8C034F6A-1D3F-4DB8-BC99-B73873D8C297")]
[ClassInterface(ClassInterfaceType.None)]
[ComVisible(true)]
public class Calculator : ICalculator
{
    public int Sum(int a, int b)
    {
        return a + b;
    }
}
```
We’re almost done! Now we can build the assembly. Since we checked *Register for COM interop*, the COM component will be registered in the system automatically. It’s also possible to register it manually. You can do it with the [RegAsm](http://msdn.microsoft.com/ru-ru/library/tzat5yw6.aspx) utility located here: `C:\Windows\Microsoft.NET\Framework\v < necessary version number >\`. The corresponding tlb file can be created with the help of the `/tlb` argument. The `/u` argument will [cancel](http://stackoverflow.com/questions/7841428/how-to-unregister-the-assembly-registered-using-regasm) assembly registration. So, let’s execute the command (assume that name of the project and the corresponding dll is ComCalculator):

```
RegAsm.exe Calculator.dll /tlb
```

Great! The component is registered! Run Delphi and try to use it. After a new project is created (a common WinForms project), it’s necessary to import ComCalculator to it. Select `Import Type Library` from the `Project` menu. Look for `ComCalculator` and click `Install`.

<p class="center">
  <img src="/img/posts/dotnet/wrap-cs-in-com/screen2.png" />
</p>

You need to add `ComCalculator_TLB` to the `uses` section in the `Unit1.pas` file. After that you [can get some issues](http://stackoverflow.com/questions/7196769/what-is-this-error-mscorlib-tlb-pas) with compilation of `mscorlib_TBL.pas`. If that’s the case, you just need to delete reference to it from the `uses` section of the `ComCalculator_TLB.pas` file.

Now let’s try to use our COM component. We will do it directly in the form constructor. The constructor body will contain two simple lines of code: the first one will contain instance of the `TCalculator` class, in the second one, we will call the `Sum` method. Calculation result will be shown with the help of the `ShowMessage` procedure.

```delphi
procedure TForm1.FormCreate(Sender: TObject);
var
  calculator : TCalculator;
begin
  calculator := TCalculator.Create(Self);
  ShowMessage(IntToStr(calculator.Sum(1, 2)));
end;
```

Running the application you will see the window with figure 3.

## Links

I recommend reading the following article for more complicated variants of the creation of COM objects:

* [MSDN: Example COM Class (C# Programming Guide)](https://msdn.microsoft.com/en-us/library/c3fd4a20.aspx)

## Cross-posts

* [blogs.perpetuumsoft.com](http://blogs.perpetuumsoft.com/dotnet/wrapping-c-class-for-use-in-com/)