---
layout: ru-post
title: "Вся правда о TypeHandle в .NET"
date: "2013-09-14"
lang: ru
type: post
tags:
- ".NET"
- CLR
- CLI
- TypeHandle
- MethodTable
- TypeDesc
redirect_from:
- /ru/blog/dotnet/typehandle/
- /ru/blog/post/typehandle/
---

В разных умных книжках и статьях про .NET я часто наталкивался на упоминания про TypeHandle. Чаще всего пишут, что у каждого .NET-объекта в заголовке находится некоторый TypeHandle, который представляет собой ссылку на тип. Ещё пишут, что TypeHandle — это всегда указатель на таблицу методов типа. А в некоторых местах мне доводилось встречать информацию о том, что TypeHandle указывает на некий TypeDesc. В общем, я устал от неразберихи: давайте вместе разберёмся что к чему. А для этого нам придётся немного подизассемблировать, поизучать дампы памяти и залезть в исходники CLI.<!--more-->

### Что нам понадобится?

* Нам нужна будет Visual Studio. А в ней нам понадобится консольное приложение, над которым мы будем ставить наши эксперименты. Для чистоты эксперимента не забываем поставить сборку проекта в `Release mode`, а для честного дебага уберём галочку Suppress JIT optimization on module load (`Tools` -> `Options` -> `Debugging` -> `General`). В свойствах проекта на вкладке `Debug` нужно включить опцию `Enable native code debugging`. Для простоты примера будем собирать наш проект под `x86`.

