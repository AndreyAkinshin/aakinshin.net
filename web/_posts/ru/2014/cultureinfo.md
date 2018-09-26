---
layout: ru-post
title: "Эти занимательные региональные настройки"
date: "2014-09-21"
lang: ru
type: post
tags:
- ".NET"
- CultureInfo
- Localization
- Globalization
redirect_from:
- /ru/blog/dotnet/cultureinfo/
- /ru/blog/post/cultureinfo/
---

Сегодня мы поговорим о региональных настройках. Но сперва — небольшая задачка: что выведет нижеприведённый код? (Код приведён на языке C#, но рассматривается достаточно общая проблематика, так что вы можете представить на его месте какой-нибудь другой язык.)

```cs
Console.WriteLine((-42).ToString() == "-42");
Console.WriteLine(double.NaN.ToString() == "NaN");
Console.WriteLine(int.Parse("-42") == -42);
Console.WriteLine(1.1.ToString().Contains("?") == false);
Console.WriteLine(new DateTime(2014, 1, 1).ToString().Contains("2014"));
Console.WriteLine("i".ToUpper() == "I" || "I".ToLower() == "i");
```

Сколько значений `true` у вас получилось? Если больше `0`, то вам не мешает узнать больше про региональные настройки, т. к. правильный ответ: «зависит». К сожалению, многие программисты вообще не задумываются о том, что настройки эти в различных окружениях могут отличаться. А выставлять для всего кода InvariantCulture этим программистом лениво, в результате чего их прекрасные приложения ведут себя очень странно, попадая к пользователям из других стран.

Ошибки бывают самые разные, но чаще всего связаны они с форматированием и парсингом строк — достаточно частыми задачами для многих программистов. В статье приведена краткая подборка некоторых важных моментов, на которые влияют региональные настройки.

<p class="center">
  <img src="/img/posts/dotnet/cultureinfo/dotnet-cultureinfoexplorer.png" />
</p>

<!--more-->

Совсем немного теории: в .NET все сведения об определённом языке и региональных параметрах можно найти с помощью класса [CultureInfo](http://msdn.microsoft.com/en-us/library/system.globalization.cultureinfo.aspx). Если вы ранее не сталкивались с культурами, то для первичного ознакомления хорошо подойдёт [этот пост](http://habrahabr.ru/post/166053/). Искушённый программист, увлечённый изучением различных существующих региональных настроек, может утомиться от ручного просмотра всех `CultureInfo`. Лично я в какой-то момент утомился. Поэтому появилось небольшое WPF-приложение под названием CultureInfoExplorer ([ссылка на GitHub](https://github.com/AndreyAkinshin/CultureInfoExplorer), [бинарники](https://github.com/AndreyAkinshin/CultureInfoExplorer/releases/tag/v1.0.0.0)), представленное на вышеприведённом скриншоте. Оно позволяет:

* По данной	`CultureInfo` посмотреть значение основных её свойств и то, как в ней выглядят некоторые заранее заготовленные строковые паттерны.
* По данному свойству посмотреть его возможные значения и список всех `CultureInfo`, которые соответствуют каждому значению.
* По данному паттерну посмотреть возможные варианты того, во что он может превратиться, и для каждого варианта также посмотреть список соответствующих `CultureInfo`.

Надеюсь, найдутся читатели, которым данная программка будет полезна. Можно узнать много нового о различных региональных настройках. Ну, а теперь перейдём к примерам.

### Числа

За представление чисел у нас отвечает [NumberFormatInfo](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.aspx) (доступный через [CultureInfo.NumberFormat](http://msdn.microsoft.com/en-us/library/system.globalization.cultureinfo.numberformat.aspx)). И имеются в виду не только обычные числа, а также процентные и денежные значения. Обратите внимание на то, что значения бывают положительные и отрицательные: если вы работаете с локализацией/глобализацией, то важно обращать на это внимание. Настоятельно рекомендую хотя бы пробежаться глазами по документации и посмотреть доступные свойства.

Одно из самых популярных свойств, которое вызывает проблемы у людей, называется [NumberDecimalSeparator](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.numberdecimalseparator.aspx). Оно отвечает за то, чем будет при форматировании числа отделяться целая часть от дробной. Типичный пример ошибки: программист сливает массив дробных чисел в строчку, разделяя их запятыми. После этого он пытается распарсить строчку обратно в массив. Если `NumberDecimalSeparator` равен точке, то всё будет хорошо. Скажем, при выставленной культуре `en-US` у программиста всё заработало, он выпустил свой продукт. Этот продукт скачивает пользователь с культурой `ru-RU` и начинает грустить: ведь у него `NumberDecimalSeparator` равен запятой: массив из элементов 1.2 и 3.4 при таком слиянии превратится в строчку `"1,2,3,4"`, а её распарсить будет проблемно. Лично мне становится ещё грустнее тогда, когда встретивший подобную проблему программист не пытается решить её нормально, указывая правильный `NumberFormatInfo` при форматировании, а начинает колдовать с заменами точек на запятые или запятых на точки. Нужно понимать, что `NumberDecimalSeparator`, в принципе, может быть любой. Например, в культуре `fa-IR` (Persian) он равен слешу (`'/'`).

Ещё в нашем распоряжении имеются аналогичные свойства для процентов и валют: [PercentDecimalSeparator](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.percentdecimalseparator.aspx) и [CurrencyDecimalSeparator](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.currencydecimalseparator.aspx). Все эти три значения вовсе не обязаны совпадать. Например, у казахов (`kk-KZ`) `NumberDecimalSeparator` и `PercentDecimalSeparator` равны запятой, а `CurrencyDecimalSeparator` равен знаку минус (точно такому же, с помощью которого обозначаются отрицательные числа).

Некоторые считают, что целое число при конвертации в строку даёт значение, состоящее только из цифр. Но цифры эти могут разбиваться на группы. За размер групп отвечает свойство [NumberGroupSizes](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.numbergroupsizes.aspx), а за их разделитель —
[NumberGroupSeparator](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.numbergroupseparator.aspx)	(аналогичные свойства есть у процентов и валют, но они опять-таки не обязаны совпадать). Группы могут быть разного размера: например, во многих культурах (`as-IN`, `bn-BD`, `gu-IN`, `hi-IN` и т.п.) `NumberGroupSizes` равно {3, 2}. Скажем, число 1234567 в культуре as-IN будет выглядеть как `"12,34,567"`. В качестве разделителя групп может выступать пробел `\u0020` (например в `af-ZA` и `lt-LT`), но, увидев его, не торопитесь вбивать очередной костыль на парсинг и форматирование строк. Чаще всего вместо обычного пробела используется неразрывный пробел `\u00A0` (наша родная `ru-RU`).

Знаки для обозначения отрицательных и положительных чисел также входят в культуру: [NegativeSign](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.negativesign.aspx), [PositiveSign](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.positivesign.aspx). Слава богу, во всех доступных культурах они равны минусу и плюсу, но закладываться на это не стоит: окружение можно переопределить и задать свойствам любые значения. А самое интересное заключается не в знаках, а в паттернах форматирования положительных и отрицательных значений. Например, форматирование отрицательного числа определяется с помощью [NumberNegativePattern](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.numbernegativepattern.aspx), у которого есть пять возможных значений:

```
0 (n)
1 -n
2 - n
3 n-
4 n -
```

Например, в культуре `ti-ET` (Tigrinya (Ethiopia)) значение `-5` предстанет в виде `(5)`. С процентами и валютами ([PercentNegativePattern](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.percentnegativepattern.aspx),	[PercentPositivePattern](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.percentpositivepattern.aspx), [CurrencyNegativePattern](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.currencynegativepattern.aspx),	[CurrencyPositivePattern](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.currencypositivepattern.aspx)) дело обстоит ещё веселее. Например, для `CurrencyNegativePattern` есть целых шестнадцать возможных значений:

```
0  ($n)
1  -$n
2  $-n
3  $n-
4  (n$)
5  -n$
6  n-$
7  n$-
8  -n $
9  -$ n
10 n $-
11 $ n-
12 $ -n
13 n- $
14 ($ n)
15 (n $)
```

Также есть специальные свойства для специальных знаков и специальных численных значений: [PercentSymbol](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.percentsymbol.aspx),	[PerMilleSymbol](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.permillesymbol.aspx), [NaNSymbol](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.nansymbol.aspx), [NegativeInfinitySymbol](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.negativeinfinitysymbol.aspx), [PositiveInfinitySymbol](http://msdn.microsoft.com/en-us/library/system.globalization.numberformatinfo.positiveinfinitysymbol.aspx). Мне доводилось видеть реальный проект, в котором брался double, форматировался в строку (разумеется, в текущей культуре пользователя), а затем в строковом виде сравнивался с `«-Infinity»`. А в зависимости от этой самой текущей культуры `NegativeInfinitySymbol` может принимать самые разные значения:

<pre class="prettyprint" style="white-space: pre-wrap">'- безкрайност', '-- អនន្ត', '(-) முடிவிலி', '-∞', '-Anfeidredd', '-Anfin', '-begalybė', '-beskonačnost', 'Éigríoch dhiúltach', '-ifedh', '-INF', '-Infini', '-infinit', '-Infinit', '-Infinito', '-Infinitu', '-infinity', 'Infinity-', '-Infinity', 'miinuslõpmatus', 'mínusz végtelen', '-nekonečno', '-neskončnost', '-nieskończoność', '-njekónčne', '-njeskóńcnje', '-onendlech', '-Sonsuz', '-tükeniksizlik', '-unendlich', '-Unendlich', '-Άπειρο', '-бесконачност', 'терс чексиздик', '-უსასრულობა', 'אינסוף שלילי', '-لا نهاية', 'منهای بی نهایت', 'مەنپىي چەكسىزلىك', '-අනන්තය', 'ᠰᠦᠬᠡᠷᠬᠦ ᠬᠢᠵᠠᠭᠠᠷᠭᠦᠢ ᠶᠡᠬᠡ', 'མོ་གྲངས་ཚད་མེད་ཆུང་བ།', 'ߘߊ߲߬ߒߕߊ߲߫-', 'ꀄꊭꌐꀋꉆ', '負無窮大', '负无穷大'</pre>

Примеры разных полезных свойств мы разобрали. А теперь давайте немножко пошалим: чуть-чуть изменим русскую культуру, чтобы её новое значение портило нам жизнь в примере из начала поста:

```cs
var myCulture = (CultureInfo)new CultureInfo("ru-RU").Clone();
myCulture.NumberFormat.NegativeSign = "!";
myCulture.NumberFormat.PositiveSign = "-";
myCulture.NumberFormat.PositiveInfinitySymbol = "+Inf";
myCulture.NumberFormat.NaNSymbol = "Not a number";
myCulture.NumberFormat.NumberDecimalSeparator = "?";
Thread.CurrentThread.CurrentCulture = myCulture;
Console.WriteLine(-42); // !42
Console.WriteLine(double.NaN); // Not a number
Console.WriteLine(int.Parse("-42")); // 42
Console.WriteLine(1.1); // 1?1
```

Возможно, кто-то тут скажет мне: «Да зачем такие примеры вообще рассматривать? Ни один программист такое никогда писать не будет!». А я отвечу: «Ну-ну, ни один не будет, как же». Ситуация становится печальной, когда вы распространяете некоторую библиотеку, а один из её пользователей решил поразвлекаться с культурой. Может, он просто любит развлекаться, а может, пишет приложение для какой-то диковиной культуры (скажем, мёртвого или вымышленного языка). Но это не важно. А важно то, что ваша библиотека начинает вести себя странно в непривычном для неё окружении. Поэтому не стоит закладываться на то, что `NegativeSign` и `PositiveSign` никогда не меняются. Лучше просто явно указать нужную вам культуру и жить счастливо.

А ещё, всем советую прочитать недавний пост Джона Скита [The BobbyTables culture](http://codeblog.jonskeet.uk/2014/08/08/the-bobbytables-culture/). Краткая суть: Джон Скит ругается на тех, кто не экранирует параметры в SQL-запросах, даже если это числа и даты. И тогда Джон берёт пару запросов

```
"SELECT * FROM Foo WHERE BarDate > '" + DateTime.Today + "'"
"SELECT * FROM Foo WHERE BarValue = " + (-10)
```

и определяет чудо-культуру:

```cs
CultureInfo bobby = (CultureInfo) CultureInfo.InvariantCulture.Clone();
bobby.DateTimeFormat.ShortDatePattern = ＠"yyyy-MM-dd'' OR ' '=''";
bobby.DateTimeFormat.LongTimePattern = "";
bobby.NumberFormat.NegativeSign = "1 OR 1=1 OR 1=";
```

Легким движением руки запросы превращаются в:

```
SELECT * FROM Foo WHERE BarDate > '2014-08-08' OR ' '=' '
SELECT * FROM Foo WHERE BarValue = 1 OR 1=1 OR 1=10
```

Ну, думаю, дальнейшие пояснения не нужны.

### Дата и время

С датами и временем всё особенно тяжело. За даты у нас отвечает класс [DateTimeFormatInfo](http://msdn.microsoft.com/en-us/library/system.globalization.datetimeformatinfo.aspx) (свойство [CultureInfo.DateTimeFormat](http://msdn.microsoft.com/en-us/library/system.globalization.cultureinfo.datetimeformat.aspx)), а в нём есть [Calendar](http://msdn.microsoft.com/en-us/library/system.globalization.datetimeformatinfo.calendar.aspx). Причём есть основной календарь культуры ([CultureInfo](http://msdn.microsoft.com/en-us/library/system.globalization.cultureinfo.calendar.aspx)), а есть список доступных для использования календарей ([CultureInfo.OptionalCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.cultureinfo.optionalcalendars.aspx)). В нашем распоряжении имеется большая пачка стандартных календарей:

[ChineseLunisolarCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.chineselunisolarcalendar.aspx),
[EastAsianLunisolarCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.eastasianlunisolarcalendar.aspx),
[GregorianCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.gregoriancalendar.aspx),
[HebrewCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.hebrewcalendar.aspx),
[HijriCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.hijricalendar.aspx),
[JapaneseCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.japanesecalendar.aspx),
[JapaneseLunisolarCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.japaneselunisolarcalendar.aspx),
[JulianCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.juliancalendar.aspx),
[KoreanCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.koreancalendar.aspx),
[KoreanLunisolarCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.koreanlunisolarcalendar.aspx),
[PersianCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.persiancalendar.aspx),
[TaiwanCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.taiwancalendar.aspx),
[TaiwanLunisolarCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.taiwanlunisolarcalendar.aspx),
[ThaiBuddhistCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.thaibuddhistcalendar.aspx),
[UmAlQuraCalendar](http://msdn.microsoft.com/en-us/library/system.globalization.umalquracalendar.aspx)
(у некоторых есть ряд дополнительных важных параметров). Логика у них, доложу я вам, самая разная. Не будем останавливаться подробно, ибо на эту тему подробной информации в интернете достаточно, а материала хватит на серию самостоятельных постов. Правила форматирования дат и времени ещё более весёлые, чем у чисел: куча паттернов для разных вариантов форматирования даты, нативные имена для месяцев и дней недели, обозначения для AM/PM, разделители и т.п. Скажем, 31 декабря 2014 года может быть представлено (`dateTime.ToString("d")`) в следующих форматах:

```
09/03/36
10/3/1436
12/31/2014
1436/3/10
2014.12.21.
2014/12/21
2014-12-21
31. 12. 2014
31.12.14
31.12.14 ý.
31.12.2014
31.12.2014 г.
31.12.2014.
31/12/14
31/12/2014
31/12/2557
31-12-14
31-12-2014
31-дек 14
31-жел-14
```

И это только дефолтные значения (без подключения опциональных календарей). Но даже тут видно разнообразие летоисчислений: у кого-то на дворе 1436 год, а у кого-то — 2557 (это отсылка к предпоследней строчке примера из начала статьи). Если вы оперируете с датами, то следует задуматься: стоит ли их показывать всегда в одинаковом формате или же подстроиться под пользователя и отобразить дату в более привычном для него виде. Ну, а про парсинг дат я вообще умолчу.

### The Turkey Test

<p class="center">
  <img src="/img/posts/dotnet/cultureinfo/turkey-flag.png" />
</p>

Есть классический пост от 2008 года под называнием [Does Your Code Pass The Turkey Test?](http://www.moserware.com/2008/02/does-your-code-pass-turkey-test.html). Подробно пересказывать его не буду, лучше самостоятельно прочитать оригинал. Краткая суть The Turkey Test такова: поменяйте текущую культуру на tr-TR (Turkish (Turkey)) и запустите ваше приложение. Всё ли нормально работает? В этой культуре хватает веселья и с датами, и с числами, и со строками. Если вернуться к нашему первому примеру, то в рассматриваемой культуре `"i".ToUpper()` не равно `"I"`, а `"I".ToLower()` не равно `"i"` (если вам интересно больше узнать про заглавные и строчные буквы, то крайне рекомендую [этот пост](http://habrahabr.ru/post/147387/)	и [вот этот SO-ответ про UTF-8](http://stackoverflow.com/a/6163129/184842), это просто прекрасно). В конце поста приводится замечательный пример, в котором под регулярное выражение `\d{5}` подходит строка состоящая из арабских цифр `"٤٦٠٣٨"`.

### Вместо заключения

Наука о региональных настройках сложна. В этом посте я ни в коем случае не претендую на то, чтобы выдать полную информацию о том, на что же они могут влиять. Есть ещё очень много разных интересностей, связанных с интернализацией (думаю, только про идущий справа налево текст можно написать отдельный пост, да и не один). Мне просто хотелось показать несколько занимательных примеров того, как `CultureInfo.CurrentCulture` может повлиять на ваше приложение. Надеюсь, в плане расширения общей эрудиции этот материал окажется кому-то полезным. Общая мораль такова: если вы не хотите думать о том, что в мире существует много разных культур, то используйте везде `CultureInfo.InvariantCulture` (или другую подходящую вам культуру) — в подавляющем большинстве случаев вы сможете спать спокойно. А если вы об этом задумываетесь, то неплохо бы поизучать эту область более основательно. В этом может помочь вот эта хорошая книжка: [Net Internationalization: The Developer's Guide to Building Global Windows and Web Applications](https://www.goodreads.com/book/show/1310940.Net_Internationalization).

Приветствуются любые дополнительные факты о том, как `CultureInfo` может повлиять на работу различных функций. Думаю, у многих найдутся собственные увлекательные истории.

### Ссылки

* [Оригинал поста на Хабре](habrahabr.ru/post/237209/)