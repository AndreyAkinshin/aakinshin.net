---
layout: post
title: "About System.Drawing.Color and operator =="
date: "2014-02-21"
lang: en
type: post
tags:
- ".NET"
- Colors
- C#
- Equals
redirect_from:
- /en/blog/dotnet/system-drawing-color-equals/
- /blog/post/system-drawing-color-equals/
---

Operator `==` that allows easy comparison of your objects is overridden for many standard structures in .NET. Unfortunately, not every developer really knows what is actually compared when working with this wonderful operator. This brief blog post will show the comparison logic based on a sample of `System.Drawing.Color`. What do you think the following code will get:

```cs
var redName = Color.Red;
var redArgb = Color.FromArgb(255, 255, 0, 0);
Console.WriteLine(redName == redArgb);
```

<!--more-->

“It’s red here and it’s red there. Probably, the objects should be equal”, the reader might think. Let’s open [source code](http://www.dotnetframework.org/default.aspx/Net/Net/3@5@50727@3053/DEVDIV/depot/DevDiv/releases/whidbey/netfxsp/ndp/fx/src/CommonUI/System/Drawing/Color@cs/1/Color@cs) and review the operator `==`:

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

Code review help us make an interesting conclusion: colors are compared by the Name property rather than the ARGB-value. What are the names of our objects? Let’s see.

```cs
Console.WriteLine(redName.Name); // Red
Console.WriteLine(redArgb.Name); // ffff0000
```

Hmm, they’ve got different names. So, the expression `redName == redArgb` gets `False`. There may occur an irritating situation, for example, when initial `Color.Red` was serialized to ARGB and then de-serialized back and then you decided to compare the final color with the original. Let’s read what [MSDN](http://msdn.microsoft.com/en-us/library/system.drawing.color.op_equality(v=vs.110).aspx) says about operator `==`:

> This method compares more than the ARGB values of the	[Color](http://msdn.microsoft.com/en-us/library/system.drawing.color(v=vs.110).aspx) structures. It also does a comparison of some state flags. If you want to compare just the ARGB values of two Color structures, compare them using the [ToArgb](http://msdn.microsoft.com/en-us/library/system.drawing.color.toargb(v=vs.110).aspx) method.

Everything is clear now. In order to compare our colors we need the `ToArgb` method.

```cs
Console.WriteLine(redName.ToArgb() == redArgb.ToArgb()); // True
```

## Summary

I think you shouldn’t relay on a guess about logic of the standard comparison methods even if they might seem obvious to you. If you use operator == or Equals method for value types it would be a good idea to have a look at the documentation and check what will be actually compared.

## Cross-posts

* [blogs.perpetuumsoft.com](http://blogs.perpetuumsoft.com/dotnet/about-system-drawing-color-and-operator/)