* Расширение отладки [SOS](http://msdn.microsoft.com/ru-ru/library/bb190764.aspx).
* [Shared Source Common Language Infrastructure 2.0](http://www.microsoft.com/en-us/download/details.aspx?id=4917)

### Пример 1

Начнём с совсем простого примера:

```cs
object a = new object();
Console.WriteLine(a);
Console.ReadLine();
```

Последние пара строчек нужна затем, чтобы можно было нормально подебажить (в дальнейшем я их приводить не буду). Давайте поставим точку останова на второй строчке и запустим наше приложение из студии (через `F5`). Для удобной отладки нам понадобится несколько окошек: `Disassembly`, `Registers`, `Memory` (их можно найти в `Debug` -> `Windows`).

<p class="center">
  <img src="/img/posts/dotnet/typehandle/screen.png" />
</p>

Наш объект только что создался, а его адрес вернулся нам через регистр `eax`:

```
;       object a = new object();
00000000  push        ebp 
00000001  mov         ebp,esp 
00000003  push        esi 
00000004  mov         ecx,65C4B060h 
00000009  call        FE6BF7A0      ; адрес нового объекта записывается в eax
0000000e  mov         esi,eax 
;       Console.WriteLine(a);
00000010  call        63ECA5E4 
;       ...
```

В окне `Registers` находим значение eax (у вас адреса будут другие)

```
EAX = 01ED1598 EBX = 0543EA64 
ECX = 65C4B060 EDX = 005495E8 
ESI = 01ED1598 EDI = 0543E9D0 
EIP = 01CF2970 ESP = 0543E9B0 
EBP = 0543E9B4 EFL = 00000212 
```

и копируем его в поле Address окна Memory:

```
0x01ED1594  00000000  
0x01ED1598  65c4b060  
0x01ED159C  00000000  
```

Заметьте, что я привёл дамп памяти размером 12 байт — именно столько занимает сейчас наш объект. Разберёмся более подробно: в заголовке каждого объекта всегда присутствует два поля: `SyncBlockIndex` (который размещается непосредственно перед объектом, т.е. обладает отрицательным смещением) и то, что мы пока назовём «ссылкой на тип». Под архитектуру `x86` каждое из этих полей занимает 4 байта. Но особенности работы GC требуют, чтобы минимальный размер объекта был 12 байт. Поэтому CLR аккуратненько дополняет объект 4 байтами до нужного размера. Давайте посмотрим на наш объект с помощью SOS. Откроем Immediate Window (для каждой дебаг-сессии необходимо включить SOS с помощью команды `.load sos.dll`) и воспользуемся командой `!DumpObj`, которой отдадим адрес нашего объекта:

```
.load sos.dll
!DumpObj 0x01ED1598
Name:        System.Object
MethodTable: 65c4b060
EEClass:     65854920
Size:        12(0xc) bytes
File:        C:\WINDOWS\Microsoft.Net\assembly\GAC_32\mscorlib\v4.0_4.0.0.0__b77a5c561934e089\mscorlib.dll
Object
Fields:
```

Ага, теперь понятно: значение `0x65c4b060` — это адрес таблицы методов (MethodTable) для нашего объекта. Давайте проверим эту гипотезу: воспользуемся командой
`!DumpMT` для просмотра таблицы методов (если вы запустите эту команду с ключом `-MD`
, то кроме заголовочной информации увидите ещё и все методы):

```
!DumpMT 65c4b060
EEClass:         65854920
Module:          65851000
Name:            System.Object
mdToken:         02000002
File:            C:\WINDOWS\Microsoft.Net\assembly\GAC_32\mscorlib\v4.0_4.0.0.0__b77a5c561934e089\mscorlib.dll
BaseSize:        0xc
ComponentSize:   0x0
Slots in VTable: 12
Number of IFaces in IFaceMap: 0
```

Казалось бы всё понятно: в начале каждого объекта хранится ссылка на MethodTable — так CLR узнаёт к какому типу относится объект. Но не будем делать выводы по одному примеру: давайте взглянем на исходники CLI. В этом нам поможет [SSCLI](http://en.wikipedia.org/wiki/Shared_Source_Common_Language_Infrastructure) (в узких кругах известная как Rotor) — это открытые исходники реализации CLI от Microsoft. Увы, последняя версия SSCLI 2.0 датируется 2006-ым годом и относится к .NET Framework 2.0. Понадеемся, что базовые принципы хранения объектов в памяти не сильно поменялись за последнее время. Если открыть файл `sscli20\clr\src\vm\object.h`, то ближе к началу можно найти такие строчки:

```
class Object
{
  protected:
    MethodTable*    m_pMethTab;
```

Ну, вроде всё верно: в объекте действительно хранится указатель на MethodTable. Такое заключение вы можете встретить во многих статьях и книжках. Только вот некоторые называют его просто указателем на MethodTable, а некоторые — TypeHandle. Как считаете, правильно ли это? Давайте разбираться дальше.

### Пример 2

А теперь перейдём к устройству массива:

```cs
var a = new object[1];
a[0] = new object();  
```

Точно также перейдём в дебаггер, найдём адрес массива через регистры и посмотрим дамп памяти:

```cs
0x02F9240C  00000000  // SyncBlockIndex (a)
0x02F92410  65bfab98  // System.Object[] MethodTable (a)
0x02F92414  00000001  // a.Length
0x02F92418  65c4b060  // (???) Type of elements in a
0x02F9241C  02f92424  // &a[0]
0x02F92420  00000000  // SyncBlockIndex (a[0])
0x02F92424  65c4b060  // System.Object MethodTable (a[0])
0x02F92428  00000000  // Free space (a[0])
```

После ссылки на таблицу методов для массива `a` идёт количество элементов в массиве (1), а затем — «ссылка на тип» элементов массива. Обратите внимание, я ещё ничего не утверждаю об этих данных в общем случае. Просто имеется известный факт о том, что у массивов, элементы которых являются ссылочным типом, имеются дополнительные данные, которые некоторым образом характеризуют тип элементов массива. После всех этих служебных данных находится содержание массива — единственный элемент, хранящий адрес созданного `object`. Легко видеть, что поле

```
0x02F92418  65c4b060 // System.Object[] MethodTable
```

указывает на таблицу методов для `System.Object`. Ну, вроде бы всё понятно: в массивах, элементы которого являются ссылочным типом, появляется дополнительное поле, которое указывает на MethodTable типа элементов. Но так ли это? Продолжим наше исследование.

### Пример 3

А теперь создадим jagged-массив:

```cs
var a = new object[1][];
a[0] = new object[1];
```

Обратимся к дампу памяти:

```
0x0301240C  00000000  // SyncBlockIndex (a)
0x03012410  011731d4  // System.Object[][] MethodTable (a)
0x03012414  00000001  // a.Length
0x03012418  65854d7a  // (???) Type of elements in a
0x0301241C  03012424  // &a[0]
0x03012420  00000000  // SyncBlockIndex (a[0])
0x03012424  65bfab98  // System.Object[] MethodTable
0x03012428  00000001  // a[0].Length
0x0301242C  65c4b060  // Type of elements in a[0] = System.Object MethodTable
```

В этом дампе можно увидеть нечто странное: поле, которое должно определять тип элементов массива `a` (по адресу `0x03012418`) не ведёт на `System.Object[]`
MethodTable — ведь адрес этой таблицы можно найти по адресу (`0x03012424`) при описании MethodTable для `a[0]` — и они различаются. Давайте убедимся, что значение
`0x65854d7a` не определяет MethodTable:

```
!DumpMT 65854d7a
65854d7a is not a MethodTable
```

Хм... Но что же это тогда такое? Давайте обратимся к исходникам CLI за объяснением. В фале `sscli20\clr\src\vm\object.h` также можно найти следующий код:

```cs
// ArrayBase encapuslates all of these details.  In theory you should never
// have to peek inside this abstraction
class ArrayBase : public Object
{
    ...
    // This MUST be the first field, so that it directly follows Object.  This is because
    // Object::GetSize() looks at m_NumComponents even though it may not be an array (the
    // values is shifted out if not an array, so it's ok). 
    DWORD       m_NumComponents;
    ...
    // What comes after this conceputally is:
    // TypeHandle elementType;        Only present if the method table is shared among many types (arrays of pointers)
    // INT32      bounds[rank];       The bounds are only present for Multidimensional arrays   
    // INT32      lowerBounds[rank];  Valid indexes are lowerBounds[i] <= index[i] < lowerBounds[i] + bounds[i]
```

Мы видим, что для массивов из элементов ссылочного типа (arrays of pointers) действительно появляется дополнительное поле, а тип его — TypeHandle. Но что же это такое? Перейдём к файлу `sscli20\clr\src\vm\typehandle.h` . В самом начале файла к комментариях можно найти следующую полезную информацию:

```cs
// A TypeHandle is the FUNDAMENTAL concept of type identity in the CLR.
// That is two types are equal if and only if their type handles
// are equal.  A TypeHandle, is a pointer sized struture that encodes 
// everything you need to know to figure out what kind of type you are
// actually dealing with.  

// At the present time a TypeHandle can point at two possible things
//
//      1) A MethodTable    (Intrinsics, Classes, Value Types and their instantiations)
//      2) A TypeDesc       (all other cases: arrays, byrefs, pointer types, function pointers, generic type variables)  
//
// or with IL stubs, a third thing:
//
//      3) A MethodTable for a native value type.
//
// MTs that satisfy IsSharedByReferenceArrayTypes are not 
// valid TypeHandles: for example no allocated object will
// ever return such a type handle from Object::GetTypeHandle(), and
// these type handles should not be passed across the JIT Interface
// as CORINFO_CLASS_HANDLEs.  However some code in the EE does create 
// temporary TypeHandles out of these MTs, so we can't yet assert 
// !IsSharedByReferenceArrayTypes() in the TypeHandle constructor.
```

Ага, значит TypeHandle может быть как указателем на MethodTable, так и указателем на TypeDesc, в зависимости от типа объекта. Для массивов он указывает на TypeDesc. Тип `object[][]` — это массив, элементами которого являются `object[]`, для которых TypeHandle=TypeDesc. Эта информация объясняет наш пример, но всё ещё остаются некоторые вопросы. Например: а как же отличить, на что именно указывает TypeHandle? Поможет нам в этом дальнейшее изучение исходников CLI:

```
   FORCEINLINE BOOL IsUnsharedMT() const {
        LEAF_CONTRACT;
        STATIC_CONTRACT_SO_TOLERANT;
        return((m_asTAddr & 2) == 0);
    }

    FORCEINLINE BOOL IsTypeDesc() const  {
        WRAPPER_CONTRACT;
        return(!IsUnsharedMT());
    }
```

Всё зависит от второго бита в адресе: нулевое значение определяет MethodTable, а единичное — TypeDesc. Если мы работаем с шестнадцатеричными адресами, то можно легко определить вид TypeHandle по последней цифре:

```
MethodTable: 0, 1, 4, 5, 8, 9, C, D
TypeDesc   : 2, 3, 6, 7, A, B, E, F
```

А теперь взглянем ещё раз на дамп памяти нашего примера. Можно видеть, что для `System.Object[]` в дампе присутствуют указатели как на его TypeDesc, так и на MethodTable. Не смотря на то, что под TypeHandle в данном случае подразумевается TypeDesc, заголовочный указатель для `a[0]` всё-таки указывает на MethodTable. Поэтому некорректно говорить о том, что в заголовке каждого объекта хранится TypeHandle: там хранится указатель на MethodTable, а это далеко не всегда одно и то же.

### Пример 4

Последний пример проиллюстрирует недавно полученное правило про последнюю цифру адреса. Мы можем получить TypeHandle прямо из управляемого кода, а по этому значению мы можем определить, что именно под ним подразумевается:

```cs
private void Run()
{
    Print(typeof(int));
    Print(typeof(object));
    Print(typeof(Stream));
    Print(typeof(int[]));
    Print(typeof(int[][]));
    Print(typeof(object[]));
}

private void Print(Type type)
{
    bool isTypeDesc = ((int)type.TypeHandle.Value & 2) > 0;
    Console.WriteLine("{0}: {1} => {2}", 
        type.Name.PadRight(10), 
        type.TypeHandle.Value.ToString("X"), 
        (isTypeDesc ? "TypeDesc" : "MethodTable"));
}
```

У меня этот код выводит следующее:

```
Int32     : 65C4C480 => MethodTable
Object    : 65C4B060 => MethodTable
Stream    : 65C4D954 => MethodTable
Int32[]   : 65854C8A => TypeDesc
Int32[][] : 658F6BD6 => TypeDesc
Object[]  : 65854D7A => TypeDesc
```

### Выводы

В ходе нашего маленького исследования были получены следующие выводы:

* TypeHandle является указателем либо на MethodTable, либо на TypeDesc (зависит от типа объекта)
* В заголовке каждого объекта для идентификации его типа всегда хранится указатель на MethodTable (это не всегда TypeHandle)
* Для массивов, чьи элементы должны представлять ссылочный тип, хранится дополнительное поле, которое представляет собой TypeHandle для типа элементов.