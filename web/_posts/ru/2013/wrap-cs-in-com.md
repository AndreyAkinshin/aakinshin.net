---
layout: ru-post
title: "Заворачиваем C#-класс в COM"
date: "2013-06-03"
lang: ru
type: post
tags:
- ".NET"
- C#
- COM
redirect_from:
- /ru/blog/dotnet/wrap-cs-in-com/
- /ru/blog/post/wrap-cs-in-com/
---


Пусть у нас имеется C#-класс, который делает что-нибудь полезное, например:

```cs
public class Calculator
{
    public int Sum(int a, int b)
    {
        return a + b;
    }
}
```

Давайте создадим для этого класса [COM](http://ru.wikipedia.org/wiki/Component_Object_Model)-интерфейс, чтобы его функциональность можно было использовать в других местах. В конце посмотрим на использование этого класса в среде Delphi.<!--more-->

Для начала нужно пойти в свойства проекта и на вкладке *Build* поставить галочку напротив *Register for COM interop*:

<p class="center">
  <img src="/img/posts/dotnet/wrap-cs-in-com/screen1.png" />
</p>

Далее создаём интерфейс для нашего класса:

```cs
public interface ICalculator
{
    int Sum(int a, int b);
}

public class Calculator : ICalculator
{
    public int Sum(int a, int b)
    {
        return a + b;
    }
}
```

Класс и интерфейс нужно пометить рядом атрибутов: следует указать для них уникальные [GUID](http://ru.wikipedia.org/wiki/GUID)-ы, указать `ComVisible(true)`
, а для класса также добавить атрибут `ClassInterface(ClassInterfaceType.None)`:

```cs
[Guid("364C5E66-4412-48E3-8BD8-7B2BF09E8922")]
[ComVisible(true)]
public interface ICalculator
{
    int Sum(int a, int b);
}

[Guid("8C034F6A-1D3F-4DB8-BC99-B73873D8C297")]
[ClassInterface(ClassInterfaceType.None)]
[ComVisible(true)]
public class Calculator : ICalculator
{
    public int Sum(int a, int b)
    {
        return a + b;
    }
}
```

Уже почти всё готово! Можно собирать готовый вариант нашей сборки. Благодаря галочке *Register for COM interop* COM-компнент сам зарегистрируется в системе, но регистрацию можно провести и руками. Делается это с помощью утилиты [RegAsm](http://msdn.microsoft.com/ru-ru/library/tzat5yw6.aspx), которую можно найти в "C:\Windows\Microsoft.NET\Framework\v<номер нужной версии>\". С помощью аргумента `/tlb` можно попутно создать сопутствующий tlb-файл. Отменить регистрацию сборки
[поможет](http://stackoverflow.com/questions/7841428/how-to-unregister-the-assembly-registered-using-regasm) атрибут `/u`. Итак, выполним команду (будем считать, что название проекта и соответствующей dll — ComCalculator):

```
RegAsm.exe Calculator.dll /tlb
```

Отлично, теперь наш компонент зарегистрирован! Давайте откроем Delphi и попробуем его использовать. После создания нового проекта (пусть это будет обычный WinForms-проект) нужно импортировать в него ComCalculator. Выбираем из меню *Project* пункт *Import Type Library* . В списке находим *ComCalculator* и жмём *Install*:

<p class="center">
  <img src="/img/posts/dotnet/wrap-cs-in-com/screen2.png" />
</p>

В файле `Unit1.pas` необходимо добавить `ComCalculator_TLB` в раздел `uses`. После этого у вас <a href="http://stackoverflow.com/questions/7196769/what-is-this-error-mscorlib-tlb-pas">могут быть проблемы</a> с компиляцией `mscorlib_TBL.pas`. Если это так, то просто удалите ссылку на него из раздела `uses` файла `ComCalculator_TLB.pas`.

Теперь попробуем использовать наш COM-компонент. Будем это делать прямо в конструкторе формы. Тело конструктора будет содержать две незамысловатые строчки: в первой мы создадим экземпляр класса `TCalculator` , а во второй вызовем метод `Sum` , результат вычислений покажем с помощью процедуры `ShowMessage`.

``` delphi
procedure TForm1.FormCreate(Sender: TObject);
var
  calculator : TCalculator;
begin
  calculator := TCalculator.Create(Self);
  ShowMessage(IntToStr(calculator.Sum(1, 2)));
end;
```

Запустив приложение, вы сможете увидеть появившееся окошечко с цифрой 3 и порадоваться. 

### Ссылки

Для более сложных вариантов создания COM-объектов рекомендуются к изучению следующие статьи:

* [Пример COM-класса / msdn](http://msdn.microsoft.com/ru-ru/library/c3fd4a20.aspx)
* [Как создавать COM+-компоненты на .NET-е / rsdn](http://rsdn.ru/forum/info/FAQ.dotnet.complusplus)
* [Создание COM в C# NET / CyberForum](http://www.cyberforum.ru/csharp-net/thread153051.html)