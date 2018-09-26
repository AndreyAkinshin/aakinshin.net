---
layout: ru-post
title: "Об итерировании статичных массивов в .NET"
date: "2013-08-29"
lang: ru
type: post
tags:
- ".NET"
- C#
- Benchmarking
- Static
- IL
- Arrays
redirect_from:
- /ru/blog/dotnet/static-array-iteration/
- /ru/blog/post/static-array-iteration/
---

## Часть 1

Управляемый подход платформы .NET делает жизнь разработчиков достаточно простой, беря на себя многие рутинные операции. Большую часть времени программист может вообще не вспоминать о технической реализации платформы, сосредоточившись исключительно на логике своего приложения. Но иногда попадаются задачи, критичные по производительности. Существует множество различных подходов к оптимизации кода в таких ситуациях вплоть до переписывания наиболее важных частей кода через неуправляемый код. Однако, зачастую для увеличения скорости приложения достаточно понимать, сколько времени тратится на ту или иную операцию. Знание подобных вещей позволит оптимизировать некоторые методы с помощью достаточно простых модификаций исходного кода.

В этой статье мне хотелось бы поговорить о скорости доступа к массивам, ссылки на которые хранятся в статичных переменных. Дело в том, что в скорость итерирования по ним в зависимости от условий запуска может быть ниже, чем для массива, ссылка на который хранится в обычном поле экземпляра класса или локальной переменной. Рассмотрим пример.<!--more-->

