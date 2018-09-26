---
layout: ru-post
title: "Сравнение производительности массивов в .NET"
date: "2013-08-31"
lang: ru
type: post
tags:
- ".NET"
- C#
- Benchmarking
- ASM
- JIT
- Arrays
redirect_from:
- /ru/blog/dotnet/arrays-access-performance/
- /ru/blog/post/arrays-access-performance/
---

## Часть 1

Платформа .NET поддерживает два способа задания многомерных массивов: прямоугольные (rectangular) и изломанные (jagged). Второй способ по сути представляет собой массив массивов. Это обстоятельство создаёт у многих программистов иллюзию того, что jagged-массивы должны работать медленнее, т.к. обращение к их элементам реализуется через многократные переходы по ссылкам в управляемой куче. Но на самом деле jagged-массивы могут работают быстрее (если речь идёт непосредственно о работе с массивами, а не о их инициализации), ведь они представляют собой комбинацию одномерных (single) массивов, работа с которыми в CLR весьма оптимизирована (за счёт IL-команд `newarr`, `ldelem`, `ldelema`, `ldlen`, `stelem`). Другим подходом к представлению многомерных данных является использование одномерного массива с ручным преобразованием координат (в массиве размерности N*M для обращения к элементу [i,j] будем писать [i*M+j]). Если производительности не хватает, то можно использовать неуправляемый код, но этот случай мы сейчас рассматривать не будем, остановимся на трёх вышеозначенных способах. Для замеров времени используется
[BenchmarkDotNet](https://github.com/AndreyAkinshin/BenchmarkDotNet). Рассмотрим C# код, который замеряет время работы каждого варианта (полный вариант кода:
[MultidimensionalArrayProgram.cs](https://github.com/AndreyAkinshin/BenchmarkDotNet/blob/master/Benchmarks/MultidimensionalArrayProgram.cs), тестировать следует в **Release mode without debugging**). Данные результаты получены в сборке под x64 для процессора Intel Core i7-3632QM CPU 2.20GHz и параметров N=M=100, IterationCount=100000. Исследование вопроса о влиянии используемой архитектуры и параметров запуска на результат бенчмарка можно найти во второй части статьи.<!--more-->

```cs
private const int N = 100, M = 100, IterationCount = 100000;
private int[] single;
private int[][] jagged;
private int[,] rectangular;

public void Run()
{
    var competition = new BenchmarkCompetition();

    competition.AddTask("Single",
        () => single = new int[N * M],
        () => SingleRun(single));

    competition.AddTask("Jagged",
        () =>
        {
            jagged = new int[N][];
            for (int i = 0; i < N; i++)
                jagged[i] = new int[M];
        },
        () => JaggedRun(jagged));

    competition.AddTask("Rectangular",
        () => rectangular = new int[N, M],
        () => RectangularRun(rectangular));

    competition.Run();
}

private int SingleRun(int[] a)
{
    int sum = 0;
    for (int iteration = 0; iteration < IterationCount; iteration++)
        for (int i = 0; i < N; i++)
            for (int j = 0; j < M; j++)
                sum += a[i * M + j];
    return sum;
}

private int JaggedRun(int[][] a)
{
    int sum = 0;
    for (int iteration = 0; iteration < IterationCount; iteration++)
        for (int i = 0; i < N; i++)
            for (int j = 0; j < M; j++)
                sum += a[i][j];
    return sum;
}

private int RectangularRun(int[,] a)
{
    int sum = 0;
    for (int iteration = 0; iteration < IterationCount; iteration++)
        for (int i = 0; i < N; i++)
            for (int j = 0; j < M; j++)
                sum += a[i, j];
    return sum;
}
```

Этот пример на моём ноутбуке даёт следующие результаты (запускать следует в Release mode):

```
Single:      542ms
Jagged:      346ms
Rectangular: 755ms
```

Как можно видеть, доступ к элементам jagged-массива всегда осуществляется заметно быстрее, чем доступ к элементам rectangular-массива. Работа с single-массивом будет происходить быстрее, чем с rectangular, но чуть медленнее, чем с jagged. Мне думается, что single работает чуть медленнее jagged в большей степени из-за следующей причины:

* На расчёт индекса i*M+j требуется время, не дающее оптимизации в сравнении с лишним вызовом `ldelem.ref`.

Чтобы лучше разобраться рассмотрим IL-код каждого из методов в release режиме (для упрощения чтения из каждого метода был убран цикл итераций по `iteration`).

<hr />

**single.il**

```
.method private hidebysig instance 
    int32 SingleAccessTest(int32[] a) cil managed
{
    .maxstack 4
    .locals init (
        [0] int32 sum,
        [1] int32 i,
        [2] int32 j)
    L_0000: ldc.i4.0     // Stack = [0]
    L_0001: stloc.0      // sum = 0, Stack = []
    L_0002: ldc.i4.0     // Stack = [0]
    L_0003: stloc.1      // i = 0, Stack = []
    L_0004: br.s L_0022  // GoTo L_0022
CY1 L_0006: ldc.i4.0     // Stack = [0]
    L_0007: stloc.2      // j = 0, Stack = []
    L_0008: br.s L_0019  // GoTo L_0019
CY2 L_000a: ldloc.0      // Stack = [sum]
    L_000b: ldarg.1      // Stack = [sum, a]
    L_000c: ldloc.1      // Stack = [sum, a, i]
    L_000d: ldc.i4.s 100 // Stack = [sum, a, i, 100]
    L_000f: mul          // Stack = [sum, a, i * 100]
    L_0010: ldloc.2      // Stack = [sum, a, i * 100, j]
    L_0011: add          // Stack = [sum, a, i * 100 + j]
    L_0012: ldelem.i4    // Stack = [sum, a[i * 100 + j]]
    L_0013: add          // Stack = [sum + a[i * 100 + j]]
    L_0014: stloc.0      // sum = sum + a[i * 100 + j], Stack = []
    L_0015: ldloc.2      // Stack = [j]
    L_0016: ldc.i4.1     // Stack = [j, 1]
    L_0017: add          // Stack = [j + 1]
    L_0018: stloc.2      // j = j + 1, Stack = []
CY2 L_0019: ldloc.2      // Stack = [j]
    L_001a: ldc.i4.s 100 // Stack = [j, 100]
    L_001c: blt.s L_000a // GoTo L_000a (if j < 100), Stack = []
    L_001e: ldloc.1      // Stack = [i]
    L_001f: ldc.i4.1     // Stack = [i, 1]
    L_0020: add          // Stack = [i + 1]
    L_0021: stloc.1      // i = i + 1, Stack = []
CY1 L_0022: ldloc.1      // Stack = [i]
    L_0023: ldc.i4.s 100 // Stack = [i, 100]
    L_0025: blt.s L_0006 // GoTo L_0006 (if i < 100), Stack = []
    L_0027: ldloc.0      // Stack = [sum]
    L_0028: ret          // return sum, Stack = []
}
```

---

**jagged.il**

```
.method private hidebysig instance 
    int32 JaggedAccessTest(int32[][] a) cil managed
{
    .maxstack 3
    .locals init (
        [0] int32 sum,
        [1] int32 i,
        [2] int32 j)
    L_0000: ldc.i4.0     // Stack = [0]
    L_0001: stloc.0      // sum = 0, Stack = []
    L_0002: ldc.i4.0     // Stack = [0]
    L_0003: stloc.1      // i = 0, Stack = []
    L_0004: br.s L_001f  // GoTo L_001f
CY1 L_0006: ldc.i4.0     // Stack = [0]
    L_0007: stloc.2      // j = 0, Stack = []
    L_0008: br.s L_0016  // Stack = []
CY2 L_000a: ldloc.0      // Stack = [sum]
    L_000b: ldarg.1      // Stack = [sum, a]
    L_000c: ldloc.1      // Stack = [sum, a, i]
    L_000d: ldelem.ref   // Stack = [sum, a[i]]
    L_000e: ldloc.2      // Stack = [sum, a[i], j]
    L_000f: ldelem.i4    // Stack = [sum, a[i][j]]
    L_0010: add          // Stack = [sum + a[i][j]]
    L_0011: stloc.0      // sum = sum + a[i][j], Stack = []
    L_0012: ldloc.2      // Stack = [j]
    L_0013: ldc.i4.1     // Stack = [j + 1]
    L_0014: add          // Stack = [j + 1]
    L_0015: stloc.2      // j = j + 1, Stack = []
CY2 L_0016: ldloc.2      // Stack = [j]
    L_0017: ldc.i4.s 100 // Stack = [j, 100]
    L_0019: blt.s L_000a // GoTo L_000a (if j < 100)
    L_001b: ldloc.1      // Stack = [i]
    L_001c: ldc.i4.1     // Stack = [i, 1]
    L_001d: add          // Stack = [i + 1]
    L_001e: stloc.1      // i = i + 1, Stack = []
CY1 L_001f: ldloc.1      // Stack = [i]
    L_0020: ldc.i4.s 100 // Stack = [i, 100]
    L_0022: blt.s L_0006 // GoTo L_0006 (if i < 100)
    L_0024: ldloc.0      // Stack = [sum]
    L_0025: ret          // return sum, Stack = []
}
```

---

**rectangular.il**

```
.method private hidebysig instance 
    int32 RectangularAccessTest(int32[0...,0...] a) cil managed
{
    .maxstack 4
    .locals init (
        [0] int32 sum,
        [1] int32 i,
        [2] int32 j)
    L_0000: ldc.i4.0     // Stack = [0]
    L_0001: stloc.0      // sum = 0, Stack = []
    L_0002: ldc.i4.0     // Stack = [0]
    L_0003: stloc.1      // i = 0, Stack = []
    L_0004: br.s L_0022  // GoTo L_0022
CY1 L_0006: ldc.i4.0     // Stack = [0]
    L_0007: stloc.2      // j = 0, Stack = []
    L_0008: br.s L_0019  // GoTo L_0019
CY2 L_000a: ldloc.0      // Stack = [sum]
    L_000b: ldarg.1      // Stack = [sum, a]
    L_000c: ldloc.1      // Stack = [sum, a, i]
    L_000d: ldloc.2      // Stack = [sum, a, i, j]
    L_000e: call instance int32 int32[0...,0...]::Get(int32, int32)
                         // Stack = [sum, a[i, j]]
    L_0013: add          // Stack = [sum + a[i, j]]
    L_0014: stloc.0      // sum = sum + a[i, j], Stack = []
    L_0015: ldloc.2      // Stack = [j]
    L_0016: ldc.i4.1     // Stack = [j, 1]
    L_0017: add          // Stack = [j + 1]
    L_0018: stloc.2      // j = j +1, Stack = []
CY2 L_0019: ldloc.2      // Stack = [j]
    L_001a: ldc.i4.s 100 // Stack = [j, 100]
    L_001c: blt.s L_000a // GoTo L_000a (if j < 100), Stack = []
    L_001e: ldloc.1      // Stack = [i]
    L_001f: ldc.i4.1     // Stack = [i, 1]
    L_0020: add          // Stack = [i + 1]
    L_0021: stloc.1      // i = i + 1, Stack = []
CY1 L_0022: ldloc.1      // Stack = [i]
    L_0023: ldc.i4.s 100 // Stack = [i, 100]
    L_0025: blt.s L_0006 // GoTo L_0006 (if i < 100), Stack = []
    L_0027: ldloc.0      // Stack = [sum]
    L_0028: ret          // return sum, Stack = []
}
```

## Часть 2

В первой части статьи я задался задачей сравнить производительность многомерных массивов. Рассматривались данные в виде двумерного массива N*M, тестировалась скорость доступа к элементу `[i,j]` при итерировании по всему массиву двумя циклами. Для сравнения было выбрано три варианта: одномерный массив `single[i * N + j]` и двумерные массивы `jagged[i][j]`, `rectangular[i, j]`. Изначально у меня получилось, что `jagged`-версия работает быстрее `single` версии, но более детальное изучение проблемы показало, что дело может измениться в зависимости от используемых JIT-оптимизаций. Разберёмся с проблемой более подробно.

Рассмотрим методы из [бенчмарка](https://github.com/AndreyAkinshin/BenchmarkDotNet/blob/master/Benchmarks/MultidimensionalArrayProgram.cs) с наборами параметров `«100»` (N=M=100, IterationCount=100000) и `«101»` (N=M=101, IterationCount=100001) под x86 и x64. На моей машине (Intel Core i7-3632QM CPU 2.20GHz) получились следующие результаты:

```
  100-x86
Single      : 1012ms
Jagged      :  772ms
Rectangular : 1460ms

  101-x86
Single      : 1036ms
Jagged      :  785ms
Rectangular : 1485ms  

  100-x64
Single      : 544ms
Jagged      : 346ms
Rectangular : 741ms

  101-x64
Single      :  785ms
Jagged      :  793ms
Rectangular : 1050ms
```

Любопытно, не правда ли? Ну, давайте разбираться. Сразу видно, что `Rectangular`-версия всегда работает медленнее двух других. Так происходит из-за того, что работа с одномерными массивами реализуется через команды `newarr`, `ldelem`, `ldelema`, `ldlen`, `stelem`, которые CLR в достаточной мере оптимизирует. Поэтому отложим рассмотрение `Rectangular`-метода на будущее, а сейчас сосредоточимся на сравнении `Single` и `Jagged` методов.

---

### x86

**Single-100-x86.asm**

```
00 push ebp 
01 mov  ebp,esp 
03 push edi 
04 push esi 
05 push ebx 
06 push eax 
07 xor  ecx,ecx                       ; sum = 0
09 mov  dword ptr [ebp-10h],ecx       ; iteration = 0
0c xor  ebx,ebx                       ; i = 0
0e xor  esi,esi                       ; j = 0
10 mov  edi,dword ptr [edx+4]         ; edi = a.Length
13 imul eax,ebx,64h                   ; eax = i * 100
16 add  eax,esi                       ; eax = i * 100 + j
18 cmp  eax,edi                       ; if i * 100 + j >= a.Length then
1a jae  00000040                      ; throw IndexOutOfRangeException
1c add  ecx,dword ptr [edx+eax*4+8]   ; sum += a[i * 100 + j]
20 inc  esi                           ; j++
21 cmp  esi,64h                       ; if j < 100 then
24 jl   00000013                      ; loop by j
26 inc  ebx                           ; i++
27 cmp  ebx,64h                       ; if i < 100 then
2a jl   0000000E                      ; loop by i
2c inc  dword ptr [ebp-10h]           ; iteration++
2f cmp  dword ptr [ebp-10h],186A0h    ; if iteration < 100000 then
36 jl   0000000C                      ; loop by iteration
38 mov  eax,ecx                       ; eax = sum (Result)
3a pop  ecx 
3b pop  ebx 
3c pop  esi 
3d pop  edi 
3e pop  ebp 
3f ret   
40 call 65BC5A15                      ; IndexOutOfRangeException
45 int  3 
```

**Jagged-100-x86.asm**

```
00  push ebp 
01  mov  ebp,esp 
03  push edi 
04  push esi 
05  push ebx 
06  push eax 
07  mov  ecx,edx                       ; ecx = &a
09  xor  ebx,ebx                       ; sum = 0
0b  mov  dword ptr [ebp-10h],ebx       ; iteration = 0
0e  xor  edx,edx                       ; i = 0
10  xor  esi,esi                       ; j = 0
12  mov  eax,dword ptr [ecx+4]         ; eax = a.Length
15  cmp  edx,eax                       ; if i >= a.Length then
17  jae  00000048                      ; throw IndexOutOfRangeException
19  mov  eax,dword ptr [ecx+edx*4+0Ch] ; eax = &a[i]
1d  mov  edi,dword ptr [eax+4]         ; edi = a[i].Length
20  cmp  esi,edi                       ; if j >= a[i].Length
22  jae  00000048                      ; throw IndexOutOfRangeException
24  add  ebx,dword ptr [eax+esi*4+8]   ; sum += a[i][j]
28  inc  esi                           ; j++
29  cmp  esi,64h                       ; if j < 100 then
2c  jl   00000020                      ; loop by j
2e  inc  edx                           ; i++
2f  cmp  edx,64h                       ; if i < 100 then
32  jl   00000010                      ; loop by i
34  inc  dword ptr [ebp-10h]           ; iteration++
37  cmp  dword ptr [ebp-10h],186A0h    ; if iteration < 100000 then
3e  jl   0000000E                      ; loop by iteration
40  mov  eax,ebx                       ; eax = sum (Result)
42  pop  ecx 
43  pop  ebx 
44  pop  esi 
45  pop  edi 
46  pop  ebp 
47  ret    
48  call 66935A55                      ; IndexOutOfRangeException
4d  int  3 
```

Большая часть кода в обоих методах совпадает. Сравним непосредственный код обращения к элементу:

```
; Single
13 imul eax,ebx,64h                    ; eax = i * 100
16 add  eax,esi                        ; eax = i * 100 + j
1c add  ecx,dword ptr [edx+eax*4+8]    ; sum += a[i * 100 + j]
; Jagged
19 mov  eax,dword ptr [ecx+edx*4+0Ch] ; eax = &a[i]
24 add  ebx,dword ptr [eax+esi*4+8]   ; sum += a[i][j]
```

Отсюда можно понять, почему же `jagged`-версия лидирует в скорости: для доступа к массиву нам необходимо всего навсего перейти по паре ссылок, а вот в `single`-версии приходится использовать «тяжёлые» операции `imul` и `add` для подсчёта индекса массива.

Оптимизаций по развертке цикла (см. [Loop unwinding](http://en.wikipedia.org/wiki/Loop_unwinding)) в данных методах не наблюдается, поэтому версия методов `101-x86`
не будет отличаться от `100-x86` за исключением подставленных констант.

---

### 100-x64

**Single-100-x64.asm**

```
000 push   rbx 
001 push   rbp 
002 push   rsi 
003 push   rdi 
004 push   r12 
006 push   r13 
008 push   r14 
00a push   r15 
00c sub    rsp,28h 
010 mov    rbx,rdx                     ; rbx = &a
013 xor    r11d,r11d                   ; iteration = 0
016 mov    r9d,r11d                    ; sum = 0
019 nop    dword ptr [rax+00000000h] 
020 xor    edi,edi                     ; (i*100) = 0
022 lea    eax,[rdi+64h]                
025 movsxd rcx,eax                      
028 lea    rbp,[rcx*4+00000000h]        ; rbp = 400  
030 movsxd rax,edi                     
033 lea    r10,[rax*4+00000000h]        ; j = 0
03b movsxd rax,edi 
03e lea    r8,[rax*4+00000000h] 
046 mov    rdx,qword ptr [rbx+8]        ; rdx = a.Length
04a lea    rsi,[rdx*4+00000000h]        ; rsi = a.Length * 4
052 lea    eax,[rdi+1] 
055 movsxd rcx,eax 
058 lea    r12,[rcx*4+00000000h]        ; r12 = 1 * 4
060 sub    r12,r8 
063 lea    r14,[rdx*4+00000000h]        ; r14 = a.Length * 4
06b lea    eax,[rdi+2] 
06e movsxd rcx,eax                        
071 lea    r13,[rcx*4+00000000h]        ; r13 = 2 * 4
079 sub    r13,r8                       
07c lea    r15,[rdx*4+00000000h]        ; r15 = a.Length * 4
084 lea    eax,[rdi+3]                  
087 movsxd rcx,eax                         
08a shl    rcx,2                           
08e sub    rcx,r8                       ; rcx = 3 * 4
091 shl    rdx,2                        ; rdx = a.Length * 4
095 cmp    r10,rsi                      ; if j >= a.Length then
098 jae    0000000000000110             ; throw IndexOutOfRangeException
09a mov    eax,dword ptr [rbx+r10+10h]  ; eax = a[j]
09f add    r9d,eax                      ; sum += a[j]
0a2 lea    rax,[r10+r12]                ; rax = (j + 1)*4
0a6 cmp    rax,r14                      ; if j + 1 >= a.Length then
0a9 jae    0000000000000110             ; throw IndexOutOfRangeException
0ab mov    eax,dword ptr [rbx+rax+10h]  ; eax = a[j + 1]
0af add    r9d,eax                      ; sum += a[j + 1]
0b2 lea    rax,[r10+r13]                ; rax = (j + 2)*4
0b6 cmp    rax,r15                      ; if j + 2 >= a.Length
0b9 jae    0000000000000110             ; throw IndexOutOfRangeException
0bb mov    eax,dword ptr [rbx+rax+10h]  ; eax = a[j + 2]
0bf add    r9d,eax                      ; sum += a[j + 2]
0c2 lea    rax,[r10+rcx]                ; rax = (j + 3)*4
0c6 cmp    rax,rdx                      ; if j >= a.Length
0c9 jae    0000000000000110             ; throw IndexOutOfRangeException
0cb mov    eax,dword ptr [rbx+rax+10h]  ; eax = a[j + 3]
0cf add    r9d,eax                      ; sum += a[j + 3]
0d2 add    r10,10h                      ; j += 4
0d6 cmp    r10,rbp                      ; if j < 100 then
0d9 jl     0000000000000095             ; loop by j
0db add    edi,64h                      ; (i*100) += 100
0de cmp    edi,2710h                    ; if (i*100) < 10000 then
0e4 jl     0000000000000022             ; loop by i
0ea inc    r11d                         ; iteration++
0ed cmp    r11d,186A0h                  ; if iteration < 100000 then
0f4 jl     0000000000000020             ; loop by iteration
0fa mov    eax,r9d                      ; eax = sum (Result)
0fd add    rsp,28h 
101 pop    r15 
103 pop    r14 
105 pop    r13 
107 pop    r12 
109 pop    rdi 
10a pop    rsi 
10b pop    rbp 
10c pop    rbx 
10d ret      
10e xchg   ax,ax 
110 call   000000005FA5AC24             ; IndexOutOfRangeException
```

---

**Jagged-100-x64.asm**

```
00 push rbx                                 
01 sub  rsp,20h                           
05 mov  r10,rdx                        ; r10 = &a
08 xor  edx,edx                        ; iteration = 0
0a mov  r8d,edx                        ; sum = 0
0d nop  dword ptr [rax]                    
10 xor  ecx,ecx                        ; i = 0
12 xor  r9d,r9d                        ; j = 0
15 mov  rax,qword ptr [r10+8]          ; rax = a.Length
19 cmp  rcx,rax                        ; if i >= a.Length
1c jae  0000000000000099               ; throw IndexOutOfRangeException
1e mov  r11,qword ptr [r10+rcx*8+18h]  ; r11 = &a[i]
23 mov  rax,qword ptr [r11+8]          ; rax = a[i].Length
27 mov  ebx,60h                        ; ebx = 96
2c cmp  rbx,rax                        ; if 96 >= a[i].Length
2f jae  0000000000000099               ; throw IndexOutOfRangeException
31 mov  ebx,61h                        ; ebx = 97
36 cmp  rbx,rax                        ; if 97 >= a[i].Length
39 jae  0000000000000099               ; throw IndexOutOfRangeException
3b mov  ebx,62h                        ; ebx = 98
40 cmp  rbx,rax                        ; if 98 >= a[i].Length
43 jae  0000000000000099               ; throw IndexOutOfRangeException
45 mov  ebx,63h                        ; ebx = 99
4a cmp  rbx,rax                        ; if 99 >= a[i].Length
4d jae  0000000000000099               ; throw IndexOutOfRangeException
4f nop                                      
50 mov  eax,dword ptr [r11+r9+10h]     ; eax = a[i][j]
55 add  r8d,eax                        ; sum += a[i][j]
58 mov  eax,dword ptr [r11+r9+14h]     ; eax = a[i][j + 1]
5d add  r8d,eax                        ; sum += a[i][j + 1]
60 mov  eax,dword ptr [r11+r9+18h]     ; eax = a[i][j + 2]
65 add  r8d,eax                        ; sum += a[i][j + 2]
68 mov  eax,dword ptr [r11+r9+1Ch]     ; eax = a[i][j + 3]
6d add  r8d,eax                        ; sum += a[i][j + 3]
70 add  r9,10h                         ; j + 4
74 cmp  r9,190h                        ; if j < 100 then
7b jl   0000000000000050               ; loop by j
7d inc  rcx                            ; i++
80 cmp  rcx,64h                        ; if i < 100 then
84 jl   0000000000000012               ; loop by i
86 inc  edx                            ; iteration++
88 cmp  edx,186A0h                     ; if iteration < 100000 then
8e jl   0000000000000010               ; loop by iteration
90 mov  eax,r8d                        ; eax = sum (Result)
93 add  rsp,20h                            
97 pop  rbx                               
98 ret                                      
99 call 000000005FA69BF4               ; IndexOutOfRangeException
9e nop              
```

Тут тоже всё понятно: `single`-версия тормозит из-за кучи операций с высчитыванием индексов, в то время как в `jagged` достаточно просто пару раз перейти по ссылкам. Обе версии работают намного быстрее своего x86-аналога, т.к. теперь у нас достаточно регистров, чтобы сделать оптимизацию по развёртке цикла (см. [Loop unwinding](http://en.wikipedia.org/wiki/Loop_unwinding)).

---

### 101-x64

**Single-101-x64.asm**

```
00 push   rbx 
01 sub    rsp,20h 
05 mov    r10,rdx                      ; r10 = &a
08 xor    edx,edx                      ; iteration = 0
0a mov    r9d,edx                      ; sum = 0
0d nop    dword ptr [rax] 
10 xor    r8d,r8d                      ; i = 0
13 nop    word ptr [rax+rax+00000000h] 
20 lea    eax,[r8+65h]                 ; eax = (i*101)+101
24 movsxd rcx,eax                      ; rcx = (i*101)+101
27 lea    rbx,[rcx*4+00000000h]        ; rbx = ((i*101)+101) * 4
2f movsxd rax,r8d                      ; rax = (i*101) * 4
32 lea    rcx,[rax*4+00000000h]        ; j = (i*101)
3a mov    rax,qword ptr [r10+8]        ; rax = a.Length
3e lea    r11,[rax*4+00000000h]        ; r11 = a.Length * 4
46 cmp    rcx,r11                      ; if j < a.Length
49 jae    0000000000000080             ; throw IndexOutOfRangeException
4b mov    eax,dword ptr [r10+rcx+10h]  ; eax = a[i * 101 + j]
50 add    r9d,eax                      ; sum += a[i * 101 + j]
53 add    rcx,4                        ; j++
57 cmp    rcx,rbx                      ; if j < (i*101)+101 then
5a jl     0000000000000046             ; loop by j
5c add    r8d,64h                      ; (i*100) += 100
60 cmp    r8d,2774h                    ; if (i*100) < 10100
67 jl     0000000000000020             ; loop by i
69 inc    edx                          ; iteration++
6b cmp    edx,186A1h                   ; if iteration < 100001 then
71 jl     0000000000000010             ; loop by iteration
73 mov    eax,r9d                      ; eax = sum (Result)
76 add    rsp,20h 
7a pop    rbx 
7b ret       
7c nop    dword ptr [rax] 
80 call   000000005FA5AC24             ; IndexOutOfRangeException
85 nop       
```

---

**Jagged-101-x64.asm**

```
00 push rbx 
01 sub  rsp,20h 
05 mov  r10,rdx                        ; r10 = &a
08 xor  edx,edx                        ; iteration = 0
0a mov  r9d,edx                        ; sum = 0
0d nop  dword ptr [rax] 
10 xor  ecx,ecx                        ; i = 0
12 xor  r8d,r8d                        ; j = 0
15 mov  rax,qword ptr [r10+8]          ; rax = a.Length
19 cmp  rcx,rax                        ; if i >= a.Length then
1c jae  0000000000000062               ; throw IndexOutOfRangeException
1e mov  r11,qword ptr [r10+rcx*8+18h]  ; r11 = &a[i]
23 mov  rax,qword ptr [r11+8]          ; rax = a[i].Length
27 mov  ebx,64h                        ; ebx = 100
2c cmp  rbx,rax                        ; if 100 >= a[i].Length then
2f jae  0000000000000062               ; throw IndexOutOfRangeException
31 mov  eax,dword ptr [r11+r8+10h]     ; eax = a[i][j]
36 add  r9d,eax                        ; sum += a[i][j]
39 add  r8,4                           ; j++
3d cmp  r8,194h                        ; if j < 101 then
44 jl   0000000000000031               ; loop by j
46 inc  rcx                            ; i++
49 cmp  rcx,65h                        ; if i < 101 then
4d jl   0000000000000012               ; loop by i
4f inc  edx                            ; iteration++
51 cmp  edx,186A1h                     ; if iteration < 100001 then
57 jl   0000000000000010               ; loop by iteration
59 mov  eax,r9d                        ; eax = sum (Result)
5c add  rsp,20h 
60 pop  rbx 
61 ret   
62 call 000000005FA69D04               ; IndexOutOfRangeException
67 nop   
```

Как можно видеть, в `101`-версии оптимизации развёртки цикла по очевидным причинам не стало. Однако, скорость работы методов сравнялась. Так произошло из-за того, что JIT под `x64` более оптимально реализовал `Single`-версию: он не стал явно высчитывать индекс каждый раз, а вместо этого он для каждой строки матрицы данных перед циклом по `j` высчитывает смещение, относительно которого берутся элементы. Таким образом, `Single` и `Jagged` версии выполняют практически одни и те же операции для получения элементов массива.

---

### Выводы

Быстродействие многих методов сильно зависит от произведённых JIT-оптимизаций, которые в свою очередь зависят от используемой архитектуры. Оптимизация развёртки цикла применяется в обоих случаях по самому вложенному циклу и не влияет на сравнение быстродействий разных способов. `Rectangular` версия всегда работает медленнее своих «конкурентов», т.к. в CLR работа с многомерными массивами такого рода организована сложнее, чем с одномерными.

`Single`-метод (`single[i*M+j]`) *обычно* работает медленнее, чем `Jagged` (`jagged[i][j]`), т.к. вычисление индекса `i*N+j` на каждой итерации является более затратной операцией, чем явный переход по двум ссылкам. Однако, они *могут сравняться* по времени работы, если JIT нужным образом соптимизирует `Single` версию. Если же говорить о непосредственном доступе к элементу без расчёта индекса, то `single[i]` будет лидировать в скорости по сравнению с `jagged[i][j]`.
