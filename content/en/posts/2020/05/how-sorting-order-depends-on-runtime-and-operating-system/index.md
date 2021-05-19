---
title: "How Sorting Order Depends on Runtime and Operating System"
date: "2020-05-13"
tags:
- dotnet
- cs
- Rider
- Mono
- netcore
---

*This blog post was [originally posted](https://blog.jetbrains.com/dotnet/2020/05/13/sorting-order-depends-runtime-operating-system/) on [JetBrains .NET blog](https://blog.jetbrains.com/dotnet/).*

In <a href="https://www.jetbrains.com/rider/">Rider</a>, we have unit tests that enumerate files in your project and dump a sorted list of these files. In one of our test projects, we had the following files: <code>jquery-1.4.1.js</code>, <code>jquery-1.4.1.min.js</code>, <code>jquery-1.4.1-vsdoc.js</code>. On Windows, .NET Framework, .NET Core, and Mono produce the same sorted list:

```bash
jquery-1.4.1.js
jquery-1.4.1.min.js
jquery-1.4.1-vsdoc.js
```

<!--more-->

On Unix, Mono also produces the same list, so we had a consistent list of files across all environments. However, once we migrated to .NET Core, we discovered that the sorting order had changed to:

```bash
jquery-1.4.1-vsdoc.js
jquery-1.4.1.js
jquery-1.4.1.min.js
```

After a quick investigation, we realized that the problem was related to the <code>.</code> and <code>-</code> symbols. The example above can be simplified to the following minimal repro:

```cs
var list = new List<string> { "a.b", "a-b" };
Console.WriteLine(string.Join(" ", list.OrderBy(x => x)));
```

.NET Framework, Mono, and .NET Core+Windows print <code>a.b a-b</code> to the output. However, .NET Core on Unix thinks that <code>a-b</code> is smaller than <code>a.b</code>, and prints <code>a-b a.b</code>. Thus, the sorting order depends on the runtime and operating system that you use.
In our codebase, we fixed this problem with the help of <code>StringComparer.Ordinal</code>. Instead of <code>list.OrderBy(x =&gt; x)</code>, in the example above we would write <code>list.OrderBy(x =&gt; x, StringComparer.Ordinal)</code>. This guarantees a consistent string order that doesn't depend on the environment.
We also started to wonder about the other kinds of string sorting "phenomena" we might find by switching between runtimes and operating systems. Let's find out!
<h2><strong>Collecting more data</strong></h2>
We took a simple set of characters <code>.-'!a</code> and built all possible two-character combinations from them:

```cs
var chars = ".-'!a".ToCharArray();
var strings = new List<string>();
for (int i = 0; i < chars.Length; i++)
    for (int j = 0; j < chars.Length; j++)
        strings.Add(chars[i].ToString() + chars[j]);
```

Next, we compared these combinations to each other on different combinations of runtimes (.NET Framework, .NET Core, Mono) and operating systems (Windows, Linux, macOS):

```cs
using (var writer = new StreamWriter(filename))
{
    foreach (var a in strings)
        foreach (var b in strings)
             writer.WriteLine(a.CompareTo(b));
}
```

We discovered three different cases in which the <code>CompareTo</code> results are not consistent. To illustrate them, we took 4 string pairs from each group and built the following diagram for you:

{{< img dotnet-SortingTable-blog >}}

In the <a href="https://blog.jetbrains.com/dotnet/2020/04/27/socket-error-codes-depend-runtime-operating-system/">previous post</a> where we discussed socket implementations in different environments, we showed the source code for all relevant cases. This time, we suggest you do this exercise yourself. Try digging into the source code of all runtimes to find explanations for the above picture. For a bonus challenge, do your own experiments with <code>CultureInfo.CurrentCulture</code> and learn more about how the sorting order depends on the system locale. It would be great if you could share your findings with the community! To give you further inspiration for this kind of research, we want to show you a few more interesting facts.
<h2><strong>More tricky cases</strong></h2>
Sorting order can be pretty tricky, even if you are only working within one environment. A great example of unexpected behavior can be found in this StackOverflow <a href="https://stackoverflow.com/q/2244480/184842">question</a>, where developers discuss the following code snippet:

```cs
"+".CompareTo("-")
Returns: 1

"+1".CompareTo("-1")
Returns: -1
```

As you can see, <code>"+"</code> is greater than <code>"-"</code> while <code>"+1"</code> is lesser than <code>"-1"</code>. The <a href="https://stackoverflow.com/a/2244615/184842">best answer</a> quotes the following paragraph from Microsoft Docs:
<blockquote>The comparison uses the current culture to obtain culture-specific information such as casing rules and the alphabetic order of individual characters.
For example, a culture could specify that certain combinations of characters be treated as a single character, or uppercase and lowercase characters be compared in a particular way, or that the sorting order of a character depends on the characters that precede or follow it.</blockquote>
If we continue to read the documentation, we will see that there are overloads of <code>string.Compare</code> that take <code>System.Globalization.CompareOptions </code>as one of the arguments. Here is the most common overload:

```cs
public static int Compare(string strA, string strB, CultureInfo culture, CompareOptions options);
```

The <a href="https://docs.microsoft.com/en-us/dotnet/api/system.globalization.compareoptions">CompareOptions</a> flag enum defines the string comparison rules. Here are the most interesting values:
<ul>
	<li><strong>IgnoreKanaType:</strong> Indicates that the string comparison must ignore the Kana type. Kana type refers to Japanese hiragana and katakana characters, which represent phonetic sounds in the Japanese language. Hiragana is used for native Japanese expressions and words, while katakana is used for words borrowed from other languages, such as "computer" or "Internet". A phonetic sound can be expressed in both hiragana and katakana. If this value is selected, the hiragana character for one sound is considered equal to the katakana character for the same sound.</li>
	<li><strong>IgnoreNonSpace:</strong> Indicates that the string comparison must ignore non-spacing combining characters, such as diacritics. The Unicode Standard defines combining characters as characters that are combined with base characters to produce a new character. Non-spacing combining characters do not occupy a spacing position by themselves when rendered.</li>
	<li><strong>IgnoreSymbols:</strong> Indicates that the string comparison must ignore symbols, such as white-space characters, punctuation, currency symbols, the percent sign, mathematical symbols, the ampersand, and so on.</li>
	<li><strong>IgnoreWidth</strong>: Indicates that the string comparison must ignore character width. For example, Japanese katakana characters can be written as full-width or half-width. If this value is selected, the katakana characters written as full-width are considered equal to the same characters written as half-width.</li>
	<li><strong>Ordinal:</strong> Indicates that the string comparison must use the successive Unicode UTF-16 encoded values of the string (code unit by code unit comparison), leading to a fast comparison, but one that is culture-insensitive. A string starting with a code unit XXXX16 comes before a string starting with YYYY16, if XXXX16 is less than YYYY16. This value cannot be combined with other CompareOptions values and must be used alone.</li>
	<li><strong>StringSort:</strong> Indicates that the string comparison must use the string sort algorithm. In a string sort, the hyphen and the apostrophe, as well as other non-alphanumeric symbols, come before alphanumeric characters.</li>
</ul>
Try to play with these values, and find examples of string lists that can be sorted differently depending on the above flags. This kind of experiment is a great way to learn more about runtime and to become more aware of pitfalls related to string sorting.
This is not the end of our adventure, however. There is one more global option that can completely change the behavior of string comparison!
<h2><strong>Globalization invariant mode</strong></h2>
In .NET Core 2.0+, there is a feature called <em>Globalization invariant mode</em>, which uses the <code>Ordinal</code> sorting rule for all string comparisons by default. It can be enabled if you set the <code>DOTNET_SYSTEM_GLOBALIZATION_INVARIANT</code> environment variable to <code>true</code> or <code>1</code>. Let's enable this mode and run examples from the previous section:

```cs
Console.WriteLine(string.Compare("-", "+"));
Console.WriteLine(string.Compare("-x", "+x"));
```

Now it prints a new result:

```txt
2
2
```

Some developers may think that it's a good idea to always enable this by default to avoid problems with inconsistent sorting. Note that in this mode, you will get poor globalization support: a lot of features will be affected, including all <code>CultureInfo</code>-specific logic, string operations, internationalized domain names (IDN) support, and even time zone display names on Linux. If you want to enable it, carefully read the <a href="https://github.com/dotnet/runtime/blob/master/docs/design/features/globalization-invariant-mode.md">documentation</a> first.
It's worth mentioning that if you don't control the environment of your application, there is a chance that users will enable it manually. This could significantly affect any .NET Core application!
<h2><strong>Conclusion</strong></h2>
Here are a few practical recommendations that can help you avoid tricky and painful bugs in the future:
<ul>
	<li>If you want to achieve consistent string comparison across different runtimes and operating systems, always use <code>StringComparer.Ordinal</code>.</li>
	<li>If you don't use <code>StringComparer.Ordinal</code>, always keep in mind that the sorting order may depend on runtime, operating system, current culture, and environment variables.</li>
	<li>Try to do your own experiments and learn more about sorting rules in .NET. This time we decided to leave out the detailed explanations and instead encourage you to explore them for yourself. After all, this is the best way to learn something new and improve your programming skills!</li>
</ul>