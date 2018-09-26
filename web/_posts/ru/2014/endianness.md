---
layout: ru-post
title: Endianness в .NET
date: "2014-10-29"
lang: ru
type: post
tags:
- ".NET"
- Endianness
- ASM
- Mono
- C#
redirect_from:
- /ru/blog/dotnet/endianness/
- /ru/blog/post/endianness/
---

<table class="table-ok">
    <tr>
        <td valign="top">
            <div class="separator" style="clear: both; text-align: center;">
                <img src="/img/posts/dotnet/endianness/front.png" alt="Endian funny image" style="margin: 0 2em 1em 0;" />
            </div>
        </td>
        <td valign="top">
            <p>Рассмотрим простую задачку: что выведет следующий код?</p>
<pre class="prettyprint lang-cs">
[StructLayout(LayoutKind.Explicit)]
struct UInt16Wrapper
{
  [FieldOffset(0)]
  public UInt16 Value;
  [FieldOffset(0)]
  public Byte Byte1;
  [FieldOffset(1)]
  public Byte Byte2;
}
void Main()
{
  var uint16 = new UInt16Wrapper();
  uint16.Value = 1 + 2 * 256;
  Console.WriteLine(uint16.Byte1);
  Console.WriteLine(uint16.Byte2);
}
</pre>
        </td>
    </tr>
</table>

Полагаю, что внимательный читатель должен обратить внимание на название поста и дать правильный ответ: «зависит». Сегодня мы немного поговорим о том, как в .NET обстоят дела с порядком байтов.<!--more-->


### Небольшой обзор

