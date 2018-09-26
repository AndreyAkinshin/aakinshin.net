---
layout: ru-post
title: "Занимательное о шрифтах в .NET"
date: "2013-06-03"
lang: ru
type: post
tags:
- fonts
- ".NET"
- C#
redirect_from:
- /ru/blog/dotnet/fonts/
- /ru/blog/post/dotnet-fonts/
---


Сегодня мы поговорим о замечательном классе [Font](http://msdn.microsoft.com/en-us/library/system.drawing.font(v=vs.90).aspx). Иногда при работе с шрифтами возникают некоторые вопросы, которые не настолько очевидны, как хотелось бы. Рассмотрим несколько из них.

---

**Q:** Как опознать моноширинный шрифт?

**A:** Это не такой простой вопрос. Если немного погуглить, то можно найти следующий совет: описываем у себя в проекте класс [LOGFONT](http://www.pinvoke.net/default.aspx/Structures/LOGFONT.html) и используем метод [ToLogFont](http://msdn.microsoft.com/en-us/library/9a240xh2.aspx) для конвертации шрифта в соответствующий объект. После этого (согласно легенде) в поле [lfPitchAndFamily](http://msdn.microsoft.com/en-us/library/microsoft.visualstudio.shell.interop.uidlglogfont.lfpitchandfamily(v=vs.80).aspx) первый бит должен определять моноширинность шрифта. Так вот, это враньё, в современном мире поле [всегда будет равно нулю](http://social.msdn.microsoft.com/Forums/en-US/netfxbcl/thread/1bc0166b-8a68-4067-a44b-e11ff7d55720). Когда-то где-то этот способ работал, но сейчас не работает. В реальности приходится использовать не очень красивое, но весьма эффективное решение типа такого:

```
// graphics — заранее созданный экземпляр класса Graphics
public static bool IsMonospace(Font font)
{
    return Math.Abs(graphics.MeasureString("iii", font).Width - 
                    graphics.MeasureString("WWW", font).Width) < 1e-3;
}
```

<!--more-->

---

**Q:** А как узнать размеры, которые будет занимать строчка при рисовании данным шрифтом?


**A:** Нам понадобится [Graphics](http://msdn.microsoft.com/en-us/library/system.drawing.graphics.aspx), с помощью которого мы собираемся рисовать, а именно — его метод
[MeasureString](http://msdn.microsoft.com/en-us/library/6xe5hazb.aspx). Передаём ему рисуемый текст и используемый шрифт — а он нам в ответ отдаёт его размеры.

---

**Q:** А если мне нужен размер не всей строчки, а только заданных её частей?

**A:** Это можно сделать с помощью метода [Graphics.MeasureCharacterRanges](http://msdn.microsoft.com/en-us/library/system.drawing.graphics.measurecharacterranges.aspx). Но сначала (в msdn есть хороший пример) нужно задать целевые интервалы символов с помощью метода [StringFormat.SetMeasurableCharacterRanges](http://msdn.microsoft.com/ru-ru/library/system.drawing.stringformat.setmeasurablecharacterranges.aspx). Это метод обладает занимательным ограничением — ему нельзя передавать более 32-х интервалов.

---

**Q:** Этот метод выдаёт какие-то слишком большие границы. В них попадают не только сами символы, но и немного пространства около них. Что делать?

**A:** Действительно, возвращаемые регионы содержат интересующие нас символы так, как они идут в исходном шрифте — вместе с небольшой пустотой около них. Красивого способа получить точные границы нет. Придётся явно создавать картинку с целевыми символами, попиксельно её просмотреть (только не используйте метод
[Bitmap.GetPixel](http://msdn.microsoft.com/en-us/library/system.drawing.bitmap.getpixel.aspx), он очень долгий, есть [более быстрые способы](http://stackoverflow.com/questions/1563038/fast-work-with-bitmaps-in-c-sharp)) и найти крайние нарисованные символы нашей строки.

---

**Q:** Я создал шрифт, используя его строковое название, никаких исключений не вылетело. А этот шрифт точно есть в системе?

**A:** Не обязательно. Конструктор класса Font попытается подобрать самый подходящий (по его мнению) шрифт для данного названия. Лучше проверить, что создался правильный шрифт:

```cs
var font = new Font(fontName, 12);
vat exists = font.Name == fontName;
```

А ещё не помешает проверить, поддерживает ли используемое вами семейство шрифтов ваш [FontStyle](http://msdn.microsoft.com/en-us/library/system.drawing.fontstyle.aspx):

```cs
var fontFamily = new FontFamily(fontName);
exists &= fontFamily.IsStyleAvailable(fontStyle);
```