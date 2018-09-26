---
layout: ru-post
title: "RyuJIT CTP5 и размотка циклов"
date: "2015-03-01"
lang: ru
type: post
tags:
- ".NET"
- C#
- JIT
- RyuJIT
- LoopUnrolling
redirect_from:
- /ru/blog/dotnet/ryujit-ctp5-and-loop-unrolling/
- /ru/blog/post/ryujit-ctp5-and-loop-unrolling/
---

Уже скоро нам будет доступен RyuJIT, JIT-компилятор следующего поколения для .NET-приложений. Microsoft любит рассказывать нам о преимуществах использования SIMD и сокращением времени JIT-компиляции. Но что можно сказать о базовых оптимизациях кода, за которые обычно отвечает компилятор? Сегодня мы поговорим о такой оптимизации как размотка (раскрутка) цикла. Если кратко, то это оптимизации кода вида

```cs
for (int i = 0; i < 1024; i++)
    Foo(i);
```

превращается в

```cs
for (int i = 0; i < 1024; i += 4)
{
    Foo(i);
    Foo(i + 1);
    Foo(i + 2);
    Foo(i + 3);
}
```

Подобный подход может заметно увеличить производительность вашего кода. Итак, как же обстоят дела с раскруткой цикла в .NET?

<!--more-->

### Общая теория

Сперва поговорим о том, как размотка циклов влияет на наше приложение.

#### Достоинства

