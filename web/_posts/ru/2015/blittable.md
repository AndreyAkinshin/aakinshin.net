---
layout: ru-post
title: "Blittable-типы"
date: "2015-11-26"
lang: ru
type: post
tags:
- ".NET"
- C#
redirect_from:
- ru/blog/dotnet/blittable/
- ru/blog/post/blittable/
---

Вопрос дня: что выведет нижеприведённый код?

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

Если вы подумали, что в консоли напечатается два нуля (или просто два одинаковых значения), то вам нужно узнать больше про внутреннее устройство структур в .NET. Ниже представлены результаты выполнения кода в зависимости от рантайма:

<table>
<tr><th></th><th>MS.NET-x86</th><th>MS.NET-x64</th><th>Mono</th></tr>
<tr><td>uInt128Adress - baseAddress                  </td><td>4</td><td>8</td><td>0</td></tr>
<tr><td>Marshal.OffsetOf(typeof(MyStruct), "UInt128")</td><td>0</td><td>0</td><td>0</td></tr>
</table>

Чтобы разобраться с ситуацией, нам необходимо узнать больше про blittable-типы.<!--more-->

### Теория

Википедия [даёт](https://en.wikipedia.org/wiki/Blittable_types) следующее определение blittable-типов:

> Blittable types are data types in software applications which have a unique characteristic. Data are often represented in memory differently in managed and unmanaged code in the Microsoft .NET framework. However, blittable types are defined as having an identical presentation in memory for both environments, and can be directly shared. Understanding the difference between blittable and non-blittable types can aid in using COM Interop or P/Invoke, two techniques for interoperability in .NET applications.

Другими словами, это такие типы, которые представлены одинаково в управляемой или неуправляемой памяти. Данная характеристика очень важна, если вы собираетесь маршалить ваши структуры. Согласитесь, было бы очень здорово, если бы поля структуры уже лежали бы в памяти именно в том порядке, в котором вы собираетесь их куда-то передавать. Кроме того, имеется ряд ситуаций, в которых вы можете использовать только blittable-типы. Примеры:

* Типы, которые возвращаются через P/Invoke.
* Типы, которые вы можете сделать [pinned](https://msdn.microsoft.com/en-us/library/23acw07k.aspx) (Есть оптимизация, благодаря которой при маршалинге такие типы делаются pinned, а не копируются явно).

Давайте разберёмся в этой теме подробней: какие же типы являются blittable и что на это влияет?

Для понимания дальнейшего материала также полезно знать про атрибут [ System.Runtime.InteropServices.StructLayoutAttribute](https://msdn.microsoft.com/en-us/library/system.runtime.interopservices.structlayoutattribute.aspx), с помощью которого можно контролировать метод физической организации данных структуры при экспорте в неуправляемый код. С помощью параметра `LayoutKind` можно задать [один из трёх режимов](https://msdn.microsoft.com/en-us/library/system.runtime.interopservices.layoutkind.aspx):

* `Auto`: Среда CLR автоматически выбирает соответствующее размещение для членов объекта в неуправляемой памяти. Доступ к объектам, определенным при помощи этого члена перечисления, не может быть предоставлен вне управляемого кода. Попытка выполнить такую операцию вызовет исключение.
* `Explicit`: Точное положение каждого члена объекта в неуправляемой памяти управляется явно в соответствии с настройкой поля StructLayoutAttribute.Pack. Каждый член должен использовать атрибут FieldOffsetAttribute для указания положения этого поля внутри типа.
* `Sequential`: Члены объекта располагаются последовательно, в порядке своего появления при экспортировании в неуправляемую память. Члены располагаются в соответствии с компоновкой, заданной в StructLayoutAttribute.Pack, и могут быть несмежными.

Два последних значения (`Explicit` и `Sequential`) также называются Formatted, т.к. явно задают порядок полей. C# использует `Sequential` в качестве значения по умолчанию.

### Blittable types

Очень важно понимать, какие именно типы являются blittable. Итак, Blittable-типами являются:

* Следующие примитивные типы: [System.Byte](https://msdn.microsoft.com/en-us/library/system.byte.aspx), [System.SByte](https://msdn.microsoft.com/en-us/library/system.sbyte.aspx), [System.Int16](https://msdn.microsoft.com/en-us/library/system.int16.aspx), [System.UInt16](https://msdn.microsoft.com/en-us/library/system.uint16.aspx), [System.Int32](https://msdn.microsoft.com/en-us/library/system.int32.aspx), [System.UInt32](https://msdn.microsoft.com/en-us/library/system.uint32.aspx), [System.Int64](https://msdn.microsoft.com/en-us/library/system.int64.aspx), [System.UInt64](https://msdn.microsoft.com/en-us/library/system.uint64.aspx), [System.IntPtr](https://msdn.microsoft.com/en-us/library/system.intptr.aspx), [System.UIntPtr](https://msdn.microsoft.com/en-us/library/system.uintptr.aspx), [System.Single](https://msdn.microsoft.com/en-us/library/system.single.aspx), [System.Double](https://msdn.microsoft.com/en-us/library/system.double.aspx).
* Одномерные массивы blittable-типов.
* Formatted (Explicit или Sequential) value types, которые в качестве полей содержат исключительно blittable-структуры.

### Non-Blittable Types

Есть несколько non-blittable-типов, о которых хотелось бы поговорить подробней.

#### Decimal

Да, [Decimal](https://msdn.microsoft.com/en-us/library/system.decimal.aspx) не является blittable-типом. Если вам нужно использовать его для blittable-целей, то придётся написать обёртку вида (основано на [методе](http://stackoverflow.com/a/30217247/184842) от Hans Passant, см. [Why is “decimal” data type non-blittable?](http://stackoverflow.com/questions/30213132/why-is-decimal-data-type-non-blittable)):

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

Занимательный факт: [DateTime](https://msdn.microsoft.com/en-us/library/system.datetime.aspx) содержит единственное `UInt64` поле, но LayoutKind [явно выставлен](http://referencesource.microsoft.com/#mscorlib/system/datetime.cs,55) в `Auto`:

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

Это означает, что `DateTime` не является blittable-типом. Значит, если ваша структура содержит DateTime-поле, то она также будет non-blittable. Данный факт имеет исторические причины и вызывает массу недоумения у людей, см: [Why does the System.DateTime struct have layout kind Auto?](http://stackoverflow.com/questions/21881554/why-does-the-system-datetime-struct-have-layout-kind-auto), [Why does LayoutKind.Sequential work differently if a struct contains a DateTime field?](http://stackoverflow.com/questions/4132533/why-does-layoutkind-sequential-work-differently-if-a-struct-contains-a-datetime) (для понимания происходящего рекомендую прочитать [вот этот ответ](http://stackoverflow.com/a/21883421/184842) от Hans Passant).

Для DateTime можно написать blittable-обёртку:

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

Вы наверняка знаете про тип [Guid](https://msdn.microsoft.com/en-us/library/system.guid.aspx), но знаете ли вы то, как он устроен внутри? Давайте взглянем на [исходный код](http://referencesource.microsoft.com/#mscorlib/system/guid.cs,30):

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

Интересненько, не правда ли? Если мы [почитаем википедию](https://en.wikipedia.org/wiki/Globally_unique_identifier), то найдём там следующую табличку:

<table>
<tr><th>Bits</th><th>Bytes</th><th>Name</th><th>Endianness (Microsoft GUID Structure)</th><th>Endianness (RFC 4122)</th></tr>
<tr><td>32</td><td>4</td><td>Data1</td><td>Native</td><td>Big</td></tr>
<tr><td>16</td><td>2</td><td>Data2</td><td>Native</td><td>Big</td></tr>
<tr><td>16</td><td>2</td><td>Data3</td><td>Native</td><td>Big</td></tr>
<tr><td>64</td><td>8</td><td>Data4</td><td>Big   </td><td>Big</td></tr>
</table>

GUID имеет следующий Type library representation:

```c
typedef struct tagGUID {
    DWORD Data1;
    WORD  Data2;
    WORD  Data3;
    BYTE  Data4[ 8 ];
} GUID;
```
Важным является тот факт, что представление GUID в памяти является платформозависимым. Если вы работаете с little-endian-архитектурой (а это скорее всего так, см. [Endianness](https://en.wikipedia.org/wiki/Endianness)), то представление Guid будет отличаться от RFC 4122, что может создать некоторые проблемы при взаимодействии .NET с другими системами (например, [Java UUID](http://docs.oracle.com/javase/8/docs/api/java/util/UUID.html) использует RFC 4122).

#### Char

[Char](https://msdn.microsoft.com/en-us/library/system.char.aspx) также является non-blittable-типом, при маршалинге он может конвертироваться в `Unicode` или `ANSI` символ. За тип маршалинга отвечает [CharSet](https://msdn.microsoft.com/en-us/library/system.runtime.interopservices.charset.aspx) атрибута `StructLayout`, который может принимать значения: `Auto`, `Ansi`, `Unicode`. На современных версиях Windows `Auto` превращается в `Unicode`, но во времена Windows 98 и Windows Me `Auto` превращался в `Ansi`. C# компилятор использует значение `Ansi` по умолчанию, что делает char не blittable-типом. Однако, мы можем написать следующую обёртку, чтобы победить проблему:

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

MSDN [говорит](https://msdn.microsoft.com/en-us/library/75dwhxf7.aspx) нам следующую вещь про [Boolean](https://msdn.microsoft.com/en-us/library/system.boolean.aspx):

> Converts to a 1, 2, or 4-byte value with true as 1 or -1.

Давайте напишем ещё одну обёртку, чтобы решить проблему:

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

### Blittable или Non-Blittable?

Порой очень полезно понять, является ли наш тип Blittable. Как это сделать? Нам поможет знание о том, что мы не можем аллоцировать pinned-версию экземпляра такого типа. Для удобства мы можем написать следующий helper-класс (основано на [методе IllidanS4](http://stackoverflow.com/a/31485271/184842), см. [The fastest way to check if a type is blittable?](http://stackoverflow.com/questions/10574645/the-fastest-way-to-check-if-a-type-is-blittable)):

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

Но есть один особый тип, для которого приведённый helper будет работать неправильно: decimal. Удивительно, но вы можете сделать pinned alloc для decimal-а! Впрочем, pinned alloc для структуры, которая содержит decimal, работать не будет, т.к. decimal всё-таки не является blittable-типом. Я не знаю других типов, с которыми возникает подобная проблема, поэтому можно позволить себе немного похакать и добавить в начало метода `IsBlittable` вот такие строчки:

```
if (type == typeof(decimal))
    return false;
```

Если вы знаете более элегантное решение, то буду рад комментариям.

### CoreCLR-исходники

CoreCLR нынче имеет открытый исходный код, так что можно посмотреть, как же там всё устроено внутри. Сегодня нас больше всего будет интересовать файл [fieldmarshaler.cpp](https://github.com/dotnet/coreclr/blob/master/src/vm/fieldmarshaler.cpp#L283-L318), там можно найти следующие строчки:

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

### Разбор примера

Давайте вернёмся к примеру из начала поста. Теперь понятно, почему под MS.NET мы можем наблюдать разницу. `Marshal.OffsetOf(typeof(MyStruct), "UInt128")` выдаёт нам «честный» offset, который получается при маршалинге, он равен `0`. А вот про внутреннее устройство структуры никаких гарантий CLR не даёт, ведь наша структура не является blittable:

```cs
Console.WriteLine(BlittableHelper.IsBlittable<MyStruct>()); // False
```

Но теперь мы знаем, как исправить ситуацию и сделать код более предсказуемым: заменим `char` на нашу обёртку `blittableChar`:

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

Не советую закладываться на то, что вы можете предсказать устройство non-blittable-типов в памяти, оно зависит от многих факторов. Следующая модификация примера показывает, что non-blittable-типы также могут быть представлены в памяти без переставления полей:

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

Приведённые в посте обёртки я выложил на GitHub и оформил в виде NuGet-пакета:

* [https://github.com/AndreyAkinshin/BlittableStructs](https://github.com/AndreyAkinshin/BlittableStructs)
* [https://www.nuget.org/packages/BlittableStructs/](https://www.nuget.org/packages/BlittableStructs/)

Надеюсь, кому-нибудь это будет полезно. Если у вас есть что добавить, то пул-реквесты приветствуются.

### Ссылки

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
