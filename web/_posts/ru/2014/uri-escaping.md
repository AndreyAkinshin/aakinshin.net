---
layout: ru-post
title: "Об экранировании URI в .NET"
date: "2014-11-13"
lang: ru
type: post
tags:
- ".NET"
- C#
- Mono
- URI
- Escaping
redirect_from:
- /ru/blog/dotnet/uri-escaping/
- /ru/blog/post/uri-escaping/
---

## Часть 1

Загадка на сегодня: что выведет код?

```cs
var uri = new Uri("http://localhost/%2F1");
Console.WriteLine(uri.OriginalString);
Console.WriteLine(uri.AbsoluteUri);
```

Правильный ответ: зависит. Давайте немножко поразбираемся.<!--more-->

### Так что же он выведет?

Результат работы зависит от версии .NET:

```cs
// .NET 4.0
http://localhost/%2F1
http://localhost//1
// .NET 4.5
http://localhost/%2F1
http://localhost/%2F1
```

### Да как же так-то?

Увы, до версии .NET 4.0 имела место [неприятная бага](https://connect.microsoft.com/VisualStudio/feedback/details/511010/erroneous-uri-parsing-for-encoded-reserved-characters-according-to-rfc-3986) с экранированием слеша (он же `%2F`). В 4.5 её решили пофиксить, чтобы поведение соответствовало [RFC 3986](http://tools.ietf.org/html/rfc3986). Сделали вроде бы правильно, но добавили дополнительной головной боли разработчикам, которые не знают про этот небольшой нюанс: теперь механизм экранирования зависит от версии Framework-а. Лучше всего использовать правильный механизм из .NET 4.5. Но что, если у нас нет .NET 4.5? Имеется путь починить поведение в .NET 4.0. Для этого необходимо добавить в *.config-файл вашего приложения магические строчки:

``` xml
<configuration>
  <uri>
    <schemeSettings>
      <add name="http" 
           genericUriParserOptions="DontUnescapePathDotsAndSlashes" />
    </schemeSettings>
  </uri>
</configuration>
```

Работает приведённый фокус-покус начиная с .NET 4.0 beta 2. Т.е., скажем, в .NET 3.5 так сделать не получится. Так что придётся крутиться и вертеться. Например, на просторах интернета [можно найти](http://stackoverflow.com/a/784937/184842) вот такой чудо-хак:

```cs
void ForceCanonicalPathAndQuery(Uri uri)
{
  string paq = uri.PathAndQuery; // need to access PathAndQuery
  FieldInfo flagsFieldInfo = typeof(Uri).GetField("m_Flags", 
    BindingFlags.Instance | BindingFlags.NonPublic);
  ulong flags = (ulong) flagsFieldInfo.GetValue(uri);
  flags &= ~((ulong) 0x30); // Flags.PathNotCanonical|Flags.QueryNotCanonical
  flagsFieldInfo.SetValue(uri, flags);
}
```

### А что будет в Mono?

В Mono [накосячили](https://bugzilla.xamarin.com/show_bug.cgi?id=16960) точно также. Починка осуществилась совсем недавно с [выходом](http://www.mono-project.com/docs/about-mono/releases/3.10.0/) Mono 3.10.0 в октябре 2014. Так что если вы сидите на последней версии, то у вас уже всё должно быть хорошо. Но как же нам теперь переключаться между старым и новым поведением? Для этих целей в классе `System.Uri` имеется свойство `IriParsing`. Заглянем в [код](https://github.com/mono/mono/blob/mono-3.10.0/mcs/class/System/System/Uri.cs):

```cs
private static bool s_IriParsing;

internal static bool IriParsing {
    get { return s_IriParsing; }
    set { s_IriParsing = value; }
}
```

Выставляется свойство следующим образом:

```cs
static Uri ()
{
#if NET_4_5
    IriParsing = true;
#endif

    var iriparsingVar = 
        Environment.GetEnvironmentVariable ("MONO_URI_IRIPARSING");
    if (iriparsingVar == "true")
        IriParsing = true;
    else if (iriparsingVar == "false")
        IriParsing = false;
}
```

Т.е. выставить его проще всего через переменную окружения `MONO_URI_IRIPARSING`.

### Заключение

Бага не особо приятная и может стоить вам многих часов душевного спокойствия, если вы на неё случайно наткнётесь. Поэтому я решил оформить такую вот небольшую заметку, чтобы побольше людей было в курсе. Помните о неоднозначности экранирования некоторых URI и пишите стабильный код.

### Ссылки

* [MS Connect 511010: Erroneous URI parsing for encoded, reserved characters, according to RFC 3986](https://connect.microsoft.com/VisualStudio/feedback/details/511010/erroneous-uri-parsing-for-encoded-reserved-characters-according-to-rfc-3986)
* [Mono Bug 16960](https://bugzilla.xamarin.com/show_bug.cgi?id=16960)
* [StackOverflow: Getting a Uri with escaped slashes on mono](http://stackoverflow.com/q/20769150/184842)
* [GETting a URL with an url-encoded slash](http://stackoverflow.com/q/781205/184842">StackOverflow)
* [Mono 3.10.0 release notes](http://www.mono-project.com/docs/about-mono/releases/3.10.0/)
* [Mike Hadlow: How to stop System.Uri un-escaping forward slash characters](http://mikehadlow.blogspot.co.uk/2011/08/how-to-stop-systemuri-un-escaping.html)
* [Arnout's Eclectica: URL-encoded slashes in System.Uri](http://grootveld.com/archives/21/url-encoded-slashes-in-systemuri)

## Часть 2

На StackOverflow мне попался интересный вопрос: [«Unit test ReSharper and NUnit give different results»](http://stackoverflow.com/q/27062562/184842). Суть заключалась в том, что ReSharper и NUnit дают разные результаты при экранировании URI. Я решил немножко углубиться в эту проблему. Разобраться с проблемой нам поможет следующая небольшая программка:

```cs
public void Run()
{
    Print("http://localhost/a%2Fb");
    Print("http://localhost/a.?b");
    Print("http://localhost/a?b=c%3Fd%3De");
}

public void Print(string uriString)
{
    var uri = new Uri(uriString);
    Console.WriteLine("Original: " + uri.OriginalString);
    Console.WriteLine("Absolute: " + uri.AbsoluteUri);
    Console.WriteLine("ToString: " + uri.ToString());
    Console.WriteLine();
}
```
<!--more-->

Я взял на рассмотрение три строки: с экранированным слешом, с точкой и с экранированными вопросом и знаком равенства. Программа запускалась под MS.NET 4.0, MS.NET 4.0 с опцией `genericUriParserOptions="DontUnescapePathDotsAndSlashes"`, MS.NET 4.5, Mono 3.2.8, Mono 3.10.0. Результаты:

```cs
// MS.NET 4.0:

Original: http://localhost/a%2Fb
Absolute: http://localhost/a/b
ToString: http://localhost/a/b

Original: http://localhost/a.?b
Absolute: http://localhost/a?b
ToString: http://localhost/a?b

Original: http://localhost/a?b=c%3Fd%3De
Absolute: http://localhost/a?b=c%3Fd%3De
ToString: http://localhost/a?b=c?d=e

// MS.NET 4.0 (DontUnescapePathDotsAndSlashes):

Original: http://localhost/a%2Fb
Absolute: http://localhost/a%2Fb
ToString: http://localhost/a/b

Original: http://localhost/a.?b
Absolute: http://localhost/a?b
ToString: http://localhost/a?b

Original: http://localhost/a?b=c%3Fd%3De
Absolute: http://localhost/a?b=c%3Fd%3De
ToString: http://localhost/a?b=c?d=e

// MS.NET 4.5:

Original: http://localhost/a%2Fb
Absolute: http://localhost/a%2Fb
ToString: http://localhost/a%2Fb

Original: http://localhost/a.?b
Absolute: http://localhost/a.?b
ToString: http://localhost/a.?b

Original: http://localhost/a?b=c%3Fd%3De
Absolute: http://localhost/a?b=c%3Fd%3De
ToString: http://localhost/a?b=c%3Fd%3De

// Mono 3.2.8

Original: http://localhost/a%2Fb
Absolute: http://localhost/a/b
ToString: http://localhost/a/b

Original: http://localhost/a.?b
Absolute: http://localhost/a.?b
ToString: http://localhost/a.?b

Original: http://localhost/a?b=c%3Fd%3De
Absolute: http://localhost/a?b=c%3Fd%3De
ToString: http://localhost/a?b=c%3Fd=e

// Mono 3.10

Original: http://localhost/a%2Fb
Absolute: http://localhost/a%2Fb
ToString: http://localhost/a%2Fb

Original: http://localhost/a.?b
Absolute: http://localhost/a.?b
ToString: http://localhost/a.?b

Original: http://localhost/a?b=c%3Fd%3De
Absolute: http://localhost/a?b=c%3Fd%3De
ToString: http://localhost/a?b=c%3Fd%3De
```

Внимательное созерцание результатов может подтолкнуть к следующим выводам:

* `uri.AbsoluteUri` совсем не обязательно совпадает с `uri.ToString()`. Например, `DontUnescapePathDotsAndSlashes` хак в MS.NET 4.0 при экранировании слеша влияет на `AbsoluteUri`, но не оказывает влияния на `ToString()`. Под Mono 3.2.8 можно увидеть проблемы с экранированным знаком равенства в `AbsoluteUri`.
* В Mono и MS.NET были разные проблемы с обработкой URI. Например, под MS.NET 4.0 строка `a.?b` превратилась в `a?b`, а под Mono 3.2.8 мы увидели всё тот же `a.?b`.
* В последних версиях (MS.NET 4.5 и Mono 3.10) всё хорошо: `AbsoluteUri` и `ToString()` на *приведённых примерах* совпадают с `OriginalString`.

Что касается изначального StackOverflow-вопроса, то ReSharper проводит тестирование правильно: он запускает тесты под нужную версию .NET. А NUnit при консольном тестировании без указания специфических параметров по каким-то причинам может подхватить логику из старых библиотек.

### Выводы

Если вы работаете с URI, в который могут попасть разные спецсимволы в экранированном или явном виде, то лучше бы вам не полагаться на стандартную реализацию по обработке исходной строчки: результат работы `AbsoluteUri` и `ToString()` могут вас неприятно удивить. Если вы уверены, что у вас повсеместно используется MS.NET 4.5+ или Mono 3.10+, то скорее всего у вас всё будет нормально, но при поддержке старых версий .NET лучше бы написать свою логику по работе с URI.