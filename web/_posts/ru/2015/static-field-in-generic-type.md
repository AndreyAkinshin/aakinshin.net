---
layout: ru-post
title: "Статические поля в generic-классах"
date: "2015-01-21"
lang: ru
type: post
tags:
- ".NET"
- C#
- Generic
- Static
redirect_from:
- /ru/blog/dotnet/static-field-in-generic-type/
- /ru/blog/post/static-field-in-generic-type/
---

Сегодня мы кратко поговорим о статических полях в generic-классах. Тема простая, но у некоторых разработчиков она вызывает трудности. Итак, задачка: что выведет следующий код?

```cs
class Foo<T>
{
  public static int Bar;
}
void Main()
{
  Foo<int>.Bar++;
  Console.WriteLine(Foo<double>.Bar);
}
```
<!--more-->

*Правильный ответ:* `0`. Всё дело в том, что `Foo<int>` и `Foo<double>` — это два разных класса, у каждого своё собственное статическое поле. И это весьма логично. Действительно, раз у нас есть поле, то оно должно принадлежать экземпляру какого-то класса, а экземпляр `Foo<T>` создать невозможно, необходимо явно указать `T`. Как можно догадаться, `typeof(Foo<int>) != typeof(Foo<double>)`, поэтому каждый класс получит собственное статическое поле. Если поменять значение этого поля в одном классе, то это никак не повлияет на значение соответствующего поля в другом классе. Вроде бы просто, но не всем очевидно: мне доводилось видеть, как данный нюанс вызывал проблемы в продакшн-проектах. Поэтому я и решил написать небольшую заметку по этому поводу.

Приведу также цитату из документации языка C#. **CSharp Language Specification 5.0, 10.5.1:**

> When a field declaration includes a  static modifier, the fields introduced by the declaration are static fields. When no  static modifier is present, the fields introduced by the declaration are instance fields. Static fields and instance fields are two of the several kinds of variables (§5) supported by C#, and at times they are referred to as static variables and instance variables, respectively. A static field is not part of a specific instance; instead, it is shared amongst all instances of a closed type (§4.4.2). No matter how many instances of a closed class type are created, there is only ever one copy of a static field for the associated application domain.

У MS в разделе **Code Analysis for Managed Code Warnings** есть такое предупреждение: [CA1000](https://msdn.microsoft.com/en-us/library/ms182139.aspx): Do not declare static members on generic types (DoNotDeclareStaticMembersOnGenericTypes). Ну и, само собой, в ReSharper также есть подобный warning под названием StaticMemberInGenericType (см. [ReSharper wiki](https://confluence.jetbrains.com/display/ReSharper/Static+field+in+generic+type)).

**Мораль:** старайтесь не делать изменяемые статические поля в generic-классах. А ещё лучше — просто старайтесь не делать изменяемые статические поля. Как правило, в нормальном проекте такую потребность всегда можно обойти с помощью красивого архитектурного решения. Даже если вы считаете, что изменяемое статическое поле вам просто необходимо, и при этом прекрасно понимаете нюансы, связанные с его использованием в generic-классах (используете эту фичу в своих целях), то помните, что кто-нибудь, кто будет работать с вашим кодом, может не понять авторскую задумку и чего-нибудь испортить или использовать не по плану. А архитектуру нужно стараться делать так, чтобы что-то испортить было чертовски сложно.

### Задачи

Приведённая задачка доступна в [ProblemBookt.NET](http://problembook.net/) [на русском](http://problembook.net/content/ru/Oop/StaticFieldInGenericType-P.html) и [на английском](http://problembook.net/content/en/Oop/StaticFieldInGenericType-P.html).