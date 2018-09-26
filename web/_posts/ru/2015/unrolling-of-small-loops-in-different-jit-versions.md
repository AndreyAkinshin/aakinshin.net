---
layout: ru-post
title: "Размотка маленьких циклов в разных версиях JIT"
date: "2015-03-02"
lang: ru
type: post
tags:
- ".NET"
- C#
- JIT
- Bugs
- LoopUnrolling
redirect_from:
- /ru/blog/dotnet/unrolling-of-small-loops-in-different-jit-versions/
- /ru/blog/post/unrolling-of-small-loops-in-different-jit-versions/
---

Вопрос дня: что выведет нижеприведённый код?

```cs
struct Point
{
    public int X;
    public int Y;
}
static void Print(Point p)
{
    Console.WriteLine(p.X + " " + p.Y);
}
static void Main()
{
    var p = new Point();
    for (p.X = 0; p.X < 2; p.X++)
        Print(p);
}
```

Правильный ответ: зависит. В JIT-x86 под CLR2 был баг, который портил эту замечательную программу. А проблема кроется в оптимизации, которая назвается раскрутка маленького цикла. Тема интересная, давайте обсудим её подробно.

<!--more-->

### Эксперимент 1 (Sum)

В [предыдущем посте](http://aakinshin.net/ru/blog/dotnet/ryujit-ctp5-and-loop-unrolling/) я рассказывал, как происходит раскрутка циклов. Существует частный случай этой оптимизации: если количество итераций мало, то JIT может полностью избавиться от цикла, повторив его тело указанное число раз. Давайте разберёмся в этом чуть подробней на простом примере:

```cs
int sum = 0;
for (int i = 0; i < 4; i++)
    sum += i;
Console.WriteLine(sum);
```

#### JIT-x86

Запустим программу под CLR4 + JIT-x86:

```
        int sum = 0;                           
0125291A  in          al,dx                    
0125291B  push        esi                      
0125291C  xor         esi,esi                  
            sum += i;                          
0125291E  inc         esi                      ; sum += 1
0125291F  inc         esi                      ; sum += 2 (Part 1)
01252920  inc         esi                      ; sum += 2 (Part 2)
01252921  add         esi,3                    ; sum += 3
        Console.WriteLine(sum);                
01252924  call        72EE0258                 
01252929  mov         ecx,eax                  
0125292B  mov         edx,esi                  
0125292D  mov         eax,dword ptr [ecx]      
0125292F  mov         eax,dword ptr [eax+38h]  
01252932  call        dword ptr [eax+14h]      
01252935  pop         esi                      
01252936  pop         ebp                      
01252937  ret                                  
```

Как мы видим, условных переходов в этой программе нет, цикл был полностью уничтожен. Вместо него появились команды, которые высчитывают значение переменно `sum` в регистре `esi`.

#### JIT-x64

Следующий эксперимент: CLR4 + JIT-x64:

```
        int sum = 0;                            
00007FFCC86F3EC0  sub         rsp,28h           
        Console.WriteLine(sum);                 
00007FFCC86F3EC4  mov         ecx,6             ; sum = 6
00007FFCC86F3EC9  call        00007FFD273DCF10  
00007FFCC86F3ECE  nop                           
00007FFCC86F3ECF  add         rsp,28h           
00007FFCC86F3ED3  ret                           
```

JIT-x64 нас приятно радует: он догадался, что `0+1+2+3=6`. В результате на консоль выводится `6` без каких-либо арифметических операций для её расчёта.

#### RyuJIT CTP5

А теперь запускаем CLR4 + RyuJIT CTP5:

```
        int sum = 0;
00007FFCC8713A02  sub         esp,20h  
00007FFCC8713A05  xor         esi,esi  
        for (int i = 0; i < 4; i++)
00007FFCC8713A07  xor         eax,eax  
            sum += i;
00007FFCC8713A09  add         esi,eax  
        for (int i = 0; i < 4; i++)
00007FFCC8713A0B  inc         eax  
00007FFCC8713A0D  cmp         eax,4  
00007FFCC8713A10  jl          00007FFCC8713A09  
        Console.WriteLine(sum);
00007FFCC8713A12  call        00007FFD26C0AFA0  
00007FFCC8713A17  mov         rcx,rax  
00007FFCC8713A1A  mov         edx,esi  
00007FFCC8713A1C  mov         rax,qword ptr [rax]  
00007FFCC8713A1F  mov         rax,qword ptr [rax+60h]  
00007FFCC8713A23  call        qword ptr [rax+28h]  
00007FFCC8713A26  nop  
00007FFCC8713A27  add         rsp,20h  
00007FFCC8713A2B  pop         rsi  
00007FFCC8713A2C  ret  
```

Эй, RyuJIT, ну что же ты? Вроде бы такая простая оптимизация, а ты её не сделал! Ну, будем надеяться, что в релизе ты научишься такие вещи делать.

### Эксперимент 2 (Point)

А теперь вернёмся к коду из начала статьи:

```cs
struct Point
{
    public int X;
    public int Y;
}

static void Print(Point p)
{
    Console.WriteLine(p.X + " " + p.Y);
}

static void Main()
{
    var p = new Point();
    for (p.X = 0; p.X < 2; p.X++)
        Print(p);
}
```

Логика подсказывает нам, что на консоль будет выведено:

```
0 0
1 0
```

Давайте проверим!

#### CLR2 + JIT-x86

Начнём с конфигурации, в которой возникает бага: CLR2 + JIT-x86. В этом случае на консоль будет выведено:

```
2 0
2 0
```

Взглянем на ассемблерный код, чтобы разобраться в ситуации:

```
        var p = new Point();                  
05C5178C  push        esi                     
05C5178D  xor         esi,esi                 ; p.Y = 0
        for (p.X = 0; p.X < 2; p.X++)         
05C5178F  lea         edi,[esi+2]             ; p.X = 2
            Print(p);                         
05C51792  push        esi                     ; push p.Y
05C51793  push        edi                     ; push p.X
05C51794  call        dword ptr ds:[54607F4h] ; Print(p)
05C5179A  push        esi                     ; push p.Y
05C5179B  push        edi                     ; push p.X
05C5179C  call        dword ptr ds:[54607F4h] ; Print(p)
05C517A2  pop         esi                     
05C517A3  pop         edi                     
05C517A4  pop         ebp                     
05C517A5  ret                                 
```

Мы видим, что размотка цикла была произведена, но в оптимизацию вкралась ошибка: переменная `x` сразу принимает значение `2` и больше не меняется. Данная бага известна давно, она обсуждалась на StackOverflow в вопросе [.NET JIT potential error?](http://stackoverflow.com/q/2056948/184842). Там приведён более сложный пример кода, но в рамках данного поста я его упростил, чтобы было проще разобраться в проблеме.

Для полноты эксперимента взглянем на работу остальных версий JIT.

#### CLR4 + JIT-x86

Для версии CLR4 имеем следующий листинг:

```
        var p = new Point();                   
01392620  push        ebp                      
01392621  mov         ebp,esp                  
01392623  push        edi                      
01392624  push        esi                      
01392625  xor         edi,edi                  ; p.Y = 0
        for (p.X = 0; p.X < 2; p.X++)          
01392627  xor         esi,esi                  ; p.X = 0
            Print(p);                          
01392629  push        edi                      ; push p.Y
0139262A  push        esi                      ; push p.X
0139262B  call        dword ptr ds:[2DB2108h]  ; Print(p)
        for (p.X = 0; p.X < 2; p.X++)          
01392631  inc         esi                      ; p.X++
01392632  cmp         esi,2                    
01392635  jl          01392629                 
01392637  pop         esi                      
01392638  pop         edi                      
01392639  pop         ebp                      
0139263A  ret                                  
```

Microsoft пофиксили багу в CLR4. Увы, сделали они это за счёт выключения размотки. Код теперь работает правильно, хоть и не так быстро.

#### CLR2 + JIT-x64

```
        var p = new Point();
00007FFCB94A3502  in          al,dx  
00007FFCB94A3503  cmp         byte ptr [rbx],dh  
00007FFCB94A3505  ror         byte ptr [rax-77h],44h  
00007FFCB94A3509  and         al,20h  
00007FFCB94A350B  xor         eax,eax  
00007FFCB94A350D  mov         qword ptr [rsp+20h],rax  
        for (p.X = 0; p.X < 2; p.X++)
00007FFCB94A3512  mov         dword ptr [rsp+20h],0  
00007FFCB94A351A  mov         eax,dword ptr [rsp+20h]  
00007FFCB94A351E  cmp         eax,2  
00007FFCB94A3521  jge         00007FFCB94A3544  
            Print(p);
00007FFCB94A3523  mov         rcx,qword ptr [rsp+20h]  
00007FFCB94A3528  call        00007FFCB936C868  
        for (p.X = 0; p.X < 2; p.X++)
00007FFCB94A352D  mov         r11d,dword ptr [rsp+20h]  
00007FFCB94A3532  add         r11d,1  
00007FFCB94A3536  mov         dword ptr [rsp+20h],r11d  
00007FFCB94A353B  mov         eax,dword ptr [rsp+20h]  
00007FFCB94A353F  cmp         eax,2  
00007FFCB94A3542  jl          00007FFCB94A3523  
00007FFCB94A3544  add         rsp,38h  
00007FFCB94A3548  rep ret  
```

Хоть этот код работает и правильно, но он очень плох: мало того, что размотка цикла не выполнилась, так ещё и добавилось много лишних операций по перекидыванию значений из регистра в стек и обратно. Ай-яй-яй! Посмотрим, что изменилось в CLR4.

#### CLR4 + JIT-x64

```
        var p = new Point();                           
00007FFCC8703EC2  sub         esp,30h                  
00007FFCC8703EC5  mov         qword ptr [rsp+20h],0    
        for (p.X = 0; p.X < 2; p.X++)                  
00007FFCC8703ECE  xor         ebx,ebx                  
00007FFCC8703ED0  mov         dword ptr [rsp+20h],ebx  
00007FFCC8703ED4  cmp         ebx,2                    
00007FFCC8703ED7  jge         00007FFCC8703EF5         
00007FFCC8703ED9  nop         dword ptr [rax]          
            Print(p);                                  
00007FFCC8703EE0  mov         rcx,qword ptr [rsp+20h]  
00007FFCC8703EE5  call        00007FFCC85EC8E0         
        for (p.X = 0; p.X < 2; p.X++)                  
00007FFCC8703EEA  inc         ebx                      
00007FFCC8703EEC  mov         dword ptr [rsp+20h],ebx  
00007FFCC8703EF0  cmp         ebx,2                    
00007FFCC8703EF3  jl          00007FFCC8703EE0         
00007FFCC8703EF5  add         rsp,30h                  
00007FFCC8703EF9  pop         rbx                      
00007FFCC8703EFA  ret                                  
```

Размотки цикла по-прежнему нет, но зато код стал заметно лучше по сравнению с CLR2 + JIT-x64. Обратите внимание, что по сравнению с JIT-x86 мы пересылаем структуру `Point` в метод `Print` через один 64-битный регистр вместо двух 32-битных значений на стеке.

#### CLR4 + RyuJIT CTP5

Теперь попробуем запустить RyuJIT CTP5:

```
        var p = new Point();
00007FFCC8723A02  sub         rsp,28h  
00007FFCC8723A06  xor         esi,esi  
        for (p.X = 0; p.X < 2; p.X++)
00007FFCC8723A08  xor         edi,edi  
            Print(p);
00007FFCC8723A0A  lea         rcx,[rsp+20h]  
00007FFCC8723A0F  mov         dword ptr [rcx],edi  
00007FFCC8723A11  mov         dword ptr [rcx+4],esi  
00007FFCC8723A14  mov         rcx,qword ptr [rsp+20h]  
00007FFCC8723A19  call        00007FFCC860C8E0  
        for (p.X = 0; p.X < 2; p.X++)
00007FFCC8723A1E  inc         edi  
00007FFCC8723A20  cmp         edi,2  
00007FFCC8723A23  jl          00007FFCC8723A0A  
00007FFCC8723A25  add         rsp,28h  
00007FFCC8723A29  pop         rsi  
00007FFCC8723A2A  pop         rdi  
00007FFCC8723A2B  ret  
```

Размотки цикла нет, то зато код выглядит немного чище по сравнению с CLR4 + JIT-x64.

### Выводы

Проиллюстрируем результаты экспериментов в виде таблицы:

<table>
  <tr> <th>Эксперимент</th> <th>CLR</th> <th>JIT</th>    <th>Результаты</th> </tr>
  <tr> <td>Sum</td>         <td>4</td>   <td>x86</td>    <td>Размотка цикла</td> </tr>
  <tr> <td>Sum</td>         <td>4</td>   <td>x64</td>    <td>Предподсчёт значения</td> </tr>
  <tr> <td>Sum</td>         <td>4</td>   <td>RuyJIT</td> <td>Размотки цикла нет</td> </tr>
  <tr> <td>Point</td>       <td>2</td>   <td>x86</td>    <td>Размотка цикла с багом</td> </tr>
  <tr> <td>Point</td>       <td>4</td>   <td>x86</td>    <td>Размотки цикла нет</td> </tr>
  <tr> <td>Point</td>       <td>2</td>   <td>x64</td>    <td>Размотки цикла нет, плохой код</td> </tr>
  <tr> <td>Point</td>       <td>4</td>   <td>x64</td>    <td>Размотки цикла нет, код среднего качество</td> </tr>
  <tr> <td>Point</td>       <td>4</td>   <td>RyuJIT</td> <td>Размотки цикла нет, код хорошего качества</td> </tr>
</table>

### Ссылки

* [RyuJIT CTP5 и размотка циклов](http://aakinshin.net/ru/blog/dotnet/ryujit-ctp5-and-loop-unrolling/)
* [StackOverflow: .NET JIT potential error?](http://stackoverflow.com/q/2056948/184842)