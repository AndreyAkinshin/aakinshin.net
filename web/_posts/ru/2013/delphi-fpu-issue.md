---
layout: ru-post
title: "Проблема с FPU при вызове .NET-логики из Delphi"
date: "2013-08-06"
lang: ru
type: post
tags:
- Delphi
- ".NET"
- FPU
- COM
redirect_from:
- /ru/blog/dotnet/delphi-fpu-issue/
- /ru/blog/post/dotnet-fpu-issue/
---

**Ситуация:** мы пишем основную логику приложения на C#, но есть необходимость использовать её из Delphi. Для этих целей пользуемся COM-обёрткой, которая успешно справляется с поставленной задачей. Целевая функция перед возвращением результата показывает диалоговое WPF-окно, с которым можно сделать что-нибудь полезное. Проверяем на простом примере — всё отлично работает.

**Проблема:** в некоторых Delphi приложений окно выбрасывает исключение. Но исключение странное: при формировании WPF-окна падает, скажем, выставление ширины некоторого элемента. Но это только в некоторых приложениях. А в остальных — тот же самый код на тех же самых данных отлично работает.

**В чём же дело?**<!--more--> Оставив в стороне увлекательную историю о проведённом исследовании, перейду сразу к решению: виновником был бит в FPU-регистре [CW](http://www.club155.ru/x86internalreg-fpucw). Определённые функции некоторых версий Delphi любят менять его на такое значение, что бедный математический сопроцессор перестаёт переваривать `double.NaN`, начиная плеваться на него исключениями. А в WPF, как известно, у доброй половины свойств `FrameworkElement`-а значение по умолчанию выставлено именно в `NaN`. При малейших манипуляциях над этими свойствами приложение начинает падать.

**Что же делать?**
Имеется два метода решения проблемы. В первом варианте необходимо выставить правильное значение плохого бита в Delphi перед вызовом WPF-окна. Например так:

```
procedure Foo;
var 
  saved8087CW : Word; 
begin 
  saved8087CW := Default8087CW; 
  Set8087CW($133F); 
  // Вызываем нужный метод
  Set8087CW(saved8087CW); 
end; 
```

Этот способ не всегда подходит, т.к. возможно .NET-логика будет использоваться в различных Delphi-приложениях, и у нас нет возможности обернуть все вызовы WPF-окна во всех приложениях. С этих позиций разумно установить бит на стороне .NET-а. В этом нам поможет функция `_controlfp` из `msvcrt.dll`:

```
[DllImport("msvcrt.dll", CallingConvention = CallingConvention.Cdecl)]
public static extern int _controlfp(int newControl, int mask);
 
const int _RC_NEAR = 0x00000000;
const int _PC_53 = 0x00010000;
const int _EM_INVALID = 0x00000010;
const int _EM_UNDERFLOW = 0x00000002;
const int _EM_ZERODIVIDE = 0x00000008;
const int _EM_OVERFLOW = 0x00000004;
const int _EM_INEXACT = 0x00000001;
const int _EM_DENORMAL = 0x00080000;
const int _CW_DEFAULT = 
  _RC_NEAR + _PC_53 + _EM_INVALID + _EM_ZERODIVIDE +
  _EM_OVERFLOW + _EM_UNDERFLOW + _EM_INEXACT + _EM_DENORMAL;
 
public Foo()
{
  _controlfp(_CW_DEFAULT, 0xfffff);
  // Нужная нам логика 
}
```

### Ссылки

* [FPU issues when interoping Delphi and .net](http://blog.neslekkim.net/2008/10/fpu-issues-when-interoping-delphi-and.html)
* [Floating point exception in managed code results in Access Violation crash](http://blogs.msdn.com/b/dsvc/archive/2009/06/25/floating-point-exceptions-in-managed-code-resulting-in-access-violation-crash.aspx)
* [PRB: System.Arithmetic Exception Error When You Change the Floating-Point Control Register in a Managed Application](http://support.microsoft.com/kb/326219)
* [SO — How can I set and restore FPU CTRL registers?](http://stackoverflow.com/questions/191368/how-can-i-set-and-restore-fpu-ctrl-registers)
* [Floating Point Exception When Calling Borland C++Builder or Delphi DLL or Executable](http://digital.ni.com/public.nsf/allkb/E6A73825E57FCD9F862570DD005E594F)
* [Delphi: Set8087CW](http://valera.asf.ru/delphi/help/name.php?name=Set8087CW)
* [Внутренние регистры: Регистр управления FPU](http://www.club155.ru/x86internalreg-fpucw)