В примере будем решать простую задачу: подсчёт суммы элементов массива. В первом случае мы будем использовать обычное боле класса, а во втором — статическое. Для замеров времени будем использовать [BenchmarkDotNet](https://github.com/AndreyAkinshin/BenchmarkDotNet) (исходный код примера: [ArrayIterationProgram.cs](https://github.com/AndreyAkinshin/BenchmarkDotNet/blob/master/Benchmarks/ArrayIterationProgram.cs), тестировать следует в **Release mode without debugging**):

```cs
private const int N = 1000, IterationCount = 1000000;

private int[] nonStaticField;
private static int[] staticField;

public void Run()
{
    nonStaticField = staticField = new int[N];

    var competition = new BenchmarkCompetition();
    competition.AddTask("Non-static", () => NonStaticRun());
    competition.AddTask("Static", () => StaticRun());
    competition.Run();
}

private int NonStaticRun()
{
    int sum = 0;
    for (int iteration = 0; iteration < IterationCount; iteration++)
        for (int i = 0; i < N; i++)
            sum += nonStaticField[i];
    return sum;
}

private int StaticRun()
{
    int sum = 0;
    for (int iteration = 0; iteration < IterationCount; iteration++)
        for (int i = 0; i < N; i++)
            sum += staticField[i];
    return sum;
}
```

На своей машине я получил следующие результаты:

```
Non-static : 346ms
Static     : 535ms
```

Если мы взглянем на IL-код целевых методов, то увидим, что они различаются только в одном месте, при обращении к полю:

```
Non-static:
L_000b: ldarg.0 
L_000c: ldfld int32[] Benchmarks.StaticFieldBenchmark::nonStaticField
Static:
L_000b: ldsfld int32[] Benchmarks.StaticFieldBenchmark::staticField
```

Заметим, что физически оба поля ссылаются на одну и ту же область памяти. Мы можем ускорить работу со статическим полем, если перед многократным обращением к полю сохраним его в локальную переменную:

```cs
private int StaticRun()
{
    var localField = staticField;
    int sum = 0;
    for (int iteration = 0; iteration < IterationCount; iteration++)
        for (int i = 0; i < N; i++)
            sum += localField[i];
    return sum;
}
```

В итоге `StaticRun` будет работать столько же, сколько и `NonStaticRun`.

Объяснение такого поведения можно прочитать во второй части статьи.

## Часть 2

В первой части я встретился с весьма интересной ситуацией. Были измерены скорости работы двух методов, в первом из которых считалась сумма элементов массива, ссылка на который хранилась в обычном поле объекта, а во втором — массива, ссылка на который хранилась в статичном поле. Результаты меня удивили: массивы были одинаковые, но второй метод работал ощутимо дольше. Сперва я подумал, что дело в организации скорости доступа к статичным полям, но более детальный анализ ситуации и разговоры с коллегами помогли мне понять, что истинная причина такого поведения намного интересней: для массивов, длина которых кратна 4, JIT использует различные оптимизации в случае обычных и статичных массивов. Давайте разберёмся с ситуацией более детально.

Напомню методы, поведение которых мы будем изучать:

```
private const int N = 1000, IterationCount = 1000000;
private int[] nonStaticField;
private static int[] staticField;

public void Run()
{
    nonStaticField = staticField = new int[N];
    NonStaticRun();
    StaticRun();
}

private int NonStaticRun()
{
    int sum = 0;
    for (int iteration = 0; iteration < IterationCount; iteration++)
        for (int i = 0; i < N; i++)
            sum += nonStaticField[i];
    return sum;
}

private int StaticRun()
{
    int sum = 0;
    for (int iteration = 0; iteration < IterationCount; iteration++)
        for (int i = 0; i < N; i++)
            sum += staticField[i];
    return sum;
}
```

Для начала поменяем Platform target на x86 и запустим [бенчмарк](https://github.com/AndreyAkinshin/BenchmarkDotNet/blob/master/Benchmarks/ArrayIterationProgram.cs). Получим следующие результаты:

```
Non-static : 708ms
Static     : 709ms
```

Интересный вывод: на x86 результаты тестов одинаковы. Чтобы лучше разобраться в проблеме взглянем на нативный код, который получается после JIT-оптимизаций (изучается версия в Release mode without debugging). Конфигурация моей машины, на которой я проводил тестирование: Intel Core i7-3632QM CPU 2.20GHz.

**NonStaticRun-x86.asm**

```
00 push ebp 
01 mov  ebp,esp 
03 push edi 
04 push esi 
05 push ebx 
06 xor  edi,edi                     ; sum = 0
08 xor  ebx,ebx                     ; iteration
0a xor  edx,edx                     ; i = 0
0c mov  eax,dword ptr [ecx+4]       ; eax = &nonStaticField
0f mov  esi,dword ptr [eax+4]       ; esi = nonStaticField.Length
12 cmp  edx,esi                     ; if i >= nonStaticField.Length then
14 jae  00000033                    ; throw IndexOutOfRangeException
16 add  edi,dword ptr [eax+edx*4+8] ; sum += nonStaticField[i];
1a inc  edx                         ; i++
1b cmp  edx,3E8h                    ; if i < 1000 then
21 jl   00000012                    ; loop by i
23 inc  ebx                         ; iteration++
24 cmp  ebx,0F4240h                 ; if iteration < 1000000 then
2a jl   0000000A                    ; loop by iteration
2c mov  eax,edi                     ; eax = sum (Result)
2e pop  ebx 
2f pop  esi 
30 pop  edi 
31 pop  ebp 
32 ret 
33 call 63495C4D                    ; IndexOutOfRangeException
38 int  3 
```

**StaticRun-x86.asm**

```
00 push ebp 
01 mov  ebp,esp 
03 push edi 
04 push esi 
05 push ebx 
06 xor  edi,edi                      ; sum = 0
08 xor  ebx,ebx                      ; iteration = 0
0a xor  eax,eax                      ; i = 0
0c mov  edx,dword ptr ds:[03943380h] ; edx = &staticField
12 mov  esi,dword ptr [edx+4]        ; esi = staticField.Length 
15 cmp  eax,esi                      ; if i >= staticField.Length then
17 jae  00000035                     ; throw IndexOutOfRangeException
19 add  edi,dword ptr [edx+eax*4+8]  ; sum += staticField[i];
1d inc  eax                          ; i++
1e cmp  eax,3E8h                     ; if i < 1000 then
23 jl   00000015                     ; loop by i
25 inc  ebx                          ; iteration++
26 cmp  ebx,0F4240h                  ; if iteration < 1000000 then
2c jl   0000000A                     ; loop by iteration
2e mov  eax,edi                      ; eax = sum (Result)
30 pop  ebx 
31 pop  esi 
32 pop  edi 
33 pop  ebp 
34 ret 
35 call 639E52D5                     ; IndexOutOfRangeException
3a int  3 
```

Из этого кода становится понятно, что разнице во времени взяться неоткуда: методы отличаются только в одной строчке, в которой берётся адрес интересующего нас массива. В обоих случаях используется команда `move` , просто её аргументы разнятся, это не должно сказаться на производительности.

Теперь поменяем платформу на x64 и запустим бенчмарк:

```
Non-static : 347ms
Static     : 533ms
```

Любопытно: в обоих случаях быстродействие значительно возросло, но только в случае статичного поля оптимизация вышла «слабее». В чём же дело? Обратимся опять к машинному коду:

**NonStaticRun-x64.asm**

```
00 sub  rsp,28h
04 mov  r8,rcx
07 xor  ecx,ecx
09 mov  edx,ecx                      ; sum = 0
0b nop  dword ptr [rax+rax]
10 xor  r10d,r10d                    ; i = 0
13 mov  r9,qword ptr [r8+8]          ; r9 = &nonStaticField
17 mov  rax,qword ptr [r9+8]         ; rax = nonStaticField.Length
1b mov  r11d,3E4h                    ; r11 = 996
21 cmp  r11,rax                      ; if r11 >= nonStaticField.Length then
24 jae  000000000000008A             ; throw IndexOutOfRangeException
26 mov  r11d,3E5h                    ; r11 = 997
2c cmp  r11,rax                      ; if r11 >= nonStaticField.Length then
2f jae  000000000000008A             ; throw IndexOutOfRangeException
31 mov  r11d,3E6h                    ; r11 = 998
37 cmp  r11,rax                      ; if r11 >= nonStaticField.Length then
3a jae  000000000000008A             ; throw IndexOutOfRangeException
3c mov  r11d,3E7h                    ; r11 = 999
42 cmp  r11,rax                      ; if r11 >= nonStaticField.Length then
45 jae  000000000000008A             ; throw IndexOutOfRangeException
47 nop  word ptr [rax+rax+00000000h]
50 mov  eax,dword ptr [r9+r10+10h]   ; eax = nonStaticField[i]
55 add  edx,eax                      ; sum += eax
57 mov  eax,dword ptr [r9+r10+14h]   ; eax = nonStaticField[i+1]
5c add  edx,eax                      ; sum += eax
5e mov  eax,dword ptr [r9+r10+18h]   ; eax = nonStaticField[i+2]
63 add  edx,eax                      ; sum += eax
65 mov  eax,dword ptr [r9+r10+1Ch]   ; eax = nonStaticField[i+3]
6a add  edx,eax                      ; sum += eax
6c add  r10,10h                      ; i += 4
70 cmp  r10,0FA0h                    ; if i < 1000 then
77 jl   0000000000000050             ; loop by i
79 inc  ecx                          ; iteration++
7b cmp  ecx,0F4240h                  ; if iteration < 1000000  then
81 jl   0000000000000010             ; loop by iteration
83 mov  eax,edx                      ; eax = sum (Result)
85 add  rsp,28h
89 ret   
8a call 000000005FA4AE14             ; IndexOutOfRangeException
8f nop 
```

Этот пример намного интересней! Вспомним, что в x86 нам доступно только 8 регистров по 32 бита (EAX, ECX, EDX, EBX, ESP, EBP, ESI, EDI, R8D), а в x64 доступно 16 регистров по 64 бита (RAX, RCX, RDX, RBX, RSP, RBP, RSI, RDI, R8 — R15). Увеличение количества регистров позволило произвести JIT-оптимизацию «размотка цикла» (см.
[Loop unwinding](http://en.wikipedia.org/wiki/Loop_unwinding)). При этом важную роль играет то обстоятельство, что количество итераций в каждом из циклов кратно четвёрке. Мы ещё вернёмся к этому моменту, а пока взглянем на static-версию.

**StaticRun-x64.asm**

```
00 sub  rsp,28h 
04 xor  ecx,ecx                       ; iteration = 0
06 mov  edx,ecx                       ; sum = 0
08 nop  dword ptr [rax+rax+00000000h] 
10 xor  r8d,r8d                       ; i = 0
13 mov  r9,12D756F0h                  ; r9 = staticField
1d mov  r9,qword ptr [r9]             ; r9 = &staticField
20 mov  r10,qword ptr [r9+8]          ; r10 = staticField.Length
24 cmp  r8,r10                        ; if r8 >= staticField.Length then
27 jae  0000000000000080              ; throw IndexOutOfRangeException
29 mov  eax,dword ptr [r9+r8*4+10h]   ; eax = staticField[i]
2e add  edx,eax                       ; sum += eax
30 lea  rax,[r8+1]                    ; rax = i+1
34 cmp  rax,r10                       ; if rax >= staticField.Length then
37 jae  0000000000000080              ; throw IndexOutOfRangeException
39 mov  eax,dword ptr [r9+rax*4+10h]  ; eax = staticField[i+1]
3e add  edx,eax                       ; sum += eax
40 lea  rax,[r8+2]                    ; rax = i+2
44 cmp  rax,r10                       ; if rax >= staticField.Length then
47 jae  0000000000000080              ; throw IndexOutOfRangeException
49 mov  eax,dword ptr [r9+rax*4+10h]  ; eax = staticField[i+2]
4e add  edx,eax                       ; sum += eax
50 lea  rax,[r8+3]                    ; rax = i+3
54 cmp  rax,r10                       ; if rax >= staticField.Length then
57 jae  0000000000000080              ; throw IndexOutOfRangeException
59 mov  eax,dword ptr [r9+rax*4+10h]  ; eax = staticField[i+3]
5e add  edx,eax                       ; sum += eax
60 add  r8,4                          ; i += 4
64 cmp  r8,3E8h                       ; if i < 1000 then
6b jl   0000000000000013              ; loop by i
6d inc  ecx                           ; iteration++
6f cmp  ecx,0F4240h                   ; if iteration < 1000000 then
75 jl   0000000000000010              ; loop by iteration
77 mov  eax,edx                       ; eax = sum (result)
79 add  rsp,28h 
7d ret     
7e xchg ax,ax 
80 call 000000005FA49F64              ; IndexOutOfRangeException
85 nop   
```

Из примера видно, что для статичного массива оптимизация размотки цикла прошла несколько иначе. Причём, если в методе `StaticRun` сохранить ссылку на статический массив в локальную переменную и итерировать по ней, то машинный код будет аналогичен примеру NonStaticRun-x64.asm, а производительность обоих методов станет одинаковой. В текущей версии static-версия «проседает» по скорости из-за следующих обстоятельств:


* Вместо того, чтобы явно хранить смещения элементов, хранится индекс, который в момент вычисления адреса умножается на 4 для получения смещения.
* Вычисление адресов элементов [i+1], [i+2], [i+3] происходит в регистрах вместо того, чтобы использовать константные смещения в 4h, 8h, bh, относительно элемента [i].

Теперь попробуем изменить длину массива, чтобы она больше не делилась на 4: N = 1001. Результаты бенчмарка:

```
Non-static : 550ms
Static     : 719ms
```

Static-версия по скорости «вернулась» к результату без оптимизации, который мы видели в x86-версии. В NonStatic-версии результат интереснее: текущая версия работает медленнее, чем для N=1000, но быстрее, чем для x86. Опять обратимся к машинному коду, чтобы разобраться:


**NonStaticRun-x64-1001.asm**

```
00 sub  rsp,28h 
04 mov  r9,rcx 
07 xor  ecx,ecx 
09 mov  edx,ecx 
0b nop  dword ptr [rax+rax] 
10 xor  r8d,r8d 
13 mov  r10,qword ptr [r9+8] 
17 mov  rax,qword ptr [r10+8] 
1b mov  r11d,3E8h 
21 cmp  r11,rax 
24 jae  0000000000000055 
26 nop  word ptr [rax+rax+00000000h] 
30 mov  eax,dword ptr [r10+r8+10h] 
35 add  edx,eax 
37 add  r8,4 
3b cmp  r8,0FA4h 
42 jl   0000000000000030 
44 inc  ecx 
46 cmp  ecx,0F4240h 
4c jl   0000000000000010 
4e mov  eax,edx 
50 add  rsp,28h 
54 ret    
55 call 000000005FA5AE14 
5a nop    
```

**StaticRun-x64-1001.asm**

```
00 sub  rsp,28h 
04 xor  ecx,ecx 
06 mov  edx,ecx 
08 nop  dword ptr [rax+rax+00000000h] 
10 xor  r8d,r8d 
13 mov  r9,12B556F0h 
1d mov  r9,qword ptr [r9] 
20 mov  rax,qword ptr [r9+8] 
24 cmp  r8,rax 
27 jae  0000000000000050 
29 mov  eax,dword ptr [r9+r8*4+10h] 
2e add  edx,eax 
30 inc  r8 
33 cmp  r8,3E9h 
3a jl   0000000000000013 
3c inc  ecx 
3e cmp  ecx,0F4240h 
44 jl   0000000000000010 
46 mov  eax,edx 
48 add  rsp,28h 
4c ret   
4d nop  dword ptr [rax] 
50 call 000000005FA69FA4 
55 nop
```

Из примеров можно заметить, что в методах NonStaticRun-x86, StaticRun-x86, StaticRun-x64-1001 для вычисления очередного элемента массива используется формула:
`BaseAddress + i * 4 + 10h`, а в методе NonStaticRun: `BaseAddress + offset + 10h`, где `offset = i * 4` — уже готовое смещение. Этим и объясняется разница в скорости.

Данную тему можно изучать ещё очень долго: пробовать менять конфигурацию сборки, пробовать различные длины массивов и т.п. Но я ограничусь формулировкой основного вывода.

### Выводы

Скорость итерирования может значительно зависеть от следующих обстоятельств:

* Тип ссылки на массив: статичное поле или обычное поле/локальная переменная
* Используемая архитектура процессора
* Делимость количества элементов на степени двойки
* Версия CLR
* Фаза луны

Всем хороших бенчмарков =)