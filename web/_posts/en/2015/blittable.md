---
layout: post
title: "Blittable types"
date: "2015-11-26"
lang: en
type: post
tags:
- ".NET"
- C#
- Internals
redirect_from:
- /en/blog/dotnet/blittable/
- /blog/post/blittable/
---

Challenge of the day: what will the following code display?

```cs
[StructLayout(LayoutKind.Explicit)]
public struct UInt128
{
    [FieldOffset(0)]
    public ulong Value1;
    [FieldOffset(8)]
    public ulong Value2;
}
[StructLayout(LayoutKind.Sequential)]
public struct MyStruct
{
    public UInt128 UInt128;
    public char Char;
}
class Program
{
    public static unsafe void Main()
    {
        var myStruct = new MyStruct();
        var baseAddress = (int)&myStruct;
        var uInt128Adress = (int)&myStruct.UInt128;
        Console.WriteLine(uInt128Adress - baseAddress);
        Console.WriteLine(Marshal.OffsetOf(typeof(MyStruct), "UInt128"));
    }
}
```

A hint: two zeros or two another same values are wrong answers in the general case. The following table shows the console output on different runtimes:

<table>
<tr><th></th><th>MS.NET-x86</th><th>MS.NET-x64</th><th>Mono</th></tr>
<tr><td>uInt128Adress - baseAddress                  </td><td>4</td><td>8</td><td>0</td></tr>
<tr><td>Marshal.OffsetOf(typeof(MyStruct), "UInt128")</td><td>0</td><td>0</td><td>0</td></tr>
</table>

If you want to know why it happens, you probably should learn some useful information about blittable types.<!--more-->

### Theory

