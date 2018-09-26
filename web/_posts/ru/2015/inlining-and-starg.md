---
layout: ru-post
title: "История про инлайнинг под JIT-x86 и starg"
date: "2015-02-26"
lang: ru
type: post
tags:
- ".NET"
- C#
- Inlining
redirect_from:
- /ru/blog/dotnet/inlining-and-starg/
- /ru/blog/post/inlining-and-starg/
---

Порой можно узнать много интересного во время чтения исходников .NET. Взглянем на конструктор типа `Decimal` из .NET Reference Source ([mscorlib/system/decimal.cs,158](http://referencesource.microsoft.com/#mscorlib/system/decimal.cs,158)):

```cs
// Constructs a Decimal from an integer value.
//
public Decimal(int value) {
    //  JIT today can't inline methods that contains "starg" opcode.
    //  For more details, see DevDiv Bugs 81184: x86 JIT CQ: Removing the inline striction of "starg".
    int value_copy = value;
    if (value_copy >= 0) {
        flags = 0;
    }
    else {
        flags = SignMask;
        value_copy = -value_copy;
    }
    lo = value_copy;
    mid = 0;
    hi = 0;
}
```

В комментарии сказано, что если метод содержит IL-опкод [starg](https://msdn.microsoft.com/library/system.reflection.emit.opcodes.starg.aspx), то он не может быть заинлайнен под x86. Любопытно, не правда ли?<!--more-->

### Исходники JIT

Давайте разберёмся в ситуации. Заглянем в исходники JIT из CoreCLR. Фрагмент файла [flowgraph.cpp](https://github.com/dotnet/coreclr/blob/65456c070ffbc97f14c1c32318dabc221646d8d6/src/jit/flowgraph.cpp#L4252)

```cs
// NetCF had some strict restrictions on inlining.  Specifically they
// would only inline methods that fit a specific pattern of loading
// arguments inorder, starting with zero, with no skipping, but not
// needing to load all of them.  Then a 'body' section that could do
// anything besides control flow.  And a final ending ret opcode.
// Lastly they did not allow starg or ldarga.
// These simplifications allowed them to skip past the ldargs, when
// inlining, and just use the caller's EE stack as the callee's EE
// stack, after optionally popping a few 'arguments' from the end.
//
// stateNetCFQuirks is a simple state machine to track that state
// and allow us to match those restrictions.
// State -1 means we're not tracking (no quirks mode)
// State 0 though 0x0000FFFF tracks what the *next* ldarg should be
//    to match the pattern
// State 0x00010000 and above means we are in the 'body' section and
//    thus no more ldarg's are allowed.
```

Комментарий гласит, что если метод содержит IL-команду `starg` или `ldarga`, то инлайнинг не выполнится. Почитаем код и убедимся, что это действительно так. Вскоре после комментария происходит выбор опкода:

```cpp
switch (opcode)

// ...

    case CEE_STARG:
    case CEE_STARG_S:     goto ARG_WRITE;

    case CEE_LDARGA:
    case CEE_LDARGA_S:
    case CEE_LDLOCA:
    case CEE_LDLOCA_S:    goto ADDR_TAKEN;
```

Случай с командой `starg` попроще, взглянем на него более внимательно:

```cpp
ARG_WRITE:
            if (compIsForInlining())
            {

#ifdef DEBUG
                if (verbose)
                {
                    printf("\n\nInline expansion aborted due to opcode at offset [%02u] which writes to an argument\n",
                           codeAddr-codeBegp-1);
                }
#endif

                /* The inliner keeps the args as trees and clones them.  Storing the arguments breaks that
                 * simplification.  To allow this, flag the argument as written to and spill it before
                 * inlining.  That way the STARG in the inlinee is trivial. */
                inlineFailReason = "Inlinee writes to an argument.";
                goto InlineNever;
            }
            else
            {
                noway_assert(sz == sizeof(BYTE) || sz == sizeof(WORD));
                if (codeAddr > codeEndp - sz)
                goto TOO_FAR;
                varNum = (sz == sizeof(BYTE)) ? getU1LittleEndian(codeAddr)
                                              : getU2LittleEndian(codeAddr);
                varNum = compMapILargNum(varNum); // account for possible hidden param

                // This check is only intended to prevent an AV.  Bad varNum values will later
                // be handled properly by the verifier.
                if (varNum < lvaTableCnt)
                    lvaTable[varNum].lvArgWrite = 1;
            }
            break;
        }
```

Действительно, всё выглядит так, что для опкода `starg` в конечном итоге выполнится `goto InlineNever`. В `DEBUG`-режиме мы также получим сообщение, что процесс инлайнинга был прерван.

Эта «фича» используется в других местах JIT-а. Взглянем на фрагмент файла [importer.cpp](https://raw.githubusercontent.com/dotnet/coreclr/65456c070ffbc97f14c1c32318dabc221646d8d6/src/jit/importer.cpp):

```cs
/******************************************************************************
 Is this the original "this" argument to the call being inlined?
 
 Note that we do not inline methods with "starg 0", and so we do not need to
 worry about it.
*/
```

### Смотрим на Decimal

Вернёмся к нашему конструктору класса `Decimal`, убедимся, что копирование параметра `value` в локальную переменную действительно помогает. Вооружимся [ILSpy](http://ilspy.net/) и взглянем на IL-код нашего конструктора:

```
// Methods
.method public hidebysig specialname rtspecialname 
  instance void .ctor (
    int32 'value'
  ) cil managed 
{
  .custom instance void __DynamicallyInvokableAttribute::.ctor() = (
    01 00 00 00
  )
  // Method begins at RVA 0x222e8
  // Code size 51 (0x33)
  .maxstack 2
  .locals init (
    [0] int32
  )

  IL_0000: ldarg.1
  IL_0001: stloc.0
  IL_0002: ldloc.0
  IL_0003: ldc.i4.0
  IL_0004: blt.s IL_000f

  IL_0006: ldarg.0
  IL_0007: ldc.i4.0
  IL_0008: stfld int32 System.Decimal::'flags'
  IL_000d: br.s IL_001d

  IL_000f: ldarg.0
  IL_0010: ldc.i4 -2147483648
  IL_0015: stfld int32 System.Decimal::'flags'
  IL_001a: ldloc.0
  IL_001b: neg
  IL_001c: stloc.0

  IL_001d: ldarg.0
  IL_001e: ldloc.0
  IL_001f: stfld int32 System.Decimal::lo
  IL_0024: ldarg.0
  IL_0025: ldc.i4.0
  IL_0026: stfld int32 System.Decimal::mid
  IL_002b: ldarg.0
  IL_002c: ldc.i4.0
  IL_002d: stfld int32 System.Decimal::hi
  IL_0032: ret
} // end of method Decimal::.ctor
```

А что было бы, если бы мы не скопировали `value` в локальную переменную? Давайте проверим. Напишем простой код:

```cs
class MyDecimal
{
  private const int SignMask  = unchecked((int)0x80000000);
  private int flags, hi, lo, mid;

  public MyDecimal(int value)
  {
    if (value >= 0) {
        flags = 0;
    }
    else {
        flags = SignMask;
        value = -value;
    }
    lo = value;
    mid = 0;
    hi = 0;
  }
}
class Program
{
  static void Main()
  {
  }
}
```

Скомпилируем его:

```
>csc Program.cs /optimize
Microsoft (R) Visual C# Compiler version 4.0.30319.33440
for Microsoft (R) .NET Framework 4.5
Copyright (C) Microsoft Corporation. All rights reserved.
```

И взглянем на IL:

```
.class private auto ansi beforefieldinit MyDecimal
  extends [mscorlib]System.Object
{
  // Fields
  .field private static literal int32 SignMask = int32(-2147483648)
  .field private int32 'flags'
  .field private int32 hi
  .field private int32 lo
  .field private int32 mid

  // Methods
  .method public hidebysig specialname rtspecialname 
    instance void .ctor (
      int32 'value'
    ) cil managed 
  {
    // Method begins at RVA 0x2050
    // Code size 56 (0x38)
    .maxstack 8

    IL_0000: ldarg.0
    IL_0001: call instance void [mscorlib]System.Object::.ctor()
    IL_0006: ldarg.1
    IL_0007: ldc.i4.0
    IL_0008: blt.s IL_0013

    IL_000a: ldarg.0
    IL_000b: ldc.i4.0
    IL_000c: stfld int32 MyDecimal::'flags'
    IL_0011: br.s IL_0022

    IL_0013: ldarg.0
    IL_0014: ldc.i4 -2147483648
    IL_0019: stfld int32 MyDecimal::'flags'
    IL_001e: ldarg.1
    IL_001f: neg
    IL_0020: starg.s 'value'

    IL_0022: ldarg.0
    IL_0023: ldarg.1
    IL_0024: stfld int32 MyDecimal::lo
    IL_0029: ldarg.0
    IL_002a: ldc.i4.0
    IL_002b: stfld int32 MyDecimal::mid
    IL_0030: ldarg.0
    IL_0031: ldc.i4.0
    IL_0032: stfld int32 MyDecimal::hi
    IL_0037: ret
  } // end of method MyDecimal::.ctor

} // end of class MyDecimal
```

Как мы видим, в строчке `IL_0020` действительно вызывается команда `starg.a`. Подобный приём используется также в конструкторе, который принимает аргумент типа `long`:

```
// Constructs a Decimal from a long value.
//
public Decimal(long value) {
    //  JIT today can't inline methods that contains "starg" opcode.
    //  For more details, see DevDiv Bugs 81184: x86 JIT CQ: Removing the inline striction of "starg".
    long value_copy = value;
    if (value_copy >= 0) {
        flags = 0;
    }
    else {
        flags = SignMask;
        value_copy = -value_copy;
    }
    lo = (int)value_copy;
    mid = (int)(value_copy >> 32);
    hi = 0;
}
```

### Проверяем возможности JIT

Для полноты исследования осталось убедиться, что JIT действительно себя ведёт именно так. Напишем простой код для проверки:

```cs
using System;
using System.Runtime.CompilerServices;

class Program
{
    static void Main()
    {
        var value = 0;
        value += SimpleMethod(0x11);
        value += MethodWithStarg(0x12);
        value += MethodWithStargAggressive(0x13);
        Console.WriteLine(value);
    }

    static int SimpleMethod(int value)
    {
        return value;
    }

    static int MethodWithStarg(int value)
    {
        if (value < 0)
            value = -value;
        return value;
    }

    [MethodImpl(MethodImplOptions.AggressiveInlining)]
    static int MethodWithStargAggressive(int value)
    {
        if (value < 0)
            value = -value;
        return value;
    }
}
```

Метод `SimpleMethod` очень маленький и будет заинлайнен. Метод `MethodWithStarg` имеет следующее IL-представление:

```cs
.method private hidebysig static 
  int32 MethodWithStarg (
    int32 'value'
  ) cil managed 
{
  // Method begins at RVA 0x2086
  // Code size 10 (0xa)
  .maxstack 8

  IL_0000: ldarg.0
  IL_0001: ldc.i4.0
  IL_0002: bge.s IL_0008

  IL_0004: ldarg.0
  IL_0005: neg
  IL_0006: starg.s 'value'

  IL_0008: ldarg.0
  IL_0009: ret
} // end of method Program::MethodWithStarg
```

Данный код в строчке `IL_0006` содержит интересующую нас команду `starg.s`. Метод `MethodWithStargAggressive` имеет аналогичный код с той лишь разнице, что для него указан атрибут `[MethodImpl(MethodImplOptions.AggressiveInlining)]`. Взглянем на ассемблерный код под x86:

```
008A0050  push        ebp  
008A0051  mov         ebp,esp  
008A0053  push        esi  
008A0054  mov         ecx,12h  
008A0059  call        dword ptr ds:[7237BCh]  // MethodWithStarg
008A005F  add         eax,11h  
008A0062  mov         esi,eax  
008A0064  mov         ecx,13h  
008A0069  call        dword ptr ds:[7237C8h]  // MethodWithStargAggressive
008A006F  add         esi,eax  
```

Эксперимент прошёл успешно. Метод `SimpleMethod` был заинлайнен, как и предполагалось. Метод `MethodWithStarg` не был заинлайнен, т. к. содержит IL-команду `starg.s`. Даже атрибут `[MethodImpl(MethodImplOptions.AggressiveInlining)]` не поспособствовал тому, чтобы инлайнинг был выполнен.

А теперь взглянем на ассемблерный код под x64:

```
00007FFCC8720094  mov         ecx,36h
```

Как мы видим, JIT успешно выполнил инлайнинг всех методов и заранее предподсчитал результат.

### Выводы

Для возможности инлайнинга методов необходимо выполнение ряда условий. JIT-x86 не может заинлайнить метод, в теле которого присутствуют IL-команды `starg` или `ldarga`, при этом даже `MethodImplOptions.AggressiveInlining` не в силах на это повлиять. Если вам критично, чтобы JIT мог выполнять инлайнинг, то порой придётся делать костыли, подобные тем, которые мы можем наблюдать в конструкторах класса `Decimal`.

### Ссылки

* [.NET Reference Source: Constructs a Decimal from an integer value](http://referencesource.microsoft.com/#mscorlib/system/decimal.cs,158)
* [CoreCLR, JIT sources: flowgraph.cpp (Feb 26, 2015)](https://github.com/dotnet/coreclr/blob/65456c070ffbc97f14c1c32318dabc221646d8d6/src/jit/flowgraph.cpp#L4252)
* [CoreCLR, JIT sources: importer.cpp (Feb 26, 2015)](https://raw.githubusercontent.com/dotnet/coreclr/65456c070ffbc97f14c1c32318dabc221646d8d6/src/jit/importer.cpp)
* [MSDN: starg](https://msdn.microsoft.com/library/system.reflection.emit.opcodes.starg.aspx)
* [MSDN: ldarga](https://msdn.microsoft.com/library/system.reflection.emit.opcodes.ldarga.aspx)
* [Stackoverflow: .NET local variable optimization](http://stackoverflow.com/questions/26369163/net-local-variable-optimization)