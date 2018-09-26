---
layout: post
title: About UTF-8 conversions in Mono
date: "2014-11-10"
lang: en
type: post
tags:
- Encodings
- ".NET"
- Mono
redirect_from:
- /en/blog/dotnet/mono-utf8-conversions/
- /blog/post/mono-utf8-conversions/
---

This post is a logical continuation of the Jon Skeet's blog post [“When is a string not a string?”](http://codeblog.jonskeet.uk/2014/11/07/when-is-a-string-not-a-string). Jon showed very interesting things about behavior of ill-formed Unicode strings in .NET. I wondered about how similar examples will work on Mono. And I have got very interesting results.

### Experiment 1: Compilation

Let's take the Jon's code with a small modification. We will just add `text` null check in `DumpString`:

```cs
using System;
using System.ComponentModel;
using System.Text;
using System.Linq;
[Description(Value)]
class Test
{
    const string Value = "X\ud800Y";
    static void Main()
    {
        var description = (DescriptionAttribute)typeof(Test).
            GetCustomAttributes(typeof(DescriptionAttribute), true)[0];
        DumpString("Attribute", description.Description);
        DumpString("Constant", Value);
    }
    static void DumpString(string name, string text)
    {
        Console.Write("{0}: ", name);
        if (text != null)
        {
            var utf16 = text.Select(c => ((uint) c).ToString("x4"));
            Console.WriteLine(string.Join(" ", utf16));
        }
        else
            Console.WriteLine("null");
    }
}
```

<!--more-->

Let's compile the code with MS.NET (csc) and Mono (mcs). The resulting IL files will have one important distinction:

```
// MS.NET compiler
.custom instance void class
[System]System.ComponentModel.DescriptionAttribute::'.ctor'(string) =
(01 00 05 58 ED A0 80 59 00 00 ) // ...X...Y..
// Mono compiler
.custom instance void class
[System]System.ComponentModel.DescriptionAttribute::'.ctor'(string) =
(01 00 05 58 59 BF BD 00 00 00 ) // ...XY.....
```

**The interesting fact 1:** MS.NET and Mono transform original C# strings to UTF-8 IL strings in different ways. But both ways give non-valid UTF-8 strings (`58 ED A0 80 59` and `58 59 BF BD 00`).

### Experiment 2: Run

Ok, let's run it:

```
// MS.NET compiler / MS.NET runtime
Attribute: 0058 fffd fffd 0059
Constant: 0058 d800 0059
// MS.NET compiler / Mono runtime
Attribute: null
Constant: 0058 d800 0059
// Mono compiler / MS.NET runtime
Attribute: 0058 0059 fffd fffd 0000
Constant: 0058 d800 0059
// Mono compiler / Mono runtime
Attribute: null
Constant: 0058 d800 0059
```

**The interesting fact 2:** Mono runtime can't use our non-valid UTF-8 IL strings. Instead, Mono use `null`.

### Experiment 3: Manual UTF-8 to String conversion

Ok, but what if we create non-valid UTF-8 string in runtime? Let's check it! The code:

```cs
using System;
using System.Text;
using System.Linq;

class Test
{
    static void Main()
    {
        DumpString("(1)", Encoding.UTF8.GetString(
            new byte[] { 0x58, 0xED, 0xA0, 0x80, 0x59 }));
        DumpString("(2)", Encoding.UTF8.GetString(
            new byte[] { 0x58, 0x59, 0xBF, 0xBD, 0x00 }));
    }

    static void DumpString(string name, string text)
    {
        Console.Write("{0}: ", name);
        if (text != null)
        {
            var utf16 = text.Select(c => ((uint)c).ToString("x4"));
            Console.WriteLine(string.Join(" ", utf16));
        }
        else
            Console.WriteLine("null");
    }
}
```

And the result:

```
// MS.NET runtime
(1): 0058 fffd fffd 0059
(2): 0058 0059 fffd fffd 0000
// Mono runtime
(1): 0058 fffd fffd fffd 0059
(2): 0058 0059 fffd fffd 0000
```

**The interesting fact 3:**

MS.NET and Mono implement UTF-8 to String conversion in different ways. The `ED A0 80` sequence transforms to `FFDD FFDD` on MS.NET and to `FFDD FFDD FFDD` on Mono.

### Experiment 4: Manual String to UTF-8 conversion

Let's look to the reverse conversion (from String to UTF-8). The code:

```cs
var bytes = Encoding.UTF8.GetBytes("X\ud800Y");
Console.WriteLine(string.Join(" ", bytes.Select(b => b.ToString("x2"))));
```

And the result:

```
// MS.NET runtime
58 ef bf bd 59
// Mono runtime
58 59 bf bd 00
```

**The interesting fact 4:** MS.NET and Mono implement String to UTF-8 conversion in different ways too.

### Experiment 5: Prohibition of ill-formed string
Also, Jon's has written about prohibition of ill-formed strings in some attributes. For example, the code

```cs
[DllImport(Value)]
static extern void Foo();
```

will not compile on csc or Roslyn. But it will be successfully compile on Mono!

Another example: the code

```cs
[Conditional(Value)]
void Bar() {}
```

will not compile on csc and Mono:

```
// MS.NET compiler
error CS0647:
Error emitting ‘DllImportAttribute’ attribute
// Mono compiler
error CS0633:
The argument to the ‘ConditionalAttribute’ attribute must be a valid identifier
```

### Conclusion

Encodings are hard.