There is a definition of [blittable types](https://en.wikipedia.org/wiki/Blittable_types) from Wikipedia:

> Blittable types are data types in software applications which have a unique characteristic. Data are often represented in memory differently in managed and unmanaged code in the Microsoft .NET framework. However, blittable types are defined as having an identical presentation in memory for both environments, and can be directly shared. Understanding the difference between blittable and non-blittable types can aid in using COM Interop or P/Invoke, two techniques for interoperability in .NET applications.

If you want to marshall your structures, it is very important to know: is your type blittable or not. Indeed, marshalling will be easier, if your data in memory has a proper representation for marshalling. Furthermore, there are situations when you can use only blittable types. For example:


* Structures that are returned from platform invoke calls must be blittable types.
* As an optimization, arrays of blittable types and classes that contain only blittable members are pinned instead of copied during marshaling.

Let's discuss it in detail: which types are blittable and what does it depend?

First of all, we should know about the following attribute: [ System.Runtime.InteropServices.StructLayoutAttribute](https://msdn.microsoft.com/en-us/library/system.runtime.interopservices.structlayoutattribute.aspx), it lets you control the physical layout of the data fields of a class or structure in memory. You can use [3 following values](https://msdn.microsoft.com/en-us/library/system.runtime.interopservices.layoutkind.aspx) of `LayoutKind`:

* `Auto`: The runtime automatically chooses an appropriate layout for the members of an object in unmanaged memory. Objects defined with this enumeration member cannot be exposed outside of managed code. Attempting to do so generates an exception.
* `Explicit`: The precise position of each member of an object in unmanaged memory is explicitly controlled, subject to the setting of the StructLayoutAttribute.Pack field. Each member must use the FieldOffsetAttribute to indicate the position of that field within the type.
* `Sequential`: The members of the object are laid out sequentially, in the order in which they appear when exported to unmanaged memory. The members are laid out according to the packing specified in StructLayoutAttribute.Pack, and can be noncontiguous.

Two last values (`Explicit` and `Sequential`) are also called Formatted because they define the fields order for marshalling. C# uses `Sequential` as default.

### Blittable types

It is very important to know, which types are blittable. We have the following groups of blittable types:

* Some primitive types: [System.Byte](https://msdn.microsoft.com/en-us/library/system.byte.aspx), [System.SByte](https://msdn.microsoft.com/en-us/library/system.sbyte.aspx), [System.Int16](https://msdn.microsoft.com/en-us/library/system.int16.aspx), [System.UInt16](https://msdn.microsoft.com/en-us/library/system.uint16.aspx), [System.Int32](https://msdn.microsoft.com/en-us/library/system.int32.aspx), [System.UInt32](https://msdn.microsoft.com/en-us/library/system.uint32.aspx), [System.Int64](https://msdn.microsoft.com/en-us/library/system.int64.aspx), [System.UInt64](https://msdn.microsoft.com/en-us/library/system.uint64.aspx), [System.IntPtr](https://msdn.microsoft.com/en-us/library/system.intptr.aspx), [System.UIntPtr](https://msdn.microsoft.com/en-us/library/system.uintptr.aspx), [System.Single](https://msdn.microsoft.com/en-us/library/system.single.aspx), [System.Double](https://msdn.microsoft.com/en-us/library/system.double.aspx).
* One-dimensional arrays of blittable types, such as an array of integers. However, a type that contains a variable array of blittable types is not itself blittable.
* Formatted value types that contain only blittable types (and classes if they are marshaled as formatted types).

### Non-Blittable Types

There are several non-blittable types which we should discussed in detail.

#### Decimal

Yep, [Decimal](https://msdn.microsoft.com/en-us/library/system.decimal.aspx) is not a blittable type. If you want to use it as a blittable, you probably should write a wrapper (based on the [method](http://stackoverflow.com/a/30217247/184842) by Hans Passant, see [Why is “decimal” data type non-blittable?](http://stackoverflow.com/questions/30213132/why-is-decimal-data-type-non-blittable)):

```cs
public struct BlittableDecimal
{
    private long longValue;

    public decimal Value
    {
        get { return decimal.FromOACurrency(longValue); }
        set { longValue = decimal.ToOACurrency(value); }
    }

    public static explicit operator BlittableDecimal(decimal value)
    {
        return new BlittableDecimal { Value = value };
    }

    public static implicit operator decimal (BlittableDecimal value)
    {
        return value.Value;
    }
}
```

#### DateTime

An interesting fact: [DateTime](https://msdn.microsoft.com/en-us/library/system.datetime.aspx) contains a single  `UInt64` field, but the LayoutKind [explicitly set](http://referencesource.microsoft.com/#mscorlib/system/datetime.cs,55) to `Auto`:

```cs
[StructLayout(LayoutKind.Auto)]
[Serializable]
public struct DateTime : 
  IComparable, IFormattable, IConvertible, ISerializable, IComparable<DateTime>,IEquatable<DateTime> {
    
    // ...
                    
    // The data is stored as an unsigned 64-bit integeter
    //   Bits 01-62: The value of 100-nanosecond ticks where 0 represents 1/1/0001 12:00am, up until the value
    //               12/31/9999 23:59:59.9999999
    //   Bits 63-64: A four-state value that describes the DateTimeKind value of the date time, with a 2nd
    //               value for the rare case where the date time is local, but is in an overlapped daylight
    //               savings time hour and it is in daylight savings time. This allows distinction of these
    //               otherwise ambiguous local times and prevents data loss when round tripping from Local to
    //               UTC time.
    private UInt64 dateData;
    
    // ...
}
```

It means that `DateTime` is a non-blittable type. Thus, if you have a value type with a `DateTime` field, your types will be also non-blittable. Such behaviour has historical causes and confuses some people, see: [Why does the System.DateTime struct have layout kind Auto?](http://stackoverflow.com/questions/21881554/why-does-the-system-datetime-struct-have-layout-kind-auto), [Why does LayoutKind.Sequential work differently if a struct contains a DateTime field?](http://stackoverflow.com/questions/4132533/why-does-layoutkind-sequential-work-differently-if-a-struct-contains-a-datetime) (I recommend to read [this answer](http://stackoverflow.com/a/21883421/184842) by Hans Passant).

Of course, you can write a blittable wrapper like follows:

```cs
public struct BlittableDateTime
{
    private long ticks;

    public DateTime Value
    {
        get { return new DateTime(ticks); }
        set { ticks = value.Ticks; }
    }

    public static explicit operator BlittableDateTime(DateTime value)
    {
        return new BlittableDateTime { Value = value };
    }

    public static implicit operator DateTime(BlittableDateTime value)
    {
        return value.Value;
    }
}
```


#### Guid

Of course, you know about the [Guid](https://msdn.microsoft.com/en-us/library/system.guid.aspx) type. But do you know about its internal representation? Let's look to [the source code](http://referencesource.microsoft.com/#mscorlib/system/guid.cs,30):

```cs
private int         _a;
private short       _b;
private short       _c;
private byte       _d;
private byte       _e;
private byte       _f;
private byte       _g;
private byte       _h;
private byte       _i;
private byte       _j;
private byte       _k;

// Creates a new guid from an array of bytes.
public Guid(byte[] b)
{
    // Some checks ...

    _a = ((int)b[3] << 24) | ((int)b[2] << 16) | ((int)b[1] << 8) | b[0];
    _b = (short)(((int)b[5] << 8) | b[4]);
    _c = (short)(((int)b[7] << 8) | b[6]);
    _d = b[8];
    _e = b[9];
    _f = b[10];
    _g = b[11];
    _h = b[12];
    _i = b[13];
    _j = b[14];
    _k = b[15];
}
```

It is interesting. If we open [wikipedia](https://en.wikipedia.org/wiki/Globally_unique_identifier), we can find the following table:

<table>
<tr><th>Bits</th><th>Bytes</th><th>Name</th><th>Endianness (Microsoft GUID Structure)</th><th>Endianness (RFC 4122)</th></tr>
<tr><td>32</td><td>4</td><td>Data1</td><td>Native</td><td>Big</td></tr>
<tr><td>16</td><td>2</td><td>Data2</td><td>Native</td><td>Big</td></tr>
<tr><td>16</td><td>2</td><td>Data3</td><td>Native</td><td>Big</td></tr>
<tr><td>64</td><td>8</td><td>Data4</td><td>Big   </td><td>Big</td></tr>
</table>

GUID has the following Type library representation:

```c
typedef struct tagGUID {
    DWORD Data1;
    WORD  Data2;
    WORD  Data3;
    BYTE  Data4[ 8 ];
} GUID;
```

It is very important that internal representation of GUID is depend on platform. If you work with the little-endian architecture (you likely uses exactly little-endian, see [Endianness](https://en.wikipedia.org/wiki/Endianness)), the GUID representation will differ from RFC 4122. It can create some troubles during interop with another application (for example, [Java UUID](http://docs.oracle.com/javase/8/docs/api/java/util/UUID.html) uses RFC 4122).

#### Char

[Char](https://msdn.microsoft.com/en-us/library/system.char.aspx) is also non-blittable type, it can be converted to `Unicode` or `ANSI` character. The marshalling type depends on [CharSet](https://msdn.microsoft.com/en-us/library/system.runtime.interopservices.charset.aspx) of `StructLayout`, which can be equal to one of the following values: `Auto`, `Ansi`, `Unicode`. On the modern versions of Windows, `Auto` resolves to `Unicode`, but on Windows 98 and Windows Me `Auto` resolves to `Ansi`. The C# compiler uses `Ansi` as default that makes char a non-blittable type. However, we can write the following wrapper and solve the problem:

```cs
[StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
public struct BlittableChar
{
    public char Value;

    public static explicit operator BlittableChar(char value)
    {
        return new BlittableChar { Value = value };
    }

    public static implicit operator char (BlittableChar value)
    {
        return value.Value;
    }
}
```

#### Boolean

MSDN [says](https://msdn.microsoft.com/en-us/library/75dwhxf7.aspx) the following phrase about [Boolean](https://msdn.microsoft.com/en-us/library/system.boolean.aspx):

> Converts to a 1, 2, or 4-byte value with true as 1 or -1.

Let's write one more wrapper and make blittable bool:

```cs
public struct BlittableBoolean
{
    private byte byteValue;

    public bool Value
    {
        get { return Convert.ToBoolean(byteValue); }
        set { byteValue = Convert.ToByte(value); }
    }

    public static explicit operator BlittableBoolean(bool value)
    {
        return new BlittableBoolean { Value = value };
    }

    public static implicit operator bool (BlittableBoolean value)
    {
        return value.Value;
    }
}
```

### Blittable or Non-Blittable?

Sometimes it is useful to know, is your type blittable or not. How we can do it? Recall that we can't allocate pinned instances of non-blittable type. So, we can write the following helper class for our aim (based on the [method by IllidanS4](http://stackoverflow.com/a/31485271/184842), see [The fastest way to check if a type is blittable?](http://stackoverflow.com/questions/10574645/the-fastest-way-to-check-if-a-type-is-blittable)):

```cs
public static class BlittableHelper
{
    public static bool IsBlittable<T>()
    {
        return IsBlittableCache<T>.Value;
    }

    public static bool IsBlittable(this Type type)
    {
        if (type.IsArray)
        {
            var elem = type.GetElementType();
            return elem.IsValueType && IsBlittable(elem);
        }
        try
        {
            object instance = FormatterServices.GetUninitializedObject(type);
            GCHandle.Alloc(instance, GCHandleType.Pinned).Free();
            return true;
        }
        catch
        {
            return false;
        }
    }

    private static class IsBlittableCache<T>
    {
        public static readonly bool Value = IsBlittable(typeof(T));
    }
}
```

However, there is one type that broke our approach: decimal. Surprisingly, but you can allocate a pinned decimal. And you can't allocate a pinned instance of value types that contains decimal field (because decimal is non-blittable). I don't know other such types. So, we probably can write a hack in the `IsBlittable` method:

```
if (type == typeof(decimal))
    return false;
```

If you know a general solution, I'll be glad to discuss it.

### CoreCLR sources

Nowadays, we have open source CoreCLR. So, we can look inside the runtime and find something interesting. An interesting file is [fieldmarshaler.cpp](https://github.com/dotnet/coreclr/blob/master/src/vm/fieldmarshaler.cpp#L283-L318), it contains the following lines:

```cs
if (!(*pfDisqualifyFromManagedSequential))
{
    // This type may qualify for ManagedSequential. Collect managed size and alignment info.
    if (CorTypeInfo::IsPrimitiveType(corElemType))
    {
        pfwalk->m_managedSize = ((UINT32)CorTypeInfo::Size(corElemType)); // Safe cast - no primitive type is larger than 4gb!
        pfwalk->m_managedAlignmentReq = pfwalk->m_managedSize;
    }
    else if (corElemType == ELEMENT_TYPE_PTR)
    {
        pfwalk->m_managedSize = sizeof(LPVOID);
        pfwalk->m_managedAlignmentReq = sizeof(LPVOID);
    }
    else if (corElemType == ELEMENT_TYPE_VALUETYPE)
    {
        TypeHandle pNestedType = fsig.GetLastTypeHandleThrowing(ClassLoader::LoadTypes,
                                                                CLASS_LOAD_APPROXPARENTS,
                                                                TRUE);
        if (pNestedType.GetMethodTable()->IsManagedSequential())
        {
            pfwalk->m_managedSize = (pNestedType.GetMethodTable()->GetNumInstanceFieldBytes());

            _ASSERTE(pNestedType.GetMethodTable()->HasLayout()); // If it is ManagedSequential(), it also has Layout but doesn't hurt to check before we do a cast!
            pfwalk->m_managedAlignmentReq = pNestedType.GetMethodTable()->GetLayoutInfo()->m_ManagedLargestAlignmentRequirementOfAllMembers;
        }
        else
        {
            *pfDisqualifyFromManagedSequential = TRUE;
        }
    }
    else
    {
        // No other type permitted for ManagedSequential.
        *pfDisqualifyFromManagedSequential = TRUE;
    }
}
```

### Explanation of the example

Let's back to the first example from this post. Now we can understand why MS.NET shows different results. `Marshal.OffsetOf(typeof(MyStruct), "UInt128")` display «honest» marshalling offset (`0`). However, CLR does not guarantee anything about memory representation of our value types because it is not a blittable type:

```cs
Console.WriteLine(BlittableHelper.IsBlittable<MyStruct>()); // False
```

But now we know how to change the situation and make the result more predictable. Let's replace `char` by our wrapper:

```cs
[StructLayout(LayoutKind.Sequential)]
public struct MyStruct
{
    public UInt128 UInt128;
    public BlittableChar Char;
}

Console.WriteLine(uInt128Adress - baseAddress); // 0
Console.WriteLine(Marshal.OffsetOf(typeof(MyStruct), "UInt128")); // 0
Console.WriteLine(BlittableHelper.IsBlittable<MyStruct>()); // True
```

I don't recommend try to predict memory representation of your non-blittable types, it depends on big amount of different conditions. For example, the following modification of the example shows that non-blittable types can be represented in memory without field reordering:

```cs
[StructLayout(LayoutKind.Sequential)]
public struct UInt128
{
    public ulong Value1;
    public ulong Value2;
}
[StructLayout(LayoutKind.Sequential)]
public struct MyStruct
{
    public UInt128 UInt128;
    public char Char;
}

Console.WriteLine(uInt128Adress - baseAddress); // 0
Console.WriteLine(Marshal.OffsetOf(typeof(MyStruct), "UInt128")); // 0
Console.WriteLine(BlittableHelper.IsBlittable<MyStruct>()); // False
```

### NuGet & GitHub

I pushed my blittable wrappers to GitHub and publish a NuGet package:

* [https://github.com/AndreyAkinshin/BlittableStructs](https://github.com/AndreyAkinshin/BlittableStructs)
* [https://www.nuget.org/packages/BlittableStructs/](https://www.nuget.org/packages/BlittableStructs/)

I hope, it will be useful for someone. If you have any good ideas about blittable wrappers, PRs are welcome.

### Links

* [MSDN: Blittable and Non-Blittable Types](https://msdn.microsoft.com/en-us/library/75dwhxf7.aspx)
* [MSDN: Default Marshaling Behavior](https://msdn.microsoft.com/en-us/library/zah6xy75.aspx)
* [MSDN: Default Marshaling for Strings](https://msdn.microsoft.com/en-us/library/s9ts558h.aspx)
* [MSDN: Specifying a Character Set](https://msdn.microsoft.com/en-us/library/7b93s42f.aspx)
* [MSDN: Unicode and MBCS](https://msdn.microsoft.com/en-us/library/cwe8bzh0.aspx)
* [MSDN: Copying and Pinning](https://msdn.microsoft.com/en-us/library/23acw07k.aspx)
* [MSDN: Marshal.OffsetOf](https://msdn.microsoft.com/library/y8ewk18b.aspx)
* [MSDN: System.Runtime.InteropServices.StructLayoutAttribute](https://msdn.microsoft.com/en-us/library/system.runtime.interopservices.structlayoutattribute.aspx)
* [MSDN: System.Runtime.InteropServices.LayoutKind](https://msdn.microsoft.com/en-us/library/system.runtime.interopservices.layoutkind.aspx)
* [MSDN: System.Runtime.InteropServices.StructLayoutAttribute.CharSet](https://msdn.microsoft.com/en-us/library/system.runtime.interopservices.structlayoutattribute.charset.aspx)
* [Wikipedia: Globally unique identifier](https://en.wikipedia.org/wiki/Globally_unique_identifier)
* [Wikipedia: Universally unique identifier](https://en.wikipedia.org/wiki/Universally_unique_identifier)
* [Wikipedia: Endianness](https://en.wikipedia.org/wiki/Endianness)
* [Stackoverflow: The fastest way to check if a type is blittable?](http://stackoverflow.com/questions/10574645/the-fastest-way-to-check-if-a-type-is-blittable)
* [Stackoverflow: Marshalling non-Blittable Structs from C# to C++](http://stackoverflow.com/questions/11416433/marshalling-non-blittable-structs-from-c-sharp-to-c)
* [Stackoverflow: Why is “decimal” data type non-blittable?](http://stackoverflow.com/questions/30213132/why-is-decimal-data-type-non-blittable)
* [Stackoverflow: Non-blitable error on a blitable type](http://stackoverflow.com/questions/15544818/non-blitable-error-on-a-blitable-type)
* [Stackoverflow: Using reflection to determine how a .Net type is layed out in memory](http://stackoverflow.com/questions/17510042/using-reflection-to-determine-how-a-net-type-is-layed-out-in-memory)
* [Stackoverflow: Are .net Enums blittable types? (Marshalling)](http://stackoverflow.com/questions/5584160/are-net-enums-blittable-types-marshalling)
* [Stackoverflow: Why does the System.DateTime struct have layout kind Auto?](http://stackoverflow.com/questions/21881554/why-does-the-system-datetime-struct-have-layout-kind-auto)
* [Stackoverflow: Why does LayoutKind.Sequential work differently if a struct contains a DateTime field?](http://stackoverflow.com/questions/4132533/why-does-layoutkind-sequential-work-differently-if-a-struct-contains-a-datetime)
* [Stackoverflow: LayoutKind.Sequential not followed when substruct has LayoutKind.Explicit](http://stackoverflow.com/questions/16333511/layoutkind-sequential-not-followed-when-substruct-has-layoutkind-explicit)
* [Stackoverflow: Is there any difference between a GUID and a UUID?](http://stackoverflow.com/questions/246930/is-there-any-difference-between-a-guid-and-a-uuid)
* [GitHub CoreCLR:  coreclr/src/vm/fieldmarshaler.cpp
](https://github.com/dotnet/coreclr/blob/master/src/vm/fieldmarshaler.cpp)
* [Microsoft Reference Source: GUID](http://referencesource.microsoft.com/#mscorlib/system/guid.cs)
* [Microsoft Reference Source: DateTime](http://referencesource.microsoft.com/#mscorlib/system/datetime.cs)
* [RFC 4122](https://tools.ietf.org/html/rfc4122)
* [Java UUID](http://docs.oracle.com/javase/8/docs/api/java/util/UUID.html)
* [Stephen Cleary: A Few Words on GUIDs](http://blog.stephencleary.com/2010/11/few-words-on-guids.html)