Про то, что такое endianness и зачем он нужен, я писать не буду — на эту тему и так хватает материала ([Endianness](http://en.wikipedia.org/wiki/Endianness)), [Comparison of instruction set architectures](http://en.wikipedia.org/wiki/Comparison_of_instruction_set_architectures#Endianness), [Разбираемся с прямым и обратным порядком байтов](http://habrahabr.ru/post/233245/)). Ответ на задачку можно легко найти в [ECMA-335](http://www.ecma-international.org/publications/standards/Ecma-335.htm), «I.12.6.3  Byte ordering»:

> For data types larger than 1 byte, the byte ordering is dependent on the target CPU. Code that depends on byte ordering might not run on all platforms. The PE file format (see §I.12.2) allows the file to be marked to indicate that it depends on a particular type ordering.

Ну, казалось бы, всё просто: зависит от конкретной архитектуры. Только вот архитектур у нас много. Например, Mono [поддерживает](http://www.mono-project.com/docs/about-mono/supported-platforms/) в числе прочего [x86](http://en.wikipedia.org/wiki/X86), [x64](http://en.wikipedia.org/wiki/X86-64) ([Little-endian](http://en.wikipedia.org/wiki/Endianness#Little-endian)); [s390](http://en.wikipedia.org/wiki/IBM_ESA/390) ([Big-endian](http://en.wikipedia.org/wiki/Endianness#Big-endian)); [PowerPC](http://en.wikipedia.org/wiki/PowerPC), [SPARC](http://en.wikipedia.org/wiki/SPARC), [ARM](http://en.wikipedia.org/wiki/ARM_architecture), [IA64](http://en.wikipedia.org/wiki/Itanium) ([Bi-endian](http://en.wikipedia.org/wiki/Endianness#Bi-endian_hardware), т.е. есть возможность переключаться между Little/Big-endian). Общая мораль такова: лучше не закладываться на какой-то конкретный порядок байт. Конечно, скорее всего вы пишете под x86 или x64 и можете представлять себе всю память как Little-endian, но нужно держать в уме, что это может быть и не так (особенно актуально в свете распространённости ARM для мобильных устройств).

### Погружаемся внутрь

Данный раздел предназначен для тех, кто любит залезать внутрь своих программ. Если вы не из таких, то можете просто перейти к следующему разделу. А с теми, кому всё-таки интересно, вернёмся к рассмотрению нашего примера и взглянем на IL-код метода Main:

```
.class nested private explicit ansi sealed beforefieldinit UInt16Wrapper
  extends [mscorlib]System.ValueType
{
  // Fields
  .field [0] public uint16 Value
  .field [0] public uint8 Byte1
  .field [1] public uint8 Byte2
} // end of class UInt16Wrapper

.method private hidebysig 
  instance void Run () cil managed 
{
  // Method begins at RVA 0x205c
  // Code size 45 (0x2d)
  .maxstack 2
  .locals init (
    [0] valuetype Program/UInt16Wrapper uint16
  )

  IL_0000: ldloca.s uint16
  IL_0002: initobj Program/UInt16Wrapper
  IL_0008: ldloca.s uint16
  IL_000a: ldc.i4 513
  IL_000f: stfld uint16 Program/UInt16Wrapper::Value
  IL_0014: ldloca.s uint16
  IL_0016: ldfld uint8 Program/UInt16Wrapper::Byte1
  IL_001b: call void [mscorlib]System.Console::WriteLine(int32)
  IL_0020: ldloca.s uint16
  IL_0022: ldfld uint8 Program/UInt16Wrapper::Byte2
  IL_0027: call void [mscorlib]System.Console::WriteLine(int32)
  IL_002c: ret
} // end of method Program::Run
```

Тут всё достаточно просто: в нашей структуре имеется три поля: одно двухбайтовое (`uint16`) и два однобайтовых (`uint8`). Двухбайтовое поле `Value` имеет смещение 0 байт. Первое однобайтовое поле `Byte1` также имеет смещение 0 байт, т.е. указывает в точности туда же, куда и `Value` (другими словами, на байт `Value` с младшим адресом). Второе однобайтовое поле `Byte2` имеет смещение 1 байт, т.е. указывает на байт `Value` со старшим адресом. В примере значение `Value` равно `1+2*256`. На моём компьютере архитектура x64, что означает Little-endian. Для простоты примера соберём программу под x86 (с точно таким же Little-endian) А значит в `Byte1` будет хранится `1`, а в `Byte2` — `2`. На консоли мы увидим:

```
1
2
```

Ради интереса взглянем на asm-код. Под Windows получим следующее:

```
        {
            var uint16 = new UInt16Wrapper();
00DE29A1  mov         ebp,esp  
00DE29A3  sub         esp,8  
00DE29A6  xor         eax,eax  
00DE29A8  mov         dword ptr [ebp-8],eax  
00DE29AB  mov         dword ptr [ebp-4],ecx  
00DE29AE  cmp         dword ptr ds:[4B51058h],0  
00DE29B5  je          00DE29BC  
00DE29B7  call        73DFC310  
00DE29BC  lea         eax,[ebp-8]  
00DE29BF  mov         word ptr [eax],0  
            uint16.Value = 1 + 2 * 256;
00DE29C4  mov         word ptr [ebp-8],201h  
            Console.WriteLine(uint16.Byte1);
00DE29CA  movzx       ecx,byte ptr [ebp-8]  
00DE29CE  call        7325A920  
            Console.WriteLine(uint16.Byte2);
00DE29D3  lea         eax,[ebp-8]  
00DE29D6  movzx       ecx,byte ptr [eax+1]  
00DE29DA  call        7325A920  
        }
00DE29DF  nop  
00DE29E0  mov         esp,ebp  
00DE29E2  pop         ebp  
00DE29E3  ret  
```

Значение нашего поля в шестнадцатеричном представлении имеет вид `201h`, а найти его мы можем по адресу `byte ptr [ebp-8]`. В первом случае (`00DE29CA`) мы просто загружаем значение по данному адресу в `ecx`, а во втором (`00DE29D3`) — сначала загружаем адрес в `eax`, а затем получаем значение из `byte ptr [eax+1]`. Для полноты эксперимента глянем также код под Linux. Я взял Ubuntu 14.04 и собрал следующую версию mono:

```
$ mono --version
Mono JIT compiler version 3.10.0
        TLS:           __thread
        SIGSEGV:       altstack
        Notifications: epoll
        Architecture:  amd64
        Disabled:      none
        Misc:          softdebug 
        LLVM:          supported, not enabled.
        GC:            sgen
```

Имеем код (x64-версия):

```
gram_Main:
//{
   0:   48 83 ec 08             sub    $0x8,%rsp
// var int16 = new Int16Wrapper();
   4:   66 c7 04 24 00 00       movw   $0x0,(%rsp)
   a:   66 c7 04 24 00 00       movw   $0x0,(%rsp)
// int16.Value = 1 + 2 * 256;
  10:   66 c7 04 24 01 02       movw   $0x201,(%rsp)
// Console.WriteLine(uint16.Byte1);
  16:   0f b6 3c 24             movzbl (%rsp),%edi
  1a:   49 bb 7e dc 0f 40 00    movabs $0x400fdc7e,%r11
  21:   00 00 00 
  24:   41 ff d3                callq  *%r11
// Console.WriteLine(uint16.Byte2);
  27:   0f b6 7c 24 01          movzbl 0x1(%rsp),%edi
  2c:   49 bb 7e dc 0f 40 00    movabs $0x400fdc7e,%r11
  33:   00 00 00 
  36:   41 ff d3                callq  *%r11
// }
  39:   48 83 c4 08             add    $0x8,%rsp
  3d:   c3                      retq 
```

Логика аналогична: по адресу `(%rsp)` загружаем целевое значение `$0x201`. Получаем `Byte1` по адресу `(%rsp)` и `Byte2` по адресу `0x1(%rsp)`.

### А как узнать порядок байт?

Если для вас критично то, в каком порядке байты идут в памяти, то неплохо было бы научиться узнавать: с какой архитектурой процессора мы имеем дело. Рассмотрим пару способов.

**Простой способ.** Благо, разработчики .NET позаботились о программистах и сделали специальное поле [BitConverter.IsLittleEndian](http://msdn.microsoft.com/library/system.bitconverter.islittleendian.aspx). Пользоваться им очень просто:

```cs
Console.WriteLine(BitConverter.IsLittleEndian ? "LittleEndian" : "BigEndian");
```

Класс [BitConverter](http://msdn.microsoft.com/en-us/library/system.bitconverter.aspx) удобно использовать для работы с отдельными байтами «большой» переменной. И этот способ намного предпочтительней, чем ручная работа с байтами. Вот хороший фрагмент из примера в официальной документации:

```cs
int value = 12345678;
byte[] bytes = BitConverter.GetBytes(value);
Console.WriteLine(BitConverter.ToString(bytes));
if (BitConverter.IsLittleEndian)
   Array.Reverse(bytes);
Console.WriteLine(BitConverter.ToString(bytes));
// The example displays the following output on a little-endian system: 
//       4E-61-BC-00
//       00-BC-61-4E
```
**Способ для тех, кто лёгких способов не ищет.** Следующий пример приведён сугубо в академических целях, в реальных проектах так писать не стоит. Допустим, мы не доверяем значению `BitConverter.IsLittleEndian` и хотим сами проверить порядок байт, в котором хранятся наши переменные. Нам в этом поможет `unsafe`-code. Просто создадим уже знакомое нам значение `0x201`, получим его адрес и возьмём байт по этому адресу. Получится следующий код:

```cs
public bool IsLittleEndian()
{
  UInt16 value = 0x201;
  unsafe
  {
    UInt16* valueAddress = &value;
    Byte* firstByteAddress = (Byte*)valueAddress;
    Byte firstByte = *firstByteAddress;
    return firstByte == 1;
  }
}
```

### BinaryReader/BinaryWriter

Ок, с хранением чисел в памяти разобрались. А что, если нам нужно читать/писать числа в бинарном виде? .NET предлагает нам для этого классы [BinaryReader](msdn.microsoft.com/library/system.io.binaryreader.aspx) и [BinaryWriter](http://msdn.microsoft.com/library/system.io.binarywriter.aspx). Но тут нужно быть аккуратным и помнить, что согласно документации эти классы *всегда* работают с данными в Little-endian формате. Если по какой-то причине вы хотите поработать с данными в формате с заданным порядком байт, то придётся либо ручками реверсировать каждое число для Big-endian, либо использовать какую-нибудь внешнюю библиотеку (например, класс EndianBitConverter из [MiscUtil](http://www.yoda.arachsys.com/csharp/miscutil/) от Джона Скита).

### Выводы

Всегда нужно помнить, что в разных местах для хранения чисел может использоваться разный порядок байт. А если вам доводится работать с памятью в бинарном виде, хранить числа в бинарном виде, передавать их по сети в бинарном виде или ещё что-нибудь делать с числами в бинарном виде, то к нюансу с порядком байт следует отнестись очень внимательно.
