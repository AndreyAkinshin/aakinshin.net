---
layout: ru-post
title: FastColoredTextBox — божественный RichTextBox для .NET
date: "2013-07-17"
lang: ru
type: post
tags:
- WPF
- ".NET"
- C#
- GUI
- Controls
redirect_from:
- /ru/blog/dotnet/fastcoloredtextbox/
- /ru/blog/post/fastcoloredtextbox/
---

Появилась у меня недавно задачка сделать в WPF-приложении красивый редактор форматированного текста с определённой логикой обработки. И решил я использовать для этой задачи стандартный [RichTextBox](http://msdn.microsoft.com/ru-ru/library/system.windows.controls.richtextbox.aspx). Увы, практика показала, что этот контрол [ужасно медленный](https://www.google.ru/search?q=wpf+richtextbox+performance). Можно было, конечно, написать свою реализацию, но это занятие долгое, а функционал нужно было прикрутить побыстрее. Первая мысль была [захостить](http://msdn.microsoft.com/en-us/library/ms751761.aspx) стандартный [RichTextBox](http://msdn.microsoft.com/ru-ru/library/system.windows.forms.richtextbox.aspx) из WinForms. Он работает достаточно быстро, но его функционала мне не хватило. И тогда я пустился в поиск сторонних контролов. Каким же счастливым я стал, когда наткнулся на FastColoredTextBox! Изучение контрола лучше всего начать со [статьи](http://www.codeproject.com/Articles/161871/Fast-Colored-TextBox-for-syntax-highlighting) на CodeProject. Увы, NuGet-пакет автор [по каким-то причинам](https://github.com/PavelTorgashov/FastColoredTextBox/issues/10) делать не хочет, но зато есть [исходники](https://github.com/PavelTorgashov/FastColoredTextBox) на GitHub. Итак, небольшой обзор.

<p class="center">
  <img src="/img/posts/dotnet/fastcoloredtextbox/screen1.png" />
</p>

<!--more-->

Главным образом, автор библиотеки ([Павел Торгашов](https://github.com/PavelTorgashov)) ориентировал его на работу с программным кодом, но разработанный контрол прекрасно подходит для любых других задач. В WinForms его можно использовать в чистом виде, а в WPF приложение его легко добавить [даже прямо через XAML](http://msdn.microsoft.com/en-us/library/ms742875.aspx). Скорость работы впечатляет (отличный performance был основной задачей автора), рендеринг происходит на основе GDI+. В рамках одного контрола поддерживается 16 стилей, но, как [говорит автор](https://github.com/PavelTorgashov/FastColoredTextBox/issues/18), если вам нужно больше, то вы делаете что-то не так. Распространяется под [LGPLv3](http://opensource.org/licenses/lgpl-3.0.html), а значит можно использовать в проприетарном софте. Есть [chm-документация](http://www.codeproject.com/script/articles/download.aspx?file=/KB/edit/FastColoredTextBox_/FastColoredTextBox_Help.zip&rp=http://www.codeproject.com/Articles/161871/Fast-Colored-TextBox-for-syntax-highlighting), но больше толку от оригинальной статьи и demo-проекта Tester из репозитория, который содержит большое количество примеров на все случаи жизни:

<p class="center">
  <img src="/img/posts/dotnet/fastcoloredtextbox/screen2.png" />
</p>

### Выводы

За свою жизнь я поработал с очень большим количеством разных контролов и могу авторитетно заявить: FastColoredTextBox реализован очень грамотно. В большинстве случаев, когда мне нужно было какое-нибудь свойство, то я задавал себе простой вопрос: *«Если бы я был этим свойством, то как бы я назывался?»*. Первый пришедший в голову ответ вместе с intellisense помогали быстро найти нужную функциональность. Некоторые особенности, которые понравились лично мне:

* Контрол работает ну очень быстро
* Отличное API, XML-документация и demo-приложение
* Продвинутая подсветка любого синтаксиса на основе регулярных выражений
* Интерактивное выделение некоторых частей, в зависимости от позиции курсора
* Возможность определять свои стили, в которых можно написать собственную отрисовку каждого символа через обычный Graphics
* Свёртка блоков текста
* Навигация по тексту, закладки
* Autocomplete
* Встроенные в тело документа Hint-ы и всплывающие ToolTip-ы
* Запись макросов
* Поддержка стандартных горячих клавиш (с возможностью назначить свои) и работы с буфером
* Хранение истории, нормальный ChangeTracker с операциями Undo/Redo
* Экспорт в HTML
* .NET Framework 2.0 и поддержка Compact Framework
