---
title: "How ListSeparator Depends on Runtime and Operating System"
date: "2020-05-20"
tags:
- .NET
- C#
- Rider
- Mono
- ".NET Core"
---

*This blog post was [originally posted](https://blog.jetbrains.com/dotnet/2020/05/20/listseparator-depends-runtime-operating-system/) on [JetBrains .NET blog](https://blog.jetbrains.com/dotnet/).*

In the two previous blog posts from this series, we discussed how socket errors and socket orders depend on the runtime and operating systems. For some, it may be obvious that some things are indeed specific to the operating system or the runtime, but often these issues come as a surprise and are only discovered when running our code on different systems.
An interesting example that may bite us at runtime is using <code>ListSeparator</code> in our code. It should give us a common separator for list elements in a string. But is it really common?
Let's start our investigation by printing <code>ListSeparator</code> for the Russian language:

```cs
Console.WriteLine(new CultureInfo("ru-ru").TextInfo.ListSeparator);
```

On Windows, you will get the same result for .NET Framework, .NET Core, and Mono: the <code>ListSeparator</code> is <code>;</code> (a semicolon). You will also get a semicolon on Mono+Unix. However, on .NET Core+Unix, you will get a <a href="https://en.wikipedia.org/wiki/Non-breaking_space">non-breaking space</a>.

<!--more-->

<h2><strong>The Mono approach</strong></h2>
On Windows, it's possible to fetch the <code>ListSeparator</code> value from the operating system’s regional settings. Unfortunately, there is no such option on Linux and macOS. So, how is this problem solved in Mono?
The missing information about cultures is collected in advance using the <a href="https://github.com/mono/mono/tree/mono-6.10.0.104/tools/locale-builder">locale-builder</a> tool. Some of this data is filled in using <a href="http://www.unicode.org/Public/cldr/">unicode CLDR</a>. The rest is hardcoded. Speaking of <code>TextInfo</code> (a class that contains the <code>ListSeparator </code>value), it's defined in <a href="https://github.com/mono/mono/blob/mono-6.10.0.104/tools/locale-builder/Patterns.cs#L1610">Patterns.c</a><a href="https://github.com/mono/mono/blob/mono-6.10.0.104/tools/locale-builder/Patterns.cs#L1610">s</a>:

```cs
var entry_te = Text[lcid];
var te = ci.TextInfoEntry;
te.ANSICodePage = entry_te[0];
te.EBCDICCodePage = entry_te[1];
te.IsRightToLeft = entry_te[2] == "1" ? true : false;
te.ListSeparator = entry_te[3];
te.MacCodePage = entry_te[4];
te.OEMCodePage = entry_te[5];
```

The <code>lcid</code> value (<a href="https://docs.microsoft.com/en-us/openspecs/windows_protocols/ms-lcid/70feba9f-294e-491e-b6eb-56532684c37f">Language Code Identifier</a>) for Russian is 1049 or 0x419. (The values for a number of other languages can be found <a href="https://www.science.co.il/language/Locale-codes.php">here</a>).
The predefined values can also be found in Patterns.cs. Here is the corresponding <a href="https://github.com/mono/mono/blob/mono-6.10.0.104/tools/locale-builder/Patterns.cs#L665">entry</a> for Russian:

```cs
{ 0x0419, new [] { "1251", "20880", "0", ";", "10007", "866" } },
```

Thus, <code>entry_te[3]</code> equals <code>";"</code>. That's how Mono knows the <code>ListSeparator</code> value even if it's not defined in the current operating system.
<h2><strong>The .NET Core approach</strong></h2>
Unfortunately, .NET Core doesn't have predefined values for <code>ListSeparator</code>. There’s a fairly strange logic in the source code of .NET Core 3.1.3:

```cs
case LocaleString_ListSeparator:
// fall through
case LocaleString_ThousandSeparator:
    status = GetLocaleInfoDecimalFormatSymbol(locale, UNUM_GROUPING_SEPARATOR_SYMBOL, value, valueLength);
    break;
```

It looks like .NET Core always uses the <code>ThousandSeparator</code> value instead of <code>ListSeparator</code> on Linux and macOS. This doesn't feel right, so we filed an issue: <a href="https://github.com/dotnet/runtime/issues/536">dotnet/runtime#536</a>. Hopefully, this behavior will be improved in the future.
<h2><strong>Practical recommendations</strong></h2>
If you are using some <code>CultureInfo</code> properties that are not supported by one of your target operating systems, it's better to provide some fallback values. Here is an <a href="https://github.com/dotnet/BenchmarkDotNet/commit/0c48c2862f69a63407898680d18dd76b988c4197#diff-225f35e5288a4b6836d56a4fef7b6adc">example</a> of how this problem has been solved in BenchmarkDotNet:

```cs
public static string GetActualListSeparator([CanBeNull] this CultureInfo cultureInfo)
{
    cultureInfo = cultureInfo ?? DefaultCultureInfo.Instance;
    string listSeparator = cultureInfo.TextInfo.ListSeparator;

    // On .NET Core + Linux, TextInfo.ListSeparator returns NumberFormat.NumberGroupSeparator
    // To work around this behavior, we patch empty ListSeparator with ";"
    // See also: https://github.com/dotnet/runtime/issues/536
    if (string.IsNullOrWhiteSpace(listSeparator))
        listSeparator = ";";

    return listSeparator;
}
```

Having fallback values in place prevents us from seeing unexpected issues when running our code, and helps us be sure we can safely run our code across multiple platforms without any surprises.