* Мы немного экономим на сокращении количества инкрементов переменной цикла.
* Сокращаются накладные расходы на [предсказывание переходов (branch prediction)](https://ru.wikipedia.org/wiki/%D0%9F%D1%80%D0%B5%D0%B4%D1%81%D0%BA%D0%B0%D0%B7%D0%B0%D1%82%D0%B5%D0%BB%D1%8C_%D0%BF%D0%B5%D1%80%D0%B5%D1%85%D0%BE%D0%B4%D0%BE%D0%B2).
* Повышаются возможности применения [параллелизма уровня команд (instruction-level parallelism)](https://ru.wikipedia.org/wiki/%D0%9F%D0%B0%D1%80%D0%B0%D0%BB%D0%BB%D0%B5%D0%BB%D0%B8%D0%B7%D0%BC_%D0%BD%D0%B0_%D1%83%D1%80%D0%BE%D0%B2%D0%BD%D0%B5_%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4).
* Позволяет выполнить дополнительные улучшения кода в связке с другими оптимизациями (например, [инлайнинг](http://en.wikipedia.org/wiki/Inline_expansion)).

#### Недостатки

* Увеличивается размер исходного кода, что негативно сказывается на размере программы.
* Из-за растущего размера количества инструкций иногда невозможно одновременно применить размотку цикла и инлайнинг.
* Возможные [промахи](http://en.wikipedia.org/wiki/CPU_cache#Cache_miss) в кеше команд.
* Возрастает нагрузка на регистры в рамках итерации (нам может не хватить регистров, другие оптимизации могут не примениться из-за их нехватки).
* Если внутри итерации есть ветвление, то размотка может отрицательно повлиять на другие оптимизации.

#### Выводы

Размотка циклов — очень мощный инструмент для оптимизации, но только если применять её с умом. Не рекомендуется делать размотку самостоятельно: это понизит читаемость кода и может затруднить применение других оптимизаций. Лучше всего оставить этот подход компилятору. Очень важно, чтобы ваш компилятор умел делать размотку циклов грамотно.

### Эксперименты

#### Исходный код

Мы будем работать с очень простым циклом, который просто грех не размотать:

```cs
int sum = 0;
for (int i = 0; i < 1024; i++)
    sum += i;
Console.WriteLine(sum);
```

Обратите внимание, что количество итераций известно заранее и равно 2<sup>10</sup>. Это очень важно, т. к. существенно упрощает применение рассматриваемой оптимизации.

#### JIT-x86

Запустим данный код под x86 и взглянем на ассемблерный код:

```
        int sum = 0;                    
00EE0052  in          al,dx             
00EE0053  push        esi               
00EE0054  xor         esi,esi           
        for (int i = 0; i < 1024; i++)  
00EE0056  xor         eax,eax           
            sum += i;                   
00EE0058  add         esi,eax           ; sum += i
        for (int i = 0; i < 1024; i++)  
00EE005A  inc         eax               ; i++
00EE005B  cmp         eax,400h          
00EE0060  jl          00EE0058          
```

Как видно, JIT-x86 размотку не выполнил. Нужно понимать, что 32-битная версия JIT-компилятора достаточно примитивна, от неё не часто можно увидеть хорошие оптимизации. Размотка цикла в JIT-x86 выполняется крайне редко, если выполняются специфические условия.

#### JIT-x64

Теперь перейдём к 64-битной версии JIT-компилятора:

```
        int sum = 0;                               
00007FFCC8710090  sub         rsp,28h              
        for (int i = 0; i < 1024; i++)             
00007FFCC8710094  xor         ecx,ecx              
00007FFCC8710096  mov         edx,1                ; edx = i + 1
00007FFCC871009B  nop         dword ptr [rax+rax]  
00007FFCC87100A0  lea         eax,[rdx-1]          ; eax = i
            sum += i;                              
00007FFCC87100A3  add         ecx,eax              ; sum += i
00007FFCC87100A5  add         ecx,edx              ; sum += i + 1
00007FFCC87100A7  lea         eax,[rdx+1]          ; eax = i + 2
00007FFCC87100AA  add         ecx,eax              ; sum += i + 2;
00007FFCC87100AC  lea         eax,[rdx+2]          ; eax = i + 3
00007FFCC87100AF  add         ecx,eax              ; sum += i + 3;
00007FFCC87100B1  add         edx,4                ; i += 4
        for (int i = 0; i < 1024; i++)             
00007FFCC87100B4  cmp         edx,401h             
00007FFCC87100BA  jl          00007FFCC87100A0     
```

Вы можете видеть, что размотка циклов была выполнена: тело цикла было повторено 4 раза. JIT-x64 умеет повторять тело цикла 2, 3 или 4 раза (в зависимости от количества итераций). Увы, если среди делителей количества итераций чисел 2, 3, 4 нет, то размотка произведена не будет.

#### RyuJIT

Что же произойдёт в новом RyuJIT? Взглянем на ассемблерный код:

```
        int sum = 0;                            
00007FFCC86E0091  sub         rsp,20h           
00007FFCC86E0095  xor         esi,esi           
        for (int i = 0; i < 1024; i++)          
00007FFCC86E0097  xor         eax,eax           
            sum += i;                           
00007FFCC86E0099  add         esi,eax           ; sum += i
        for (int i = 0; i < 1024; i++)          
00007FFCC86E009B  inc         eax               ; i++
00007FFCC86E009D  cmp         eax,400h          
00007FFCC86E00A2  jl          00007FFCC86E0099  
```

Печальная картина: RyuJIT не может размотать даже простейший цикл. Объяснение следующее: RyuJIT базируется на той же кодовой базе, что и JIT-x86 (см. [RyuJIT: The next-generation JIT compiler for .NET](http://blogs.msdn.com/b/dotnet/archive/2013/09/30/ryujit-the-next-generation-jit-compiler.aspx)).

### Выводы

RyuJIT позволяет нам использовать SIMD-инструкции и сокращает время JIT-компиляции. Увы, производительность самого кода с переходом на новый JIT временами начинает страдать. Стоит отметить, что финальной версии RyuJIT ещё не вышло, эксперимент был проведён для CTP5. Надеемся, что ближе к релизу интеллектуальные оптимизации кода всё-таки появятся.

### Ссылки

* [Размотка маленьких циклов в разных версиях JIT](http://aakinshin.net/ru/blog/dotnet/unrolling-of-small-loops-in-different-jit-versions/)
* [Википедия: Размотка цикла](https://ru.wikipedia.org/wiki/%D0%A0%D0%B0%D0%B7%D0%BC%D0%BE%D1%82%D0%BA%D0%B0_%D1%86%D0%B8%D0%BA%D0%BB%D0%B0)
* [Wikipedia: Loop unrolling](http://en.wikipedia.org/wiki/Loop_unrolling)
* [J. C. Huang, T. Leng, Generalized Loop-Unrolling: a Method for Program Speed-Up (1998)](https://www.researchgate.net/publication/2449271_Generalized_Loop-Unrolling_a_Method_for_Program_Speed-Up)
* [Википедия: Предсказывание переходов (branch prediction)](https://ru.wikipedia.org/wiki/%D0%9F%D1%80%D0%B5%D0%B4%D1%81%D0%BA%D0%B0%D0%B7%D0%B0%D1%82%D0%B5%D0%BB%D1%8C_%D0%BF%D0%B5%D1%80%D0%B5%D1%85%D0%BE%D0%B4%D0%BE%D0%B2)
* [Википедия: Параллелизма уровня команд (instruction-level parallelism)](https://ru.wikipedia.org/wiki/%D0%9F%D0%B0%D1%80%D0%B0%D0%BB%D0%BB%D0%B5%D0%BB%D0%B8%D0%B7%D0%BC_%D0%BD%D0%B0_%D1%83%D1%80%D0%BE%D0%B2%D0%BD%D0%B5_%D0%BA%D0%BE%D0%BC%D0%B0%D0%BD%D0%B4)
* [Wikipedia: Inline expansion](http://en.wikipedia.org/wiki/Inline_expansion)
* [Wikipedia: Cache miss](http://en.wikipedia.org/wiki/CPU_cache#Cache_miss)
* [StackOverflow: http://stackoverflow.com/questions/2349211/when-if-ever-is-loop-unrolling-still-useful](http://stackoverflow.com/questions/2349211/when-if-ever-is-loop-unrolling-still-useful)
* [Blogs.Msdn: RyuJIT: The next-generation JIT compiler for .NET](http://blogs.msdn.com/b/dotnet/archive/2013/09/30/ryujit-the-next-generation-jit-compiler